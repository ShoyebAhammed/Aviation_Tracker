import '../datasources/flight_local_datasource.dart';
import '../datasources/flight_remote_datasource.dart';
import '../models/flight_model.dart';
import '../models/pagination_model.dart';

class FlightFetchResult {
  final List<FlightModel> flights;
  final PaginationModel pagination;
  final bool isFromCache;
  final String? warningMessage;

  FlightFetchResult({
    required this.flights,
    required this.pagination,
    required this.isFromCache,
    this.warningMessage,
  });
}

class FlightRepository {
  final FlightRemoteDataSource remoteDataSource;
  final FlightLocalDataSource localDataSource;

  FlightRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  /// Fetch flights with Minimal API strategy & Local Caching
  Future<FlightFetchResult> getFlights({
    required String apiKey,
    required bool isDemoMode,
    int offset = 0,
    int limit = 20,
    String? flightStatus,
    String? searchQuery,
    bool forceRefresh = false,
  }) async {
    // 1. If in Demo Mode or No API Key provided, serve purely from Local Cache / Seed
    if (isDemoMode || apiKey.trim().isEmpty) {
      await localDataSource.incrementCacheHits();
      final localFlights = localDataSource.getPaginatedFlights(
        offset: offset,
        limit: limit,
        flightStatus: flightStatus,
        searchQuery: searchQuery,
      );
      final total = localDataSource.getTotalFlightsCount(
        flightStatus: flightStatus,
        searchQuery: searchQuery,
      );
      final pagination = PaginationModel(
        limit: limit,
        offset: offset,
        count: localFlights.length,
        total: total,
      );
      return FlightFetchResult(
        flights: localFlights,
        pagination: pagination,
        isFromCache: true,
        warningMessage: null,
      );
    }

    // 2. Try fetching from Remote API
    try {
      final response = await remoteDataSource.getFlights(
        apiKey: apiKey,
        limit: limit,
        offset: offset,
        flightStatus: flightStatus,
        searchQuery: searchQuery,
      );

      await localDataSource.incrementApiHits();

      // Cache newly fetched flights locally
      await localDataSource.cacheFlights(response.data, clearExisting: forceRefresh && offset == 0);

      // Merge with any custom user flights if at initial page
      final combinedFlights = offset == 0
          ? _mergeWithCustomFlights(response.data)
          : response.data;

      return FlightFetchResult(
        flights: combinedFlights,
        pagination: response.pagination,
        isFromCache: false,
      );
    } catch (e) {
      // 3. Fallback to Local Cache on network or quota failure
      await localDataSource.incrementCacheHits();
      final localFlights = localDataSource.getPaginatedFlights(
        offset: offset,
        limit: limit,
        flightStatus: flightStatus,
        searchQuery: searchQuery,
      );
      final total = localDataSource.getTotalFlightsCount(
        flightStatus: flightStatus,
        searchQuery: searchQuery,
      );

      return FlightFetchResult(
        flights: localFlights,
        pagination: PaginationModel(
          limit: limit,
          offset: offset,
          count: localFlights.length,
          total: total,
        ),
        isFromCache: true,
        warningMessage: null,
      );
    }
  }

  List<FlightModel> _mergeWithCustomFlights(List<FlightModel> apiFlights) {
    final allLocal = localDataSource.getAllFlights();
    final customFlights = allLocal.where((f) => f.isCustom).toList();
    final combined = <FlightModel>[...customFlights, ...apiFlights];
    final seen = <String>{};
    return combined.where((f) => seen.add(f.id)).toList();
  }

  // ==================== CRUD Operations ====================

  Future<void> createFlight(FlightModel flight) async {
    await localDataSource.saveFlight(flight);
  }

  Future<void> updateFlight(FlightModel flight) async {
    await localDataSource.saveFlight(flight);
  }

  Future<void> deleteFlight(String id) async {
    await localDataSource.deleteFlight(id);
  }

  Future<FlightModel?> toggleFavorite(String id) async {
    return await localDataSource.toggleFavorite(id);
  }

  List<FlightModel> getFavoriteFlights() {
    return localDataSource.getAllFlights().where((f) => f.isFavorite).toList();
  }

  List<FlightModel> getAllCachedFlights() {
    return localDataSource.getAllFlights();
  }

  int getApiHits() => localDataSource.getApiHits();
  int getCacheHits() => localDataSource.getCacheHits();
  Future<void> resetMetrics() => localDataSource.resetMetrics();
  Future<void> clearCache() => localDataSource.clearAllCache();
}


import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/flight_model.dart';
import '../../data/models/pagination_model.dart';
import '../../data/repositories/flight_repository.dart';
import 'settings_provider.dart';

class FlightProvider with ChangeNotifier {
  final FlightRepository repository;
  final SettingsProvider settingsProvider;

  FlightProvider({
    required this.repository,
    required this.settingsProvider,
  });

  List<FlightModel> _flights = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String? _noticeMessage;

  String _selectedStatus = 'all';
  String _searchQuery = '';
  PaginationModel? _pagination;

  Timer? _debounceTimer;

  List<FlightModel> get flights => _flights;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  String? get noticeMessage => _noticeMessage;
  String get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;
  PaginationModel? get pagination => _pagination;
  bool get hasMore => _pagination?.hasMore ?? false;

  int get apiHits => repository.getApiHits();
  int get cacheHits => repository.getCacheHits();

  /// Initial load or pull-to-refresh
  Future<void> fetchFlights({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await repository.getFlights(
        apiKey: settingsProvider.apiKey,
        isDemoMode: settingsProvider.isDemoMode,
        offset: 0,
        limit: 20,
        flightStatus: _selectedStatus,
        searchQuery: _searchQuery,
        forceRefresh: forceRefresh,
      );

      _flights = result.flights;
      _pagination = result.pagination;
      _noticeMessage = result.warningMessage;
    } catch (e) {
      _errorMessage = 'Failed to load flights: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pagination: Infinite scroll / Load more
  Future<void> loadMoreFlights() async {
    if (_isLoading || _isLoadingMore || !hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextOffset = (_pagination?.offset ?? 0) + (_pagination?.count ?? 20);
      final result = await repository.getFlights(
        apiKey: settingsProvider.apiKey,
        isDemoMode: settingsProvider.isDemoMode,
        offset: nextOffset,
        limit: 20,
        flightStatus: _selectedStatus,
        searchQuery: _searchQuery,
      );

      // Append new unique flights
      final existingIds = _flights.map((f) => f.id).toSet();
      for (final item in result.flights) {
        if (!existingIds.contains(item.id)) {
          _flights.add(item);
          existingIds.add(item.id);
        }
      }

      _pagination = result.pagination;
      if (result.warningMessage != null) {
        _noticeMessage = result.warningMessage;
      }
    } catch (e) {
      _errorMessage = 'Failed to load more: $e';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Change Status Filter Chip (e.g. Active, Scheduled, Landed, Delayed)
  void setStatusFilter(String status) {
    if (_selectedStatus == status) return;
    _selectedStatus = status;
    fetchFlights();
  }

  /// Search with Debounce to prevent unnecessary API calls
  void setSearchQuery(String query) {
    _searchQuery = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchFlights();
    });
  }

  // ==================== CRUD Operations ====================

  /// CREATE: User tracks a new flight manually
  Future<void> createFlight(FlightModel flight) async {
    await repository.createFlight(flight);
    _flights.insert(0, flight);
    notifyListeners();
  }

  /// UPDATE: User edits flight details / adds notes / changes status
  Future<void> updateFlight(FlightModel updatedFlight) async {
    await repository.updateFlight(updatedFlight);
    final index = _flights.indexWhere((f) => f.id == updatedFlight.id);
    if (index != -1) {
      _flights[index] = updatedFlight;
    }
    notifyListeners();
  }

  /// DELETE: User deletes a flight from tracking list
  Future<FlightModel?> deleteFlight(String id) async {
    final index = _flights.indexWhere((f) => f.id == id);
    if (index != -1) {
      final removed = _flights.removeAt(index);
      await repository.deleteFlight(id);
      notifyListeners();
      return removed;
    }
    return null;
  }

  /// Undo Delete (Bonus user convenience)
  Future<void> restoreFlight(FlightModel flight) async {
    await createFlight(flight);
  }

  /// Toggle Favorite / Watchlist
  Future<void> toggleFavorite(String id) async {
    final updated = await repository.toggleFavorite(id);
    if (updated != null) {
      final index = _flights.indexWhere((f) => f.id == id);
      if (index != -1) {
        _flights[index] = updated;
        notifyListeners();
      }
    }
  }

  /// Metrics & Diagnostics
  Future<void> clearCache() async {
    await repository.clearCache();
    await fetchFlights(forceRefresh: true);
  }

  Future<void> resetMetrics() async {
    await repository.resetMetrics();
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}


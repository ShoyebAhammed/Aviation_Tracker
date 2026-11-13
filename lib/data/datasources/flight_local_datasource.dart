import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/flight_model.dart';

class FlightLocalDataSource {
  static const String flightsBoxName = 'flights_cache_v1';
  static const String customFlightsBoxName = 'custom_flights_v1';
  static const String metaBoxName = 'app_meta_v1';

  late Box<String> _flightsBox;
  late Box<String> _customFlightsBox;
  late Box _metaBox;

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    await Hive.initFlutter();
    _flightsBox = await Hive.openBox<String>(flightsBoxName);
    _customFlightsBox = await Hive.openBox<String>(customFlightsBoxName);
    _metaBox = await Hive.openBox(metaBoxName);
    _isInitialized = true;

    // Check if initial seed data is needed
    if (_flightsBox.isEmpty) {
      await loadSeedData();
    }
  }

  /// Load bundled seed JSON data from assets
  Future<List<FlightModel>> loadSeedData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/seed_flights.json');
      final decoded = json.decode(jsonString) as Map<String, dynamic>;
      final list = (decoded['data'] as List<dynamic>? ?? [])
          .map((item) => FlightModel.fromJson(item as Map<String, dynamic>))
          .toList();

      final entries = <String, String>{};
      for (final flight in list) {
        entries[flight.id] = json.encode(flight.toJson());
      }
      await _flightsBox.putAll(entries);
      return list;
    } catch (_) {
      return [];
    }
  }

  /// Cache flights fetched from remote API
  Future<void> cacheFlights(List<FlightModel> flights, {bool clearExisting = false}) async {
    if (clearExisting) {
      await _flightsBox.clear();
    }
    final entries = <String, String>{};
    for (final flight in flights) {
      entries[flight.id] = json.encode(flight.toJson());
    }
    await _flightsBox.putAll(entries);
  }

  /// Retrieve all flights (cached + custom user flights)
  List<FlightModel> getAllFlights() {
    final Map<String, FlightModel> allMap = {};

    // 1. Load cached flights
    for (final key in _flightsBox.keys) {
      final jsonString = _flightsBox.get(key);
      if (jsonString != null) {
        try {
          final model = FlightModel.fromJson(json.decode(jsonString) as Map<String, dynamic>);
          allMap[model.id] = model;
        } catch (_) {}
      }
    }

    // 2. Overlay custom user flights (they have precedence)
    for (final key in _customFlightsBox.keys) {
      final jsonString = _customFlightsBox.get(key);
      if (jsonString != null) {
        try {
          final model = FlightModel.fromJson(json.decode(jsonString) as Map<String, dynamic>);
          allMap[model.id] = model;
        } catch (_) {}
      }
    }

    return allMap.values.toList();
  }

  /// Local pagination simulation for offline / cached data
  List<FlightModel> getPaginatedFlights({
    int offset = 0,
    int limit = 20,
    String? flightStatus,
    String? searchQuery,
  }) {
    var flights = getAllFlights();

    if (flightStatus != null && flightStatus.isNotEmpty && flightStatus != 'all') {
      flights = flights.where((f) => f.flightStatus.toLowerCase() == flightStatus.toLowerCase()).toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      flights = flights.where((f) {
        final fNum = f.flightNumberDisplay.toLowerCase();
        final airline = f.airlineNameDisplay.toLowerCase();
        final depIata = (f.departure.iata ?? '').toLowerCase();
        final arrIata = (f.arrival.iata ?? '').toLowerCase();
        final depCity = (f.departure.airport ?? '').toLowerCase();
        final arrCity = (f.arrival.airport ?? '').toLowerCase();
        return fNum.contains(q) ||
            airline.contains(q) ||
            depIata.contains(q) ||
            arrIata.contains(q) ||
            depCity.contains(q) ||
            arrCity.contains(q);
      }).toList();
    }

    if (offset >= flights.length) return [];
    final end = (offset + limit < flights.length) ? offset + limit : flights.length;
    return flights.sublist(offset, end);
  }

  int getTotalFlightsCount({String? flightStatus, String? searchQuery}) {
    var flights = getAllFlights();
    if (flightStatus != null && flightStatus.isNotEmpty && flightStatus != 'all') {
      flights = flights.where((f) => f.flightStatus.toLowerCase() == flightStatus.toLowerCase()).toList();
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      flights = flights.where((f) {
        final fNum = f.flightNumberDisplay.toLowerCase();
        final airline = f.airlineNameDisplay.toLowerCase();
        final depIata = (f.departure.iata ?? '').toLowerCase();
        final arrIata = (f.arrival.iata ?? '').toLowerCase();
        return fNum.contains(q) || airline.contains(q) || depIata.contains(q) || arrIata.contains(q);
      }).toList();
    }
    return flights.length;
  }

  // ==================== CRUD Operations ====================

  /// CREATE or UPDATE a flight (Custom user flight or modified flight)
  Future<void> saveFlight(FlightModel flight) async {
    final encoded = json.encode(flight.toJson());
    await _customFlightsBox.put(flight.id, encoded);
    // Also update cached box if it was originally there
    if (_flightsBox.containsKey(flight.id)) {
      await _flightsBox.put(flight.id, encoded);
    }
  }

  /// DELETE a flight (CRUD requirement)
  Future<void> deleteFlight(String id) async {
    await _customFlightsBox.delete(id);
    await _flightsBox.delete(id);
  }

  /// Toggle Favorite status
  Future<FlightModel?> toggleFavorite(String id) async {
    FlightModel? flight;
    if (_customFlightsBox.containsKey(id)) {
      final jsonStr = _customFlightsBox.get(id);
      if (jsonStr != null) {
        flight = FlightModel.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
      }
    } else if (_flightsBox.containsKey(id)) {
      final jsonStr = _flightsBox.get(id);
      if (jsonStr != null) {
        flight = FlightModel.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
      }
    }

    if (flight != null) {
      final updated = flight.copyWith(isFavorite: !flight.isFavorite);
      await saveFlight(updated);
      return updated;
    }
    return null;
  }

  // ==================== API Metrics & Counters ====================

  int getApiHits() => _metaBox.get('api_hits', defaultValue: 0) as int;
  int getCacheHits() => _metaBox.get('cache_hits', defaultValue: 0) as int;

  Future<void> incrementApiHits() async {
    final current = getApiHits();
    await _metaBox.put('api_hits', current + 1);
  }

  Future<void> incrementCacheHits() async {
    final current = getCacheHits();
    await _metaBox.put('cache_hits', current + 1);
  }

  Future<void> resetMetrics() async {
    await _metaBox.put('api_hits', 0);
    await _metaBox.put('cache_hits', 0);
  }

  Future<void> clearAllCache() async {
    await _flightsBox.clear();
    await loadSeedData();
  }
}

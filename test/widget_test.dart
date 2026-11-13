import 'package:flutter_test/flutter_test.dart';
import 'package:aviation_tracker/core/utils/date_formatter.dart';
import 'package:aviation_tracker/core/utils/geo_calculator.dart';
import 'package:aviation_tracker/data/models/flight_model.dart';

void main() {
  group('DateFormatter & GeoCalculator Tests', () {
    test('Calculates flight duration correctly', () {
      const dep = '2026-11-13T08:00:00Z';
      const arr = '2026-11-13T12:30:00Z';
      final duration = DateFormatter.formatDuration(
        departureTime: dep,
        arrivalTime: arr,
      );
      expect(duration, '4h 30m');
    });

    test('Calculates great-circle distance between coordinates', () {
      // SFO to JFK
      final distanceKm = GeoCalculator.calculateDistanceKm(
        lat1: 37.6213,
        lon1: -122.3790,
        lat2: 40.6413,
        lon2: -73.7781,
      );
      // SFO to JFK is approx 4150 km
      expect(distanceKm, greaterThan(4000));
      expect(distanceKm, lessThan(4300));
    });
  });

  group('FlightModel Tests', () {
    test('Correctly serializes and deserializes JSON', () {
      final flight = FlightModel(
        id: 'test_123',
        flightStatus: 'active',
        airline: AirlineModel(name: 'Delta Air Lines', iata: 'DL'),
        flight: FlightInfoModel(number: '415', iata: 'DL415'),
        departure: DepartureModel(iata: 'SFO', airport: 'San Francisco Int\'l'),
        arrival: ArrivalModel(iata: 'JFK', airport: 'John F Kennedy Int\'l'),
      );

      final jsonMap = flight.toJson();
      final fromJson = FlightModel.fromJson(jsonMap);

      expect(fromJson.id, 'test_123');
      expect(fromJson.flightNumberDisplay, 'DL415');
      expect(fromJson.departure.iata, 'SFO');
      expect(fromJson.arrival.iata, 'JFK');
      expect(fromJson.flightStatus, 'active');
    });
  });
}

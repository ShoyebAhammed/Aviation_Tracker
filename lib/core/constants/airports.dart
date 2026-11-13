class AirportInfo {
  final String iata;
  final String icao;
  final String name;
  final String city;
  final String country;
  final double latitude;
  final double longitude;

  const AirportInfo({
    required this.iata,
    required this.icao,
    required this.name,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
  });
}

class AirportDatabase {
  static const Map<String, AirportInfo> airports = {
    'SFO': AirportInfo(
      iata: 'SFO',
      icao: 'KSFO',
      name: 'San Francisco International',
      city: 'San Francisco',
      country: 'United States',
      latitude: 37.6213,
      longitude: -122.3790,
    ),
    'JFK': AirportInfo(
      iata: 'JFK',
      icao: 'KJFK',
      name: 'John F. Kennedy International',
      city: 'New York',
      country: 'United States',
      latitude: 40.6413,
      longitude: -73.7781,
    ),
    'LAX': AirportInfo(
      iata: 'LAX',
      icao: 'KLAX',
      name: 'Los Angeles International',
      city: 'Los Angeles',
      country: 'United States',
      latitude: 33.9416,
      longitude: -118.4085,
    ),
    'ORD': AirportInfo(
      iata: 'ORD',
      icao: 'KORD',
      name: 'O\'Hare International',
      city: 'Chicago',
      country: 'United States',
      latitude: 41.9742,
      longitude: -87.9073,
    ),
    'ATL': AirportInfo(
      iata: 'ATL',
      icao: 'KATL',
      name: 'Hartsfield-Jackson Atlanta',
      city: 'Atlanta',
      country: 'United States',
      latitude: 33.6407,
      longitude: -84.4277,
    ),
    'MIA': AirportInfo(
      iata: 'MIA',
      icao: 'KMIA',
      name: 'Miami International',
      city: 'Miami',
      country: 'United States',
      latitude: 25.7959,
      longitude: -80.2870,
    ),
    'EWR': AirportInfo(
      iata: 'EWR',
      icao: 'KEWR',
      name: 'Newark Liberty International',
      city: 'Newark',
      country: 'United States',
      latitude: 40.6895,
      longitude: -74.1745,
    ),
    'LHR': AirportInfo(
      iata: 'LHR',
      icao: 'EGLL',
      name: 'Heathrow Airport',
      city: 'London',
      country: 'United Kingdom',
      latitude: 51.4700,
      longitude: -0.4543,
    ),
    'CDG': AirportInfo(
      iata: 'CDG',
      icao: 'LFPG',
      name: 'Charles de Gaulle Airport',
      city: 'Paris',
      country: 'France',
      latitude: 49.0097,
      longitude: 2.5479,
    ),
    'FRA': AirportInfo(
      iata: 'FRA',
      icao: 'EDDF',
      name: 'Frankfurt Airport',
      city: 'Frankfurt',
      country: 'Germany',
      latitude: 50.0379,
      longitude: 8.5622,
    ),
    'MUC': AirportInfo(
      iata: 'MUC',
      icao: 'EDDM',
      name: 'Munich Airport',
      city: 'Munich',
      country: 'Germany',
      latitude: 48.3537,
      longitude: 11.7860,
    ),
    'AMS': AirportInfo(
      iata: 'AMS',
      icao: 'EHAM',
      name: 'Amsterdam Airport Schiphol',
      city: 'Amsterdam',
      country: 'Netherlands',
      latitude: 52.3105,
      longitude: 4.7683,
    ),
    'ZRH': AirportInfo(
      iata: 'ZRH',
      icao: 'LSZH',
      name: 'Zurich Airport',
      city: 'Zurich',
      country: 'Switzerland',
      latitude: 47.4582,
      longitude: 8.5555,
    ),
    'DXB': AirportInfo(
      iata: 'DXB',
      icao: 'OMDB',
      name: 'Dubai International',
      city: 'Dubai',
      country: 'United Arab Emirates',
      latitude: 25.2532,
      longitude: 55.3657,
    ),
    'DOH': AirportInfo(
      iata: 'DOH',
      icao: 'OTHH',
      name: 'Hamad International',
      city: 'Doha',
      country: 'Qatar',
      latitude: 25.2731,
      longitude: 51.6081,
    ),
    'SIN': AirportInfo(
      iata: 'SIN',
      icao: 'WSSS',
      name: 'Singapore Changi',
      city: 'Singapore',
      country: 'Singapore',
      latitude: 1.3644,
      longitude: 103.9915,
    ),
    'HND': AirportInfo(
      iata: 'HND',
      icao: 'RJTT',
      name: 'Tokyo Haneda Airport',
      city: 'Tokyo',
      country: 'Japan',
      latitude: 35.5494,
      longitude: 139.7798,
    ),
    'NRT': AirportInfo(
      iata: 'NRT',
      icao: 'RJAA',
      name: 'Narita International',
      city: 'Tokyo',
      country: 'Japan',
      latitude: 35.7653,
      longitude: 140.3856,
    ),
    'HKG': AirportInfo(
      iata: 'HKG',
      icao: 'VHHH',
      name: 'Hong Kong International',
      city: 'Hong Kong',
      country: 'Hong Kong',
      latitude: 22.3080,
      longitude: 113.9185,
    ),
    'ICN': AirportInfo(
      iata: 'ICN',
      icao: 'RKSI',
      name: 'Incheon International',
      city: 'Seoul',
      country: 'South Korea',
      latitude: 37.4602,
      longitude: 126.4407,
    ),
    'SYD': AirportInfo(
      iata: 'SYD',
      icao: 'YSSY',
      name: 'Sydney Kingsford Smith',
      city: 'Sydney',
      country: 'Australia',
      latitude: -33.9399,
      longitude: 151.1753,
    ),
  };

  static AirportInfo? findByIata(String? code) {
    if (code == null) return null;
    return airports[code.toUpperCase().trim()];
  }
}


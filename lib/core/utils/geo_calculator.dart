import 'dart:math' as math;

class GeoCalculator {
  static const double earthRadiusKm = 6371.0;
  static const double kmToNauticalMiles = 0.539957;

  /// Calculate Great-Circle distance using Haversine formula (km)
  static double calculateDistanceKm({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Calculate Great-Circle distance in Nautical Miles
  static double calculateDistanceNM({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    return calculateDistanceKm(
          lat1: lat1,
          lon1: lon1,
          lat2: lat2,
          lon2: lon2,
        ) *
        kmToNauticalMiles;
  }

  /// Calculate initial compass bearing from Point A to Point B (0 - 360 degrees)
  static double calculateBearing({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final phi1 = _toRadians(lat1);
    final phi2 = _toRadians(lat2);
    final deltaLambda = _toRadians(lon2 - lon1);

    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    final theta = math.atan2(y, x);
    final bearing = (_toDegrees(theta) + 360.0) % 360.0;
    return bearing;
  }

  /// Intermediate point along Great Circle arc (fraction 0.0 to 1.0)
  static Map<String, double> interpolatePoint({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
    required double fraction,
  }) {
    if (fraction <= 0.0) return {'lat': lat1, 'lon': lon1};
    if (fraction >= 1.0) return {'lat': lat2, 'lon': lon2};

    final phi1 = _toRadians(lat1);
    final lambda1 = _toRadians(lon1);
    final phi2 = _toRadians(lat2);
    final lambda2 = _toRadians(lon2);

    final d = 2 *
        math.asin(math.sqrt(math.pow(math.sin((phi1 - phi2) / 2), 2) +
            math.cos(phi1) *
                math.cos(phi2) *
                math.pow(math.sin((lambda1 - lambda2) / 2), 2)));

    if (d == 0) return {'lat': lat1, 'lon': lon1};

    final a = math.sin((1 - fraction) * d) / math.sin(d);
    final b = math.sin(fraction * d) / math.sin(d);

    final x = a * math.cos(phi1) * math.cos(lambda1) +
        b * math.cos(phi2) * math.cos(lambda2);
    final y = a * math.cos(phi1) * math.sin(lambda1) +
        b * math.cos(phi2) * math.sin(lambda2);
    final z = a * math.sin(phi1) + b * math.sin(phi2);

    final phi = math.atan2(z, math.sqrt(x * x + y * y));
    final lambda = math.atan2(y, x);

    return {
      'lat': _toDegrees(phi),
      'lon': _toDegrees(lambda),
    };
  }

  static double _toRadians(double deg) => deg * (math.pi / 180.0);
  static double _toDegrees(double rad) => rad * (180.0 / math.pi);
}


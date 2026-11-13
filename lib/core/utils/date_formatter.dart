import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('MMM d, h:mm a');

  static String formatTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '--:--';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return _timeFormat.format(dateTime);
    } catch (_) {
      return '--:--';
    }
  }

  static String formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '--';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return _dateFormat.format(dateTime);
    } catch (_) {
      return '--';
    }
  }

  static String formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '--';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return _dateTimeFormat.format(dateTime);
    } catch (_) {
      return '--';
    }
  }

  static String formatDuration({
    required String? departureTime,
    required String? arrivalTime,
  }) {
    if (departureTime == null || arrivalTime == null) return '--';
    try {
      final dep = DateTime.parse(departureTime);
      final arr = DateTime.parse(arrivalTime);
      final diff = arr.difference(dep);
      if (diff.isNegative) return '--';
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      if (hours == 0) return '${minutes}m';
      return '${hours}h ${minutes}m';
    } catch (_) {
      return '--';
    }
  }

  static double calculateFlightProgress({
    required String? departureTime,
    required String? arrivalTime,
  }) {
    if (departureTime == null || arrivalTime == null) return 0.0;
    try {
      final dep = DateTime.parse(departureTime).millisecondsSinceEpoch;
      final arr = DateTime.parse(arrivalTime).millisecondsSinceEpoch;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now <= dep) return 0.0;
      if (now >= arr) return 1.0;
      final total = arr - dep;
      if (total <= 0) return 0.0;
      return (now - dep) / total;
    } catch (_) {
      return 0.0;
    }
  }
}


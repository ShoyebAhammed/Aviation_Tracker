import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FlightModel {
  final String id;
  final String? flightDate;
  final String flightStatus;
  final DepartureModel departure;
  final ArrivalModel arrival;
  final AirlineModel airline;
  final FlightInfoModel flight;
  final AircraftModel? aircraft;
  final LiveModel? live;
  final bool isCustom;
  final bool isFavorite;
  final String? userNotes;
  final String? passengerSeat;

  FlightModel({
    required this.id,
    this.flightDate,
    required this.flightStatus,
    required this.departure,
    required this.arrival,
    required this.airline,
    required this.flight,
    this.aircraft,
    this.live,
    this.isCustom = false,
    this.isFavorite = false,
    this.userNotes,
    this.passengerSeat,
  });

  String get flightNumberDisplay {
    if (flight.iata != null && flight.iata!.isNotEmpty) return flight.iata!;
    if (flight.icao != null && flight.icao!.isNotEmpty) return flight.icao!;
    if (flight.number != null && flight.number!.isNotEmpty) {
      final airlineCode = airline.iata ?? airline.icao ?? '';
      return '$airlineCode ${flight.number}'.trim();
    }
    return 'FL-${id.substring(0, id.length > 5 ? 5 : id.length).toUpperCase()}';
  }

  String get airlineNameDisplay =>
      airline.name != null && airline.name!.isNotEmpty
          ? airline.name!
          : 'Commercial Carrier';

  Color get statusColor {
    switch (flightStatus.toLowerCase()) {
      case 'active':
      case 'en-route':
        return AppColors.statusActive;
      case 'scheduled':
        return AppColors.statusScheduled;
      case 'landed':
        return AppColors.statusLanded;
      case 'delayed':
        return AppColors.statusDelayed;
      case 'cancelled':
        return AppColors.statusCancelled;
      case 'diverted':
      case 'incident':
        return AppColors.statusDiverted;
      default:
        return AppColors.statusUnknown;
    }
  }

  String get statusDisplay {
    switch (flightStatus.toLowerCase()) {
      case 'active':
        return 'In Flight';
      case 'scheduled':
        return 'Scheduled';
      case 'landed':
        return 'Landed';
      case 'delayed':
        return 'Delayed';
      case 'cancelled':
        return 'Cancelled';
      case 'diverted':
        return 'Diverted';
      default:
        return flightStatus.toUpperCase();
    }
  }

  factory FlightModel.fromJson(Map<String, dynamic> json, {String? customId}) {
    final flightObj = json['flight'] is Map<String, dynamic>
        ? FlightInfoModel.fromJson(json['flight'] as Map<String, dynamic>)
        : FlightInfoModel(number: '', iata: '', icao: '');

    final airlineObj = json['airline'] is Map<String, dynamic>
        ? AirlineModel.fromJson(json['airline'] as Map<String, dynamic>)
        : AirlineModel(name: 'Airline');

    final depObj = json['departure'] is Map<String, dynamic>
        ? DepartureModel.fromJson(json['departure'] as Map<String, dynamic>)
        : DepartureModel(airport: 'Unknown Origin');

    final arrObj = json['arrival'] is Map<String, dynamic>
        ? ArrivalModel.fromJson(json['arrival'] as Map<String, dynamic>)
        : ArrivalModel(airport: 'Unknown Destination');

    final aircraftObj = json['aircraft'] is Map<String, dynamic>
        ? AircraftModel.fromJson(json['aircraft'] as Map<String, dynamic>)
        : null;

    final liveObj = json['live'] is Map<String, dynamic>
        ? LiveModel.fromJson(json['live'] as Map<String, dynamic>)
        : null;

    final generatedId = customId ??
        json['id']?.toString() ??
        '${flightObj.iata ?? flightObj.icao ?? flightObj.number}_${json['flight_date'] ?? DateTime.now().millisecondsSinceEpoch}';

    return FlightModel(
      id: generatedId,
      flightDate: json['flight_date'] as String?,
      flightStatus: (json['flight_status'] as String? ?? 'scheduled').toLowerCase(),
      departure: depObj,
      arrival: arrObj,
      airline: airlineObj,
      flight: flightObj,
      aircraft: aircraftObj,
      live: liveObj,
      isCustom: json['is_custom'] as bool? ?? false,
      isFavorite: json['is_favorite'] as bool? ?? false,
      userNotes: json['user_notes'] as String?,
      passengerSeat: json['passenger_seat'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'flight_date': flightDate,
      'flight_status': flightStatus,
      'departure': departure.toJson(),
      'arrival': arrival.toJson(),
      'airline': airline.toJson(),
      'flight': flight.toJson(),
      'aircraft': aircraft?.toJson(),
      'live': live?.toJson(),
      'is_custom': isCustom,
      'is_favorite': isFavorite,
      'user_notes': userNotes,
      'passenger_seat': passengerSeat,
    };
  }

  FlightModel copyWith({
    String? id,
    String? flightDate,
    String? flightStatus,
    DepartureModel? departure,
    ArrivalModel? arrival,
    AirlineModel? airline,
    FlightInfoModel? flight,
    AircraftModel? aircraft,
    LiveModel? live,
    bool? isCustom,
    bool? isFavorite,
    String? userNotes,
    String? passengerSeat,
  }) {
    return FlightModel(
      id: id ?? this.id,
      flightDate: flightDate ?? this.flightDate,
      flightStatus: flightStatus ?? this.flightStatus,
      departure: departure ?? this.departure,
      arrival: arrival ?? this.arrival,
      airline: airline ?? this.airline,
      flight: flight ?? this.flight,
      aircraft: aircraft ?? this.aircraft,
      live: live ?? this.live,
      isCustom: isCustom ?? this.isCustom,
      isFavorite: isFavorite ?? this.isFavorite,
      userNotes: userNotes ?? this.userNotes,
      passengerSeat: passengerSeat ?? this.passengerSeat,
    );
  }
}

class DepartureModel {
  final String? airport;
  final String? timezone;
  final String? iata;
  final String? icao;
  final String? terminal;
  final String? gate;
  final int? delay;
  final String? scheduled;
  final String? estimated;
  final String? actual;
  final String? estimatedRunway;
  final String? actualRunway;

  DepartureModel({
    this.airport,
    this.timezone,
    this.iata,
    this.icao,
    this.terminal,
    this.gate,
    this.delay,
    this.scheduled,
    this.estimated,
    this.actual,
    this.estimatedRunway,
    this.actualRunway,
  });

  String get code => iata ?? icao ?? 'DEP';

  factory DepartureModel.fromJson(Map<String, dynamic> json) {
    return DepartureModel(
      airport: json['airport'] as String?,
      timezone: json['timezone'] as String?,
      iata: json['iata'] as String?,
      icao: json['icao'] as String?,
      terminal: json['terminal']?.toString(),
      gate: json['gate']?.toString(),
      delay: json['delay'] as int?,
      scheduled: json['scheduled'] as String?,
      estimated: json['estimated'] as String?,
      actual: json['actual'] as String?,
      estimatedRunway: json['estimated_runway'] as String?,
      actualRunway: json['actual_runway'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'airport': airport,
      'timezone': timezone,
      'iata': iata,
      'icao': icao,
      'terminal': terminal,
      'gate': gate,
      'delay': delay,
      'scheduled': scheduled,
      'estimated': estimated,
      'actual': actual,
      'estimated_runway': estimatedRunway,
      'actual_runway': actualRunway,
    };
  }
}

class ArrivalModel {
  final String? airport;
  final String? timezone;
  final String? iata;
  final String? icao;
  final String? terminal;
  final String? gate;
  final String? baggage;
  final int? delay;
  final String? scheduled;
  final String? estimated;
  final String? actual;
  final String? estimatedRunway;
  final String? actualRunway;

  ArrivalModel({
    this.airport,
    this.timezone,
    this.iata,
    this.icao,
    this.terminal,
    this.gate,
    this.baggage,
    this.delay,
    this.scheduled,
    this.estimated,
    this.actual,
    this.estimatedRunway,
    this.actualRunway,
  });

  String get code => iata ?? icao ?? 'ARR';

  factory ArrivalModel.fromJson(Map<String, dynamic> json) {
    return ArrivalModel(
      airport: json['airport'] as String?,
      timezone: json['timezone'] as String?,
      iata: json['iata'] as String?,
      icao: json['icao'] as String?,
      terminal: json['terminal']?.toString(),
      gate: json['gate']?.toString(),
      baggage: json['baggage']?.toString(),
      delay: json['delay'] as int?,
      scheduled: json['scheduled'] as String?,
      estimated: json['estimated'] as String?,
      actual: json['actual'] as String?,
      estimatedRunway: json['estimated_runway'] as String?,
      actualRunway: json['actual_runway'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'airport': airport,
      'timezone': timezone,
      'iata': iata,
      'icao': icao,
      'terminal': terminal,
      'gate': gate,
      'baggage': baggage,
      'delay': delay,
      'scheduled': scheduled,
      'estimated': estimated,
      'actual': actual,
      'estimated_runway': estimatedRunway,
      'actual_runway': actualRunway,
    };
  }
}

class AirlineModel {
  final String? name;
  final String? iata;
  final String? icao;

  AirlineModel({this.name, this.iata, this.icao});

  factory AirlineModel.fromJson(Map<String, dynamic> json) {
    return AirlineModel(
      name: json['name'] as String?,
      iata: json['iata'] as String?,
      icao: json['icao'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'iata': iata, 'icao': icao};
}

class FlightInfoModel {
  final String? number;
  final String? iata;
  final String? icao;

  FlightInfoModel({this.number, this.iata, this.icao});

  factory FlightInfoModel.fromJson(Map<String, dynamic> json) {
    return FlightInfoModel(
      number: json['number']?.toString(),
      iata: json['iata'] as String?,
      icao: json['icao'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'number': number, 'iata': iata, 'icao': icao};
}

class AircraftModel {
  final String? registration;
  final String? iata;
  final String? icao;
  final String? icao24;

  AircraftModel({this.registration, this.iata, this.icao, this.icao24});

  factory AircraftModel.fromJson(Map<String, dynamic> json) {
    return AircraftModel(
      registration: json['registration'] as String?,
      iata: json['iata'] as String?,
      icao: json['icao'] as String?,
      icao24: json['icao24'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'registration': registration,
        'iata': iata,
        'icao': icao,
        'icao24': icao24,
      };
}

class LiveModel {
  final String? updated;
  final double? latitude;
  final double? longitude;
  final double? altitude;
  final double? direction;
  final double? speedHorizontal;
  final double? speedVertical;
  final bool? isGround;

  LiveModel({
    this.updated,
    this.latitude,
    this.longitude,
    this.altitude,
    this.direction,
    this.speedHorizontal,
    this.speedVertical,
    this.isGround,
  });

  factory LiveModel.fromJson(Map<String, dynamic> json) {
    return LiveModel(
      updated: json['updated'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      direction: (json['direction'] as num?)?.toDouble(),
      speedHorizontal: (json['speed_horizontal'] as num?)?.toDouble(),
      speedVertical: (json['speed_vertical'] as num?)?.toDouble(),
      isGround: json['is_ground'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'updated': updated,
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitude,
        'direction': direction,
        'speed_horizontal': speedHorizontal,
        'speed_vertical': speedVertical,
        'is_ground': isGround,
      };
}


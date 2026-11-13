import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/airports.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/geo_calculator.dart';
import '../../data/models/flight_model.dart';

class WorldFlightMapView extends StatefulWidget {
  final FlightModel flight;
  final double height;
  final bool interactive;

  const WorldFlightMapView({
    super.key,
    required this.flight,
    this.height = 360,
    this.interactive = true,
  });

  @override
  State<WorldFlightMapView> createState() => _WorldFlightMapViewState();
}

class _WorldFlightMapViewState extends State<WorldFlightMapView>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late final AnimationController _pulseController;
  bool _isSatellite = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant WorldFlightMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.flight.id != widget.flight.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitRouteBounds());
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _fitRouteBounds() {
    final depAirport = AirportDatabase.findByIata(widget.flight.departure.iata);
    final arrAirport = AirportDatabase.findByIata(widget.flight.arrival.iata);

    final depLat = depAirport?.latitude ?? 37.6213;
    final depLon = depAirport?.longitude ?? -122.3790;
    final arrLat = arrAirport?.latitude ?? 40.6413;
    final arrLon = arrAirport?.longitude ?? -73.7781;

    final bounds = LatLngBounds.fromPoints([
      LatLng(depLat, depLon),
      LatLng(arrLat, arrLon),
    ]);

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 60),
        maxZoom: 9.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 1. Resolve coordinates
    final depAirport = AirportDatabase.findByIata(widget.flight.departure.iata);
    final arrAirport = AirportDatabase.findByIata(widget.flight.arrival.iata);

    final depLat = depAirport?.latitude ?? 37.6213;
    final depLon = depAirport?.longitude ?? -122.3790;
    final arrLat = arrAirport?.latitude ?? 40.6413;
    final arrLon = arrAirport?.longitude ?? -73.7781;

    // 2. Resolve aircraft position
    double planeLat = depLat;
    double planeLon = depLon;
    final status = widget.flight.flightStatus.toLowerCase();

    if (widget.flight.live?.latitude != null && widget.flight.live?.longitude != null) {
      planeLat = widget.flight.live!.latitude!;
      planeLon = widget.flight.live!.longitude!;
    } else {
      double frac = 0.5;
      if (status == 'landed') frac = 1.0;
      if (status == 'scheduled' || status == 'cancelled') frac = 0.0;
      final interp = GeoCalculator.interpolatePoint(
        lat1: depLat,
        lon1: depLon,
        lat2: arrLat,
        lon2: arrLon,
        fraction: frac,
      );
      planeLat = interp['lat'] ?? depLat;
      planeLon = interp['lon'] ?? depLon;
    }

    final distanceKm = GeoCalculator.calculateDistanceKm(
      lat1: depLat,
      lon1: depLon,
      lat2: arrLat,
      lon2: arrLon,
    );
    final distanceNM = distanceKm * GeoCalculator.kmToNauticalMiles;
    final bearing = widget.flight.live?.direction ??
        GeoCalculator.calculateBearing(
          lat1: planeLat,
          lon1: planeLon,
          lat2: arrLat,
          lon2: arrLon,
        );

    // 3. Compute Great-Circle Arc Geodesic Points for realistic flight trajectory
    final routePoints = <LatLng>[];
    const int stepCount = 50;
    for (int i = 0; i <= stepCount; i++) {
      final frac = i / stepCount;
      final pt = GeoCalculator.interpolatePoint(
        lat1: depLat,
        lon1: depLon,
        lat2: arrLat,
        lon2: arrLon,
        fraction: frac,
      );
      routePoints.add(LatLng(pt['lat']!, pt['lon']!));
    }

    // Midpoint for initial center
    final midLat = (depLat + arrLat) / 2;
    final midLon = (depLon + arrLon) / 2;

    // Tile URL selection: CartoDB Dark Matter / Voyager
    final tileUrl = _isSatellite
        ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
        : (isDark
            ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
            : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png');

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF070B14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.radarCyan.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.radarCyan.withValues(alpha: 0.1),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Real Interactive World Map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(midLat, midLon),
                initialZoom: 4.0,
                minZoom: 1.5,
                maxZoom: 16.0,
                interactionOptions: InteractionOptions(
                  flags: widget.interactive ? InteractiveFlag.all : InteractiveFlag.none,
                ),
                onMapReady: () {
                  _fitRouteBounds();
                },
              ),
              children: [
                // World Map Tiles
                TileLayer(
                  urlTemplate: tileUrl,
                  subdomains: _isSatellite ? const [] : const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.shoyeb.aviationtracker',
                ),

                // Great Circle Geodesic Trajectory Line
                PolylineLayer(
                  polylines: [
                    // Glow background line
                    Polyline(
                      points: routePoints,
                      strokeWidth: 6.0,
                      color: widget.flight.statusColor.withValues(alpha: 0.3),
                    ),
                    // Core active route line
                    Polyline(
                      points: routePoints,
                      strokeWidth: 2.8,
                      color: widget.flight.statusColor,
                    ),
                  ],
                ),

                // Map Markers
                MarkerLayer(
                  markers: [
                    // 1. Departure Airport Marker
                    Marker(
                      point: LatLng(depLat, depLon),
                      width: 70,
                      height: 52,
                      alignment: Alignment.center,
                      child: _buildAirportMarker(
                        code: widget.flight.departure.code,
                        color: AppColors.primaryBlue,
                        isOrigin: true,
                      ),
                    ),

                    // 2. Arrival Airport Marker
                    Marker(
                      point: LatLng(arrLat, arrLon),
                      width: 70,
                      height: 52,
                      alignment: Alignment.center,
                      child: _buildAirportMarker(
                        code: widget.flight.arrival.code,
                        color: AppColors.radarGreen,
                        isOrigin: false,
                      ),
                    ),

                    // 3. Live Aircraft Position Marker
                    Marker(
                      point: LatLng(planeLat, planeLon),
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, _) {
                          return _buildAircraftMarker(
                            heading: bearing,
                            color: widget.flight.statusColor,
                            pulse: _pulseController.value,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Top Status Bar & Map Controls
            Positioned(
              top: 12,
              left: 14,
              right: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C1425).withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.radarCyan.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.radarGreen,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'GLOBAL RADAR • HDG ${bearing.toStringAsFixed(0).padLeft(3, '0')}°',
                          style: const TextStyle(
                            color: AppColors.radarCyan,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quick Action Buttons (Fit Route & Satellite Toggle)
                  Row(
                    children: [
                      _iconButton(
                        icon: _isSatellite ? Icons.map_outlined : Icons.satellite_alt_outlined,
                        tooltip: _isSatellite ? 'Dark Map' : 'Satellite View',
                        onTap: () => setState(() => _isSatellite = !_isSatellite),
                      ),
                      const SizedBox(width: 6),
                      _iconButton(
                        icon: Icons.center_focus_strong,
                        tooltip: 'Fit Route',
                        onTap: _fitRouteBounds,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Zoom Controls on Right
            Positioned(
              right: 14,
              top: 60,
              child: Column(
                children: [
                  _zoomButton(Icons.add, () {
                    final z = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, z + 1);
                  }),
                  const SizedBox(height: 4),
                  _zoomButton(Icons.remove, () {
                    final z = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, z - 1);
                  }),
                ],
              ),
            ),

            // Bottom Telemetry HUD
            Positioned(
              bottom: 12,
              left: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C1425).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _hudItem(
                      label: 'ALTITUDE',
                      value: widget.flight.live?.altitude != null
                          ? '${(widget.flight.live!.altitude! * 3.28084).toStringAsFixed(0)} FT'
                          : (status == 'active' ? '36,000 FT' : 'GROUND'),
                    ),
                    _verticalDivider(),
                    _hudItem(
                      label: 'GROUND SPEED',
                      value: widget.flight.live?.speedHorizontal != null
                          ? '${widget.flight.live!.speedHorizontal!.toStringAsFixed(0)} KM/H'
                          : (status == 'active' ? '880 KM/H' : '0 KM/H'),
                    ),
                    _verticalDivider(),
                    _hudItem(
                      label: 'DISTANCE',
                      value: '${distanceNM.toStringAsFixed(0)} NM',
                      highlight: true,
                    ),
                    _verticalDivider(),
                    _hudItem(
                      label: 'ROUTE',
                      value: '${widget.flight.departure.code} → ${widget.flight.arrival.code}',
                      highlight: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAirportMarker({
    required String code,
    required Color color,
    required bool isOrigin,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
          decoration: BoxDecoration(
            color: const Color(0xFF080D1A).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 6,
              ),
            ],
          ),
          child: Text(
            code,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildAircraftMarker({
    required double heading,
    required Color color,
    required double pulse,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Expanding radar pulse ring
        Container(
          width: 18 + (pulse * 26),
          height: 18 + (pulse * 26),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: (1.0 - pulse) * 0.7),
              width: 1.5,
            ),
          ),
        ),
        // Glow circle behind plane
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF080D1A).withValues(alpha: 0.9),
            border: Border.all(color: color, width: 1.8),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
          child: Transform.rotate(
            // Rotate towards aircraft heading
            angle: (heading - 90) * (math.pi / 180),
            child: const Icon(
              Icons.flight,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1425).withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.radarCyan.withValues(alpha: 0.35)),
        ),
        child: Icon(icon, size: 14, color: AppColors.radarCyan),
      ),
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFF0C1425).withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Icon(icon, size: 16, color: Colors.white70),
      ),
    );
  }

  Widget _hudItem({
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.white54,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: highlight ? AppColors.radarCyan : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 22,
      width: 1,
      color: Colors.white12,
    );
  }
}

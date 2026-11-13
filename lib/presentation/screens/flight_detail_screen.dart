import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/flight_model.dart';
import '../providers/flight_provider.dart';
import '../widgets/boarding_pass_card.dart';
import '../widgets/flight_route_progress.dart';
import '../widgets/radar_map_view.dart';
import '../widgets/status_badge.dart';
import 'add_edit_flight_screen.dart';

class FlightDetailScreen extends StatefulWidget {
  final FlightModel flight;

  const FlightDetailScreen({super.key, required this.flight});

  @override
  State<FlightDetailScreen> createState() => _FlightDetailScreenState();
}

class _FlightDetailScreenState extends State<FlightDetailScreen> {
  bool _showBoardingPass = false;

  @override
  Widget build(BuildContext context) {
    // Watch flight from provider in case it gets updated/edited
    final provider = context.watch<FlightProvider>();
    final currentFlight = provider.flights.firstWhere(
      (f) => f.id == widget.flight.id,
      orElse: () => widget.flight,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentFlight.flightNumberDisplay),
        actions: [
          IconButton(
            icon: Icon(
              currentFlight.isFavorite ? Icons.star : Icons.star_border,
              color: currentFlight.isFavorite ? Colors.amber : null,
            ),
            onPressed: () {
              provider.toggleFavorite(currentFlight.id);
            },
            tooltip: 'Favorite',
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditFlightScreen(flight: currentFlight),
                ),
              );
            },
            tooltip: 'Edit Flight',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.statusCancelled),
            onPressed: () => _confirmDelete(context, currentFlight),
            tooltip: 'Delete Flight',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Airline & Status Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentFlight.airlineNameDisplay,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                    ),
                    Text(
                      'Date: ${DateFormatter.formatDate(currentFlight.flightDate ?? currentFlight.departure.scheduled)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                      ),
                    ),
                  ],
                ),
                StatusBadge(
                  status: currentFlight.statusDisplay,
                  color: currentFlight.statusColor,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Route Progress Bar Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: FlightRouteProgress(flight: currentFlight, isExpanded: true),
          ),

          const SizedBox(height: 16),

          // Mode Switcher: Radar Map vs Boarding Pass Ticket
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: !_showBoardingPass
                          ? (isDark ? AppColors.radarCyan.withValues(alpha: 0.15) : AppColors.primaryBlue.withValues(alpha: 0.1))
                          : null,
                      side: BorderSide(
                        color: !_showBoardingPass ? AppColors.radarCyan : (isDark ? AppColors.darkBorder : Colors.grey.shade300),
                      ),
                    ),
                    onPressed: () => setState(() => _showBoardingPass = false),
                    icon: const Icon(Icons.public, size: 18),
                    label: const Text('Live World Map'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _showBoardingPass
                          ? (isDark ? AppColors.radarCyan.withValues(alpha: 0.15) : AppColors.primaryBlue.withValues(alpha: 0.1))
                          : null,
                      side: BorderSide(
                        color: _showBoardingPass ? AppColors.radarCyan : (isDark ? AppColors.darkBorder : Colors.grey.shade300),
                      ),
                    ),
                    onPressed: () => setState(() => _showBoardingPass = true),
                    icon: const Icon(Icons.confirmation_number_outlined, size: 18),
                    label: const Text('Boarding Pass'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Conditional Render: World Map View or Boarding Pass Card
          if (_showBoardingPass)
            BoardingPassCard(flight: currentFlight)
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: WorldFlightMapView(flight: currentFlight, height: 320),
            ),

          const SizedBox(height: 16),

          // Origin & Destination Full Details Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Departure Card
                Expanded(
                  child: _airportDetailCard(
                    title: 'DEPARTURE',
                    code: currentFlight.departure.code,
                    airport: currentFlight.departure.airport ?? 'Origin Airport',
                    terminal: currentFlight.departure.terminal,
                    gate: currentFlight.departure.gate,
                    scheduledTime: currentFlight.departure.scheduled,
                    actualTime: currentFlight.departure.actual ?? currentFlight.departure.estimated,
                    delayMinutes: currentFlight.departure.delay,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                // Arrival Card
                Expanded(
                  child: _airportDetailCard(
                    title: 'ARRIVAL',
                    code: currentFlight.arrival.code,
                    airport: currentFlight.arrival.airport ?? 'Destination Airport',
                    terminal: currentFlight.arrival.terminal,
                    gate: currentFlight.arrival.gate,
                    baggage: currentFlight.arrival.baggage,
                    scheduledTime: currentFlight.arrival.scheduled,
                    actualTime: currentFlight.arrival.estimated ?? currentFlight.arrival.actual,
                    delayMinutes: currentFlight.arrival.delay,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Aircraft Specifications Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.airplanemode_active, size: 18, color: AppColors.radarCyan),
                        SizedBox(width: 8),
                        Text(
                          'Aircraft Specifications',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoColumn('MODEL', currentFlight.aircraft?.iata ?? currentFlight.aircraft?.icao ?? 'Boeing / Airbus'),
                        _infoColumn('REGISTRATION', currentFlight.aircraft?.registration ?? 'N/A'),
                        _infoColumn('TRANSPONDER', currentFlight.aircraft?.icao24 ?? 'N/A'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // User Notes Card if exists
          if (currentFlight.userNotes != null && currentFlight.userNotes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: isDark ? AppColors.darkSurface : Colors.amber.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.note_alt_outlined, size: 18, color: Colors.amber),
                          SizedBox(width: 8),
                          Text(
                            'Personal Notes & Reminders',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentFlight.userNotes!,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _airportDetailCard({
    required String title,
    required String code,
    required String airport,
    String? terminal,
    String? gate,
    String? baggage,
    String? scheduledTime,
    String? actualTime,
    int? delayMinutes,
    required bool isDark,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              code,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            Text(
              airport,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
              ),
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _miniInfo('Terminal', terminal ?? '--'),
                _miniInfo('Gate', gate ?? '--'),
                if (baggage != null) _miniInfo('Baggage', baggage),
              ],
            ),
            const SizedBox(height: 8),
            _miniInfo('Scheduled', DateFormatter.formatTime(scheduledTime)),
            if (actualTime != null)
              _miniInfo('Estimated/Actual', DateFormatter.formatTime(actualTime)),
            if (delayMinutes != null && delayMinutes > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Delayed by ${delayMinutes}m',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.statusDelayed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _miniInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, FlightModel flight) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Flight'),
        content: Text('Are you sure you want to stop tracking ${flight.flightNumberDisplay}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.statusCancelled),
            onPressed: () {
              context.read<FlightProvider>().deleteFlight(flight.id);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${flight.flightNumberDisplay} removed from tracking'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      context.read<FlightProvider>().restoreFlight(flight);
                    },
                  ),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}


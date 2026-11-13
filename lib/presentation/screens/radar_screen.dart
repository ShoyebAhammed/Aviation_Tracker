import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/flight_provider.dart';
import '../widgets/radar_map_view.dart';
import 'flight_detail_screen.dart';

class RadarScreen extends StatefulWidget {
  const RadarScreen({super.key});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final flightProvider = context.watch<FlightProvider>();
    final flights = flightProvider.flights;

    if (flights.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Live World Flight Map')),
        body: const Center(child: Text('No active flights found for map tracking.')),
      );
    }

    final safeIndex = _selectedIndex.clamp(0, flights.length - 1);
    final activeFlight = flights[safeIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.public, color: AppColors.radarCyan, size: 22),
            SizedBox(width: 8),
            Text('Live World Flight Map'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Aircraft Selector Carousel Chips
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: flights.length,
              itemBuilder: (context, i) {
                final f = flights[i];
                final isSelected = i == safeIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('${f.flightNumberDisplay} (${f.departure.code}→${f.arrival.code})'),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedIndex = i),
                    selectedColor: AppColors.radarCyan.withValues(alpha: 0.25),
                  ),
                );
              },
            ),
          ),

          // Large Interactive Vector World Map
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: WorldFlightMapView(
                flight: activeFlight,
                height: double.infinity,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Flight Quick Action / Telemetry Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: activeFlight.statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.flight, color: activeFlight.statusColor),
                ),
                title: Text(
                  '${activeFlight.flightNumberDisplay} • ${activeFlight.airlineNameDisplay}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Route: ${activeFlight.departure.airport ?? activeFlight.departure.code} → ${activeFlight.arrival.airport ?? activeFlight.arrival.code}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FlightDetailScreen(flight: activeFlight),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

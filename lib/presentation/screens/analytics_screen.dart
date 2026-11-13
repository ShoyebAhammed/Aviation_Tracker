import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/flight_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flightProvider = context.watch<FlightProvider>();
    final flights = flightProvider.flights;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Status counts
    int activeCount = 0;
    int scheduledCount = 0;
    int landedCount = 0;
    int delayedCount = 0;
    int otherCount = 0;

    // Delays
    int onTimeCount = 0;
    int minorDelayCount = 0;
    int majorDelayCount = 0;

    for (final f in flights) {
      final st = f.flightStatus.toLowerCase();
      if (st == 'active' || st == 'en-route') {
        activeCount++;
      } else if (st == 'scheduled') {
        scheduledCount++;
      } else if (st == 'landed') {
        landedCount++;
      } else if (st == 'delayed') {
        delayedCount++;
      } else {
        otherCount++;
      }

      final delay = f.departure.delay ?? f.arrival.delay ?? 0;
      if (delay <= 5) {
        onTimeCount++;
      } else if (delay <= 30) {
        minorDelayCount++;
      } else {
        majorDelayCount++;
      }
    }

    final total = flights.isEmpty ? 1 : flights.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aviation Analytics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Fleet Metric Counters
          Row(
            children: [
              _metricTile('ACTIVE', '$activeCount', AppColors.statusActive, Icons.flight_takeoff, isDark),
              const SizedBox(width: 8),
              _metricTile('SCHEDULED', '$scheduledCount', AppColors.statusScheduled, Icons.schedule, isDark),
              const SizedBox(width: 8),
              _metricTile('LANDED', '$landedCount', AppColors.statusLanded, Icons.flight_land, isDark),
              const SizedBox(width: 8),
              _metricTile('DELAYED', '$delayedCount', AppColors.statusDelayed, Icons.timer_off_outlined, isDark),
            ],
          ),

          const SizedBox(height: 20),

          // Donut Chart: Flight Status Distribution
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.pie_chart_outline, size: 20, color: AppColors.radarCyan),
                      SizedBox(width: 8),
                      Text(
                        'Flight Status Breakdown',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: flights.isEmpty
                        ? const Center(child: Text('No flight data available'))
                        : PieChart(
                            PieChartData(
                              sectionsSpace: 3,
                              centerSpaceRadius: 46,
                              sections: [
                                if (activeCount > 0)
                                  PieChartSectionData(
                                    value: activeCount.toDouble(),
                                    title: '${((activeCount / total) * 100).toInt()}%',
                                    color: AppColors.statusActive,
                                    radius: 45,
                                    titleStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                                if (scheduledCount > 0)
                                  PieChartSectionData(
                                    value: scheduledCount.toDouble(),
                                    title: '${((scheduledCount / total) * 100).toInt()}%',
                                    color: AppColors.statusScheduled,
                                    radius: 45,
                                    titleStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                                if (landedCount > 0)
                                  PieChartSectionData(
                                    value: landedCount.toDouble(),
                                    title: '${((landedCount / total) * 100).toInt()}%',
                                    color: AppColors.statusLanded,
                                    radius: 45,
                                    titleStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                                if (delayedCount > 0)
                                  PieChartSectionData(
                                    value: delayedCount.toDouble(),
                                    title: '${((delayedCount / total) * 100).toInt()}%',
                                    color: AppColors.statusDelayed,
                                    radius: 45,
                                    titleStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                if (otherCount > 0)
                                  PieChartSectionData(
                                    value: otherCount.toDouble(),
                                    title: '${((otherCount / total) * 100).toInt()}%',
                                    color: AppColors.statusCancelled,
                                    radius: 45,
                                    titleStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _legendItem('Active', AppColors.statusActive),
                      _legendItem('Scheduled', AppColors.statusScheduled),
                      _legendItem('Landed', AppColors.statusLanded),
                      _legendItem('Delayed', AppColors.statusDelayed),
                      _legendItem('Cancelled/Diverted', AppColors.statusCancelled),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Bar Chart: Punctuality & Delay Analysis
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bar_chart, size: 20, color: AppColors.radarCyan),
                      SizedBox(width: 8),
                      Text(
                        'Punctuality & Delay Analysis',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (total + 2).toDouble(),
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                switch (val.toInt()) {
                                  case 0:
                                    return const Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text('On-Time', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                    );
                                  case 1:
                                    return const Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text('1-30m Delay', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                    );
                                  case 2:
                                    return const Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text('>30m Delay', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                    );
                                  default:
                                    return const SizedBox.shrink();
                                }
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: onTimeCount.toDouble(),
                                color: AppColors.radarGreen,
                                width: 22,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: minorDelayCount.toDouble(),
                                color: AppColors.statusDelayed,
                                width: 22,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 2,
                            barRods: [
                              BarChartRodData(
                                toY: majorDelayCount.toDouble(),
                                color: AppColors.statusCancelled,
                                width: 22,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Live Fleet Telemetry Insights
          Card(
            color: isDark ? AppColors.darkSurface : Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.flight_takeoff, color: AppColors.radarCyan),
                      SizedBox(width: 8),
                      Text(
                        'Live Fleet Telemetry & Performance',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statCounter('ON-TIME RATE', '${((onTimeCount / total) * 100).toInt()}%', AppColors.radarGreen),
                      _statCounter('AVG ALTITUDE', '36,000 FT', AppColors.radarCyan),
                      _statCounter('AVG SPEED', '885 KM/H', AppColors.primaryBlue),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _metricTile(String label, String count, Color color, IconData icon, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              count,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _statCounter(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ],
    );
  }
}


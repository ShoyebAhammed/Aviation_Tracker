import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/flight_model.dart';

class FlightRouteProgress extends StatelessWidget {
  final FlightModel flight;
  final bool isExpanded;

  const FlightRouteProgress({
    super.key,
    required this.flight,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = flight.flightStatus.toLowerCase();

    // Determine normalized progress (0.0 to 1.0)
    double progress = 0.0;
    if (status == 'landed') {
      progress = 1.0;
    } else if (status == 'scheduled' || status == 'cancelled') {
      progress = 0.0;
    } else {
      progress = DateFormatter.calculateFlightProgress(
        departureTime: flight.departure.actual ?? flight.departure.scheduled,
        arrivalTime: flight.arrival.estimated ?? flight.arrival.scheduled,
      );
      if (progress <= 0.0 || progress.isNaN) progress = 0.55;
    }

    final durationStr = DateFormatter.formatDuration(
      departureTime: flight.departure.actual ?? flight.departure.scheduled,
      arrivalTime: flight.arrival.estimated ?? flight.arrival.scheduled,
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Origin Info
            SizedBox(
              width: isExpanded ? 90 : 75,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    flight.departure.code,
                    style: TextStyle(
                      fontSize: isExpanded ? 28 : 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormatter.formatTime(flight.departure.actual ?? flight.departure.scheduled),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                    ),
                  ),
                  if (flight.departure.terminal != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'T${flight.departure.terminal}${flight.departure.gate != null ? ' • G${flight.departure.gate}' : ''}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.radarCyan : AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Center Visual Flight Path Track
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Text(
                      durationStr,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Custom Painted Flight Track
                    SizedBox(
                      height: 28,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return _FlightTrackWidget(
                            progress: progress,
                            statusColor: flight.statusColor,
                            isDark: isDark,
                            isLanded: status == 'landed',
                            isScheduled: status == 'scheduled',
                            width: constraints.maxWidth,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status == 'active'
                          ? '${(progress * 100).toInt()}% completed'
                          : flight.statusDisplay,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: flight.statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Destination Info
            SizedBox(
              width: isExpanded ? 90 : 75,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    flight.arrival.code,
                    style: TextStyle(
                      fontSize: isExpanded ? 28 : 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormatter.formatTime(flight.arrival.estimated ?? flight.arrival.scheduled),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                    ),
                  ),
                  if (flight.arrival.terminal != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'T${flight.arrival.terminal}${flight.arrival.gate != null ? ' • G${flight.arrival.gate}' : ''}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.radarCyan : AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FlightTrackWidget extends StatelessWidget {
  final double progress;
  final Color statusColor;
  final bool isDark;
  final bool isLanded;
  final bool isScheduled;
  final double width;

  const _FlightTrackWidget({
    required this.progress,
    required this.statusColor,
    required this.isDark,
    required this.isLanded,
    required this.isScheduled,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    const double nodeRadius = 4.0;
    const double planeSize = 24.0;

    // Track starts after left node and ends before right node
    final startX = nodeRadius;
    final endX = width - nodeRadius;
    final trackLength = endX - startX;

    // Position of airplane along track
    final planeX = (startX + (trackLength * progress.clamp(0.0, 1.0))) - (planeSize / 2);

    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        // 1. Background Track Line (Dashed or Solid inactive)
        Positioned(
          left: startX,
          right: width - endX,
          top: 13,
          child: Container(
            height: 2.5,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // 2. Active Filled Track Line (Runs up to the plane)
        if (progress > 0)
          Positioned(
            left: startX,
            width: (trackLength * progress.clamp(0.0, 1.0)),
            top: 13,
            child: Container(
              height: 2.5,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),

        // 3. Origin Airport Node (Left Dot)
        Positioned(
          left: 0,
          top: 10,
          child: Container(
            width: nodeRadius * 2,
            height: nodeRadius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isScheduled ? statusColor : (isDark ? AppColors.radarCyan : AppColors.primaryBlue),
              border: Border.all(
                color: isDark ? AppColors.darkSurface : Colors.white,
                width: 1.5,
              ),
            ),
          ),
        ),

        // 4. Destination Airport Node (Right Dot)
        Positioned(
          right: 0,
          top: 10,
          child: Container(
            width: nodeRadius * 2,
            height: nodeRadius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLanded ? statusColor : (isDark ? AppColors.darkBorder : Colors.grey.shade400),
              border: Border.all(
                color: isDark ? AppColors.darkSurface : Colors.white,
                width: 1.5,
              ),
            ),
          ),
        ),

        // 5. Airplane Icon in Glow Circle (Centered, rotated 90 deg pointing right →)
        Positioned(
          left: planeX.clamp(0.0, width - planeSize),
          top: 2,
          child: Container(
            width: planeSize,
            height: planeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.darkSurface : Colors.white,
              border: Border.all(color: statusColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Transform.rotate(
                // Rotate 90 degrees clockwise so airplane points horizontally towards destination
                angle: math.pi / 2,
                child: Icon(
                  Icons.flight,
                  size: 13,
                  color: statusColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

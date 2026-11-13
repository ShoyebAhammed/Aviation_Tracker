import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/flight_provider.dart';
import '../providers/settings_provider.dart';

class ApiUsageBanner extends StatelessWidget {
  final VoidCallback onOpenSettings;

  const ApiUsageBanner({super.key, required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    final flightProvider = context.watch<FlightProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final apiHits = flightProvider.apiHits;
    final cacheHits = flightProvider.cacheHits;
    final totalRequests = apiHits + cacheHits;
    final savingsPercent = totalRequests > 0
        ? ((cacheHits / totalRequests) * 100).toInt()
        : 100;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13203C) : const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.radarCyan.withValues(alpha: 0.3) : AppColors.primaryBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shield_outlined,
            size: 20,
            color: isDark ? AppColors.radarCyan : AppColors.primaryBlue,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      settingsProvider.isDemoMode
                          ? 'MINIMAL API MODE (ACTIVE)'
                          : 'LIVE API MODE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: isDark ? AppColors.radarCyan : AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.radarGreen.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$savingsPercent% SAVED',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.radarGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'API Calls: $apiHits  •  Local Cache Hits: $cacheHits',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 18),
            onPressed: onOpenSettings,
            tooltip: 'API Settings & Key',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}


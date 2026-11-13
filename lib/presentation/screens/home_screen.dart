import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/flight_model.dart';
import '../providers/flight_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/flight_card.dart';
import 'add_edit_flight_screen.dart';
import 'analytics_screen.dart';
import 'flight_detail_screen.dart';
import 'radar_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filterOptions = [
    'all',
    'active',
    'scheduled',
    'landed',
    'delayed',
    'favorites',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<FlightProvider>();
      if (!provider.isLoading && !provider.isLoadingMore && provider.hasMore) {
        provider.loadMoreFlights();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = [
      _buildFlightsListTab(isDark),
      const RadarScreen(),
      const AnalyticsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: pages[_currentTabIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (index) {
          setState(() => _currentTabIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.flight),
            selectedIcon: Icon(Icons.flight, color: AppColors.radarCyan),
            label: 'Flights',
          ),
          NavigationDestination(
            icon: Icon(Icons.public_outlined),
            selectedIcon: Icon(Icons.public, color: AppColors.radarCyan),
            label: 'World Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics, color: AppColors.radarCyan),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: AppColors.radarCyan),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _currentTabIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: isDark ? AppColors.radarCyan : AppColors.primaryBlue,
              foregroundColor: isDark ? Colors.black : Colors.white,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AddEditFlightScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Track Flight', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildFlightsListTab(bool isDark) {
    final flightProvider = context.watch<FlightProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    // Apply favorites filter locally if selected
    List<FlightModel> displayFlights = flightProvider.flights;
    if (flightProvider.selectedStatus == 'favorites') {
      displayFlights = displayFlights.where((f) => f.isFavorite).toList();
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await flightProvider.fetchFlights(forceRefresh: true);
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar with Brand Title & Quick Theme Toggle
            SliverAppBar(
              floating: true,
              snap: true,
              title: const Row(
                children: [
                  Icon(Icons.flight_takeoff, color: AppColors.radarCyan, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'SKYTRACK PRO',
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 18),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: isDark ? AppColors.radarCyan : AppColors.primaryBlue,
                  ),
                  onPressed: () => themeProvider.toggleTheme(),
                  tooltip: 'Toggle Theme',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => flightProvider.fetchFlights(forceRefresh: true),
                  tooltip: 'Refresh Live Feed',
                ),
              ],
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => flightProvider.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search by flight #, airline, SFO, JFK...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              flightProvider.setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),

            // Filter Chips Carousel
            SliverToBoxAdapter(
              child: Container(
                height: 44,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filterOptions.length,
                  itemBuilder: (context, i) {
                    final status = _filterOptions[i];
                    final isSelected = flightProvider.selectedStatus == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          status == 'all'
                              ? 'All Flights'
                              : (status == 'favorites' ? '★ Favorites' : status.toUpperCase()),
                        ),
                        selected: isSelected,
                        onSelected: (_) => flightProvider.setStatusFilter(status),
                        selectedColor: AppColors.radarCyan.withValues(alpha: 0.25),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Error Message View (if any real error)
            if (flightProvider.errorMessage != null)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.statusCancelled.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.statusCancelled.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.statusCancelled),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          flightProvider.errorMessage!,
                          style: const TextStyle(color: AppColors.statusCancelled, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Loading State (Initial)
            if (flightProvider.isLoading && displayFlights.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(strokeWidth: 2),
                      SizedBox(height: 16),
                      Text('Tracking live aircraft...', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            // Empty State
            else if (displayFlights.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flight_land, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'No flights found',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Try clearing your search or tap + to track a flight.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )
            // Flights List
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final flight = displayFlights[index];
                    return FlightCard(
                      flight: flight,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FlightDetailScreen(flight: flight),
                          ),
                        );
                      },
                      onEdit: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AddEditFlightScreen(flight: flight),
                          ),
                        );
                      },
                      onDelete: () {
                        flightProvider.deleteFlight(flight.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${flight.flightNumberDisplay} removed'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () => flightProvider.restoreFlight(flight),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: displayFlights.length,
                ),
              ),

            // Bottom Pagination Loading Indicator
            if (flightProvider.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
    );
  }
}

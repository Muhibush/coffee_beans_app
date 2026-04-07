import 'package:flutter/material.dart';
import 'package:coffee_beans_app/model/roastery.dart';
import 'package:coffee_beans_app/widget/stat_chip.dart';
import 'package:coffee_beans_app/pages/admin_dashboard/widget/admin_roastery_card.dart';
import 'package:coffee_beans_app/pages/admin_dashboard/widget/sticky_search_filter.dart';

/// Status filter options for the roastery list.
enum RoasteryFilter { all, active, inactive }

/// Admin Dashboard page — the landing screen for authenticated admin users.
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  // ── State ──
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  RoasteryFilter _activeFilter = RoasteryFilter.all;
  String _searchQuery = '';

  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  // ── Dummy Data ──
  final List<Roastery> _allRoasteries = const [
    Roastery(
      id: '1',
      name: 'Tanamera Coffee',
      city: 'Jakarta',
      beanCount: 12,
      isActive: true,
    ),
    Roastery(
      id: '2',
      name: 'Otten Coffee',
      city: 'Medan',
      beanCount: 24,
      isActive: true,
    ),
    Roastery(
      id: '3',
      name: 'Common Grounds',
      city: 'Bandung',
      beanCount: 8,
      isActive: true,
    ),
    Roastery(
      id: '4',
      name: 'Kopi Kenangan',
      city: 'Jakarta',
      beanCount: 15,
      isActive: false,
    ),
    Roastery(
      id: '5',
      name: 'Tuku Coffee',
      city: 'Jakarta',
      beanCount: 6,
      isActive: true,
    ),
    Roastery(
      id: '6',
      name: 'Anomali Coffee',
      city: 'Ubud',
      beanCount: 10,
      isActive: true,
    ),
    Roastery(
      id: '7',
      name: 'Kopi Kalyan',
      city: 'Yogyakarta',
      beanCount: 5,
      isActive: false,
    ),
    Roastery(
      id: '8',
      name: 'Coffeeland Roasters',
      city: 'Surabaya',
      beanCount: 18,
      isActive: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore &&
        _hasMoreData) {
      _loadMoreRoasteries();
    }
  }

  Future<void> _loadMoreRoasteries() async {
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isLoadingMore = false;
        _hasMoreData = false;
      });
    }
  }

  List<Roastery> get _filteredRoasteries {
    return _allRoasteries.where((r) {
      if (_activeFilter == RoasteryFilter.active && !r.isActive) return false;
      if (_activeFilter == RoasteryFilter.inactive && r.isActive) return false;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return r.name.toLowerCase().contains(query) ||
            r.city.toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRoasteries;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(child: _buildDashboardHeader(context)),

          // ── Sticky Search + Filters ──
          SliverPersistentHeader(
            pinned: true,
            delegate: StickySearchFilter<RoasteryFilter>(
              searchController: _searchController,
              searchHint: 'Search by name or city',
              activeFilter: _activeFilter,
              filters: const [
                FilterOption(label: 'All', value: RoasteryFilter.all),
                FilterOption(label: 'Active', value: RoasteryFilter.active),
                FilterOption(label: 'Inactive', value: RoasteryFilter.inactive),
              ],
              onFilterChanged: (f) => setState(() => _activeFilter = f),
              onSearchChanged: (q) => setState(() => _searchQuery = q),
              resultCount: filtered.length,
            ),
          ),

          // ── Roastery List ──
          if (filtered.isEmpty)
            SliverFillRemaining(child: _buildEmptyState(context))
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == filtered.length) {
                    return _isLoadingMore
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: colorScheme.primaryContainer,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink();
                  }
                  return AdminRoasteryCard(
                    roastery: filtered[index],
                    index: index,
                    onTap: () {
                      // TODO: Navigate to /admin/roastery/:id
                    },
                  );
                }, childCount: filtered.length + 1),
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SliverAppBar(
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      title: Text(
        'Coffee Beans App',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),
      ),
      centerTitle: false,
      actions: [
        TextButton(
          onPressed: () {},
          child: Text(
            'Logout',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDashboardHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activeCount = _allRoasteries.where((r) => r.isActive).length;
    final totalBeans = _allRoasteries.fold(0, (sum, r) => sum + r.beanCount);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OVERVIEW',
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Admin Dashboard',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              StatChip(
                icon: Icons.store_rounded,
                value: '${_allRoasteries.length}',
                label: 'Roasteries',
                color: colorScheme.primaryContainer,
              ),
              const SizedBox(width: 8),
              StatChip(
                icon: Icons.check_circle_rounded,
                value: '$activeCount',
                label: 'Active',
                color: colorScheme.tertiaryContainer,
              ),
              const SizedBox(width: 8),
              StatChip(
                icon: Icons.inventory_2_rounded,
                value: '$totalBeans',
                label: 'Beans',
                color: colorScheme.secondaryContainer,
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No roasteries found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {},
      child: const Icon(Icons.add_rounded, size: 28),
    );
  }
}

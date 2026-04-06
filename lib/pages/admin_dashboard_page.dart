import 'package:flutter/material.dart';
import 'package:coffee_beans_app/theme/app_theme.dart';
import 'package:coffee_beans_app/models/roastery.dart';

/// Status filter options for the roastery list.
enum RoasteryFilter { all, active, inactive }

/// Admin Dashboard page — the landing screen for authenticated admin users.
///
/// Features:
/// - Glassmorphic top app bar with branding and logout
/// - Sticky search bar + horizontal filter chips that pin on scroll
/// - Lazy-loaded roastery list (prepared for pagination via ScrollController)
/// - FAB for adding new roasteries
///
/// Accessed via `/admin/roastery` route (URL bypass from admin login).
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

  // Lazy loading state — ready for Supabase pagination
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  // Animation controller for staggered card entrance
  late AnimationController _staggerController;

  // ── Dummy Data ──
  // Will be replaced by BLoC state when Supabase is integrated.
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
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  /// Scroll listener for lazy loading — triggers when user reaches
  /// 80% of the scroll extent.
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore &&
        _hasMoreData) {
      _loadMoreRoasteries();
    }
  }

  /// Simulated pagination loader. Replace with BLoC event when ready.
  Future<void> _loadMoreRoasteries() async {
    setState(() => _isLoadingMore = true);
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isLoadingMore = false;
        // In production, append new items and check if more exist
        _hasMoreData = false; // No more dummy data
      });
    }
  }

  /// Returns the filtered + searched subset of roasteries.
  List<Roastery> get _filteredRoasteries {
    return _allRoasteries.where((r) {
      // Filter by status
      if (_activeFilter == RoasteryFilter.active && !r.isActive) return false;
      if (_activeFilter == RoasteryFilter.inactive && r.isActive) return false;
      // Filter by search query
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

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── Collapsible App Bar ──
          _buildAppBar(context),

          // ── Dashboard header ──
          SliverToBoxAdapter(child: _buildDashboardHeader(context)),

          // ── Sticky Search + Filters ──
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickySearchFilterDelegate(
              searchController: _searchController,
              activeFilter: _activeFilter,
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
                    // Loading indicator at the bottom
                    return _isLoadingMore
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.primaryContainer,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink();
                  }
                  return _buildRoasteryCard(context, filtered[index], index);
                }, childCount: filtered.length + 1),
              ),
            ),

          // Bottom padding for FAB clearance
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),

      // ── FAB ──
      floatingActionButton: _buildFAB(context),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // App Bar
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.surfaceBackground.withValues(alpha: 0.85),
      surfaceTintColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceBackground.withValues(alpha: 0.85),
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () {
          // TODO: Open drawer or navigate back
        },
        icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
      ),
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
          onPressed: () {
            // TODO: Supabase sign out + redirect to /admin-login
          },
          child: Text(
            'Logout',
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Dashboard Header
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDashboardHeader(BuildContext context) {
    final theme = Theme.of(context);
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
              color: AppColors.onSurfaceVariant,
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
          // ── Stats Row ──
          _buildStatsRow(context),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final theme = Theme.of(context);
    final activeCount = _allRoasteries.where((r) => r.isActive).length;
    final totalBeans = _allRoasteries.fold(0, (sum, r) => sum + r.beanCount);

    return Row(
      children: [
        _buildStatChip(
          theme,
          icon: Icons.store_rounded,
          value: '${_allRoasteries.length}',
          label: 'Roasteries',
          color: AppColors.primaryContainer,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          theme,
          icon: Icons.check_circle_rounded,
          value: '$activeCount',
          label: 'Active',
          color: AppColors.tertiaryContainer,
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          theme,
          icon: Icons.inventory_2_rounded,
          value: '$totalBeans',
          label: 'Beans',
          color: AppColors.secondaryContainer,
        ),
      ],
    );
  }

  Widget _buildStatChip(
    ThemeData theme, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 18,
              color: AppColors.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Roastery Card
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRoasteryCard(
    BuildContext context,
    Roastery roastery,
    int index,
  ) {
    final theme = Theme.of(context);
    final isInactive = !roastery.isActive;

    // Generate distinct avatar colors based on index
    final avatarColors = [
      AppColors.primaryContainer,
      AppColors.tertiaryContainer,
      AppColors.secondary,
      AppColors.primaryDark,
      AppColors.tertiary,
    ];
    final avatarColor = avatarColors[index % avatarColors.length];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 80).clamp(0, 400)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // TODO: Navigate to /admin/roastery/:id
            },
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.onSurface.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // ── Avatar / Logo ──
                    _buildRoasteryAvatar(roastery, avatarColor, isInactive),
                    const SizedBox(width: 16),
                    // ── Info ──
                    Expanded(
                      child: Opacity(
                        opacity: isInactive ? 0.5 : 1.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              roastery.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  roastery.city,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  Icons.inventory_2_rounded,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${roastery.beanCount} coffee beans',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                const Spacer(),
                                // ── Status Badge ──
                                _buildStatusBadge(theme, roastery.isActive),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // ── Chevron ──
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.outlineVariant,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoasteryAvatar(Roastery roastery, Color color, bool isInactive) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: isInactive ? AppColors.surfaceContainer : color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          roastery.name.isNotEmpty
              ? roastery.name.substring(0, 1).toUpperCase()
              : '?',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: isInactive
                ? AppColors.onSurfaceVariant
                : AppColors.onPrimary.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.tertiaryContainer
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'INACTIVE',
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: isActive
              ? AppColors.onTertiaryContainer
              : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Empty State
  // ═══════════════════════════════════════════════════════════════
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppColors.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No roasteries found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.outline,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // FAB
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // TODO: Navigate to add new roastery
      },
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.add_rounded, size: 28),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Sticky Search + Filter Delegate
// ═══════════════════════════════════════════════════════════════════
class _StickySearchFilterDelegate extends SliverPersistentHeaderDelegate {
  _StickySearchFilterDelegate({
    required this.searchController,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.onSearchChanged,
    required this.resultCount,
  });

  final TextEditingController searchController;
  final RoasteryFilter activeFilter;
  final ValueChanged<RoasteryFilter> onFilterChanged;
  final ValueChanged<String> onSearchChanged;
  final int resultCount;

  @override
  double get maxExtent => 140;
  @override
  double get minExtent => 140;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    // Show subtle shadow when pinned/overlapping
    final isPinned = shrinkOffset > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.surfaceBackground,
        boxShadow: isPinned
            ? [
                BoxShadow(
                  color: AppColors.onSurface.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search Bar ──
            TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by name or city',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 22,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.onSurfaceVariant,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primaryContainer,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ── Filter Chips ──
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip(
                    context,
                    label: 'All',
                    filter: RoasteryFilter.all,
                    count: null,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    label: 'Active',
                    filter: RoasteryFilter.active,
                    count: null,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    label: 'Inactive',
                    filter: RoasteryFilter.inactive,
                    count: null,
                  ),
                  const SizedBox(width: 8),
                  // Result count badge
                  Center(
                    child: Text(
                      '$resultCount results',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.outline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required RoasteryFilter filter,
    int? count,
  }) {
    final theme = Theme.of(context);
    final isSelected = activeFilter == filter;

    return GestureDetector(
      onTap: () => onFilterChanged(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Text(
          count != null ? '$label ($count)' : label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected
                ? AppColors.onPrimary
                : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickySearchFilterDelegate oldDelegate) {
    return activeFilter != oldDelegate.activeFilter ||
        resultCount != oldDelegate.resultCount ||
        searchController != oldDelegate.searchController;
  }
}

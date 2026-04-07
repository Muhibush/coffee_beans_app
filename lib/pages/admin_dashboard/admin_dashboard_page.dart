import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:coffee_beans_app/widget/stat_chip.dart';
import 'package:coffee_beans_app/pages/admin_dashboard/widget/admin_roastery_card.dart';
import 'package:coffee_beans_app/pages/admin_dashboard/widget/sticky_search_filter.dart';
import 'package:coffee_beans_app/pages/admin_login/bloc/auth_bloc.dart';
import 'package:coffee_beans_app/pages/admin_login/bloc/auth_event.dart';
import 'package:coffee_beans_app/pages/admin_login/bloc/auth_state.dart';
import 'bloc/admin_dashboard_bloc.dart';
import 'bloc/admin_dashboard_event.dart';
import 'bloc/admin_dashboard_state.dart';
import 'repository/admin_dashboard_repository.dart';

/// Status filter options for the roastery list.
enum RoasteryFilter { all, active, inactive }

/// Admin Dashboard page — the landing screen for authenticated admin users.
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminDashboardBloc(
        repository: AdminDashboardRepository(),
      )..add(LoadRoasteries()),
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatefulWidget {
  const _AdminDashboardView();

  @override
  State<_AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<_AdminDashboardView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  RoasteryFilter _activeFilter = RoasteryFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        final filtered = state.filteredRoasteries;

        return Scaffold(
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(child: _buildDashboardHeader(context, state)),

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
                  onFilterChanged: (f) {
                    setState(() => _activeFilter = f);
                    context.read<AdminDashboardBloc>().add(
                      FilterRoasteries(f.name),
                    );
                  },
                  onSearchChanged: (q) {
                    context.read<AdminDashboardBloc>().add(
                      SearchRoasteries(q),
                    );
                  },
                  resultCount: filtered.length,
                ),
              ),

              // ── Content ──
              if (state.status == AdminDashboardStatus.loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.status == AdminDashboardStatus.error)
                SliverFillRemaining(
                  child: _buildErrorState(context, state.errorMessage),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(child: _buildEmptyState(context))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return AdminRoasteryCard(
                        roastery: filtered[index],
                        index: index,
                        onTap: () {
                          context.push('/admin/roastery/${filtered[index].id}');
                        },
                      );
                    }, childCount: filtered.length),
                  ),
                ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/admin/roastery/new'),
            child: const Icon(Icons.add_rounded, size: 28),
          ),
        );
      },
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
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Unauthenticated) {
              context.go('/admin-login');
            }
          },
          child: TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
            child: Text(
              'Logout',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDashboardHeader(BuildContext context, AdminDashboardState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                value: '${state.allRoasteries.length}',
                label: 'Roasteries',
                color: colorScheme.primaryContainer,
              ),
              const SizedBox(width: 8),
              StatChip(
                icon: Icons.check_circle_rounded,
                value: '${state.activeCount}',
                label: 'Active',
                color: colorScheme.tertiaryContainer,
              ),
              const SizedBox(width: 8),
              StatChip(
                icon: Icons.inventory_2_rounded,
                value: '${state.totalBeans}',
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
          Icon(Icons.search_off_rounded, size: 64, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            'No roasteries found',
            style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Failed to load roasteries',
            style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.error),
          ),
          const SizedBox(height: 8),
          Text(
            message ?? 'Unknown error',
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.outline),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.tonal(
            onPressed: () => context.read<AdminDashboardBloc>().add(LoadRoasteries()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

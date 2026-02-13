import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/injector.dart';
import 'side_nav.dart';

import '../features/appliances/presentation/pages/appliances_page.dart';
import '../features/preferences/presentation/pages/preferences_page.dart';

// Minimal pages for now; add your other pages similarly:
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/optimization/presentation/pages/optimization_page.dart';
import '../features/analytics/presentation/pages/analytics_page.dart';
import '../features/history/presentation/pages/history_page.dart';
import '../features/about/about_page.dart';

import '../features/appliances/presentation/bloc/appliances_bloc.dart';
import '../features/preferences/presentation/bloc/preferences_bloc.dart';
import '../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../features/optimization/presentation/bloc/optimization_bloc.dart';
import '../features/analytics/presentation/bloc/analytics_bloc.dart';
import '../features/history/presentation/bloc/history_bloc.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  NavItem selected = NavItem.dashboard;

  Widget _page() {
    switch (selected) {
      case NavItem.dashboard:
        return const DashboardPage();
      case NavItem.appliances:
        return const AppliancesPage();
      case NavItem.preferences:
        return const PreferencesPage();
      case NavItem.optimize:
        return const OptimizationPage();
      case NavItem.analytics:
        return const AnalyticsPage();
      case NavItem.history:
        return const HistoryPage();
      case NavItem.about:
        return const AboutPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AppliancesBloc>()),
        BlocProvider(create: (_) => sl<PreferencesBloc>()),
        BlocProvider(create: (_) => sl<DashboardBloc>()),
        BlocProvider(create: (_) => sl<OptimizationBloc>()),
        BlocProvider(create: (_) => sl<AnalyticsBloc>()),
        BlocProvider(create: (_) => sl<HistoryBloc>()),
      ],
      child: Scaffold(
        body: Row(
          children: [
            const SizedBox(width: 8),
            SideNav(selected: selected, onChanged: (v) => setState(() => selected = v)),
            const VerticalDivider(width: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: _page(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

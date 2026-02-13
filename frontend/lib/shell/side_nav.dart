import 'package:flutter/material.dart';

enum NavItem { dashboard, appliances, preferences, optimize, analytics, history, about }

class SideNav extends StatelessWidget {
  final NavItem selected;
  final ValueChanged<NavItem> onChanged;
  const SideNav({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: NavItem.values.indexOf(selected),
      onDestinationSelected: (i) => onChanged(NavItem.values[i]),
      labelType: NavigationRailLabelType.none,
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text("Dashboard")),
        NavigationRailDestination(icon: Icon(Icons.devices_other_outlined), selectedIcon: Icon(Icons.devices_other), label: Text("Appliances")),
        NavigationRailDestination(icon: Icon(Icons.tune_outlined), selectedIcon: Icon(Icons.tune), label: Text("Preferences")),
        NavigationRailDestination(icon: Icon(Icons.play_circle_outline), selectedIcon: Icon(Icons.play_circle), label: Text("Optimize")),
        NavigationRailDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: Text("Analytics")),
        NavigationRailDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: Text("History")),
        NavigationRailDestination(icon: Icon(Icons.info_outline), selectedIcon: Icon(Icons.info), label: Text("About")),
      ],
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../bloc/dashboard_bloc.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(DashboardLoadRequested());
  }

  Widget _statCard({required String title, required String value, String? suffix}) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12)),
              const SizedBox(height: 10),
              Text(
                value + (suffix ?? ""),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniLineChart() {
    // dummy smooth curve for dashboard look
    final spots = <FlSpot>[
      const FlSpot(0, 2.1),
      const FlSpot(1, 2.6),
      const FlSpot(2, 2.3),
      const FlSpot(3, 3.0),
      const FlSpot(4, 3.3),
      const FlSpot(5, 3.9),
    ];

    return LineChart(
      LineChartData(
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            spots: spots,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, s) {
        final DashboardSummary? d = s.summary;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Dashboard", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),

            if (s.loading) const LinearProgressIndicator(minHeight: 2),
            if (s.error != null) ...[
              const SizedBox(height: 8),
              Text(s.error!, style: const TextStyle(color: Colors.redAccent)),
            ],
            const SizedBox(height: 12),

            Row(
              children: [
                _statCard(
                  title: "Today's Cost",
                  value: d == null ? "₹0.00" : "₹${d.todaysCost.toStringAsFixed(2)}",
                ),
                const SizedBox(width: 10),
                _statCard(
                  title: "Baseline Cost",
                  value: d == null ? "₹0.00" : "₹${d.baselineCost.toStringAsFixed(2)}",
                ),
                const SizedBox(width: 10),
                _statCard(
                  title: "Savings",
                  value: d == null ? "0" : d.savingsPercent.toStringAsFixed(0),
                  suffix: "%",
                ),
                const SizedBox(width: 10),
                _statCard(
                  title: "Peak Load",
                  value: d == null ? "0.0" : d.peakLoadKw.toStringAsFixed(1),
                  suffix: " kW",
                ),
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Power Consumption", style: TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 10),
                            Expanded(child: _miniLineChart()),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Today's Schedule (Preview)", style: TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 10),
                            Text(
                              "Run Optimization to populate schedule.\n\n(You can also fetch /runs/{id} and render table here.)",
                              style: TextStyle(color: Colors.white.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

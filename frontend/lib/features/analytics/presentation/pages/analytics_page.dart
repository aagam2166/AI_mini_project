import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/analytics_bloc.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});
  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AnalyticsBloc>().add(AnalyticsLoadRequested());
  }

  Widget _barCompare(String title, double a, double b, String aLabel, String bLabel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (x, meta) {
                          final idx = x.toInt();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(idx == 0 ? aLabel : bLabel, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: a)]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: b)]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weeklyTrend(List<double> weekly) {
    final spots = <FlSpot>[];
    for (int i = 0; i < weekly.length; i++) {
      spots.add(FlSpot(i.toDouble(), weekly[i]));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Weekly Cost Trend", style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: LineChart(
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, s) {
        final a = s.analytics;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Analytics", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            if (s.loading) const LinearProgressIndicator(minHeight: 2),
            if (s.error != null) ...[
              const SizedBox(height: 8),
              Text(s.error!, style: const TextStyle(color: Colors.redAccent)),
            ],
            const SizedBox(height: 12),

            Expanded(
              child: a == null
                  ? const Center(child: Text("No analytics yet. Run optimization first."))
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _barCompare("Cost Comparison", a.costBaseline, a.costOptimized, "Baseline", "Optimized"),
                              const SizedBox(height: 12),
                              _barCompare("Peak Load Reduction", a.peakBeforeKw, a.peakAfterKw, "Before", "After"),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _weeklyTrend(a.weeklyCosts)),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

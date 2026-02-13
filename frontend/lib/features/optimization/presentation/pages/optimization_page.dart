// lib/features/optimization/presentation/pages/optimization_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/time_utils.dart';
import '../bloc/optimization_bloc.dart';

class OptimizationPage extends StatefulWidget {
  const OptimizationPage({super.key});
  @override
  State<OptimizationPage> createState() => _OptimizationPageState();
}

class _OptimizationPageState extends State<OptimizationPage> {
  final powerLimitCtrl = TextEditingController(text: "4200");

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OptimizationBloc, OptimizationState>(
      builder: (context, s) {
        final r = s.result;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Optimization Engine", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Algorithm: ${r?.algorithm ?? "Backtracking CSP"}", style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    const Text("Constraints: Power• Power limit• Time windows• Preferences"),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(
                          width: 220,
                          child: TextField(
                            controller: powerLimitCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "Power Limit (W)"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilledButton(
                          onPressed: s.loading
                              ? null
                              : () => context.read<OptimizationBloc>().add(
                                    OptimizationRequested(int.tryParse(powerLimitCtrl.text) ?? 4200),
                                  ),
                          child: Text(s.loading ? "Running..." : "Run Optimization"),
                        ),
                      ],
                    ),
                    if (r != null) ...[
                      const SizedBox(height: 10),
                      Text("Last Results:  Cost ₹${r.totalCost.toStringAsFixed(2)}  •  Peak ${r.peakKw.toStringAsFixed(2)} kW  •  Time ${r.runtimeMs} ms"),
                    ],
                    if (s.error != null) ...[
                      const SizedBox(height: 8),
                      Text(s.error!, style: const TextStyle(color: Colors.redAccent)),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            const Text("Today's Schedule", style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),

            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: r == null
                      ? const Center(child: Text("Run optimization to generate schedule"))
                      : ListView.separated(
                          itemCount: r.schedule.length,
                          separatorBuilder: (_, __) => const Divider(height: 18),
                          itemBuilder: (_, i) {
                            final it = r.schedule[i];
                            return Row(
                              children: [
                                Expanded(child: Text(it.applianceName, style: const TextStyle(fontWeight: FontWeight.w700))),
                                Text("${minToHHMM(it.startMin)} - ${minToHHMM(it.endMin)}"),
                                const SizedBox(width: 18),
                                Text("${it.powerW} W"),
                                const SizedBox(width: 18),
                                Text("₹${it.cost.toStringAsFixed(2)}"),
                              ],
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

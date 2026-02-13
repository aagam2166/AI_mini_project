import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/history_bloc.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().add(HistoryLoadRequested());
  }

  String _fmtDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final yy = d.year;
    return "$mm/$dd/$yy";
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, s) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("History", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            if (s.loading) const LinearProgressIndicator(minHeight: 2),
            if (s.error != null) ...[
              const SizedBox(height: 8),
              Text(s.error!, style: const TextStyle(color: Colors.redAccent)),
            ],
            const SizedBox(height: 12),

            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: s.items.isEmpty
                      ? const Center(child: Text("No runs yet. Run optimization first."))
                      : ListView.separated(
                          itemCount: s.items.length,
                          separatorBuilder: (_, __) => const Divider(height: 18),
                          itemBuilder: (_, i) {
                            final it = s.items[i];
                            return Row(
                              children: [
                                Expanded(flex: 2, child: Text(_fmtDate(it.createdAt))),
                                Expanded(flex: 2, child: Text("₹${it.totalCost.toStringAsFixed(2)}")),
                                Expanded(flex: 2, child: Text("${it.peakKw.toStringAsFixed(1)} kW")),
                                Expanded(flex: 2, child: Text("${it.savingsPercent.toStringAsFixed(0)}%")),
                                const Spacer(),
                                FilledButton(
                                  onPressed: () {
                                    // Later: open run details by calling /runs/{id}
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Run #${it.id} selected (wire details page next)")),
                                    );
                                  },
                                  child: const Text("View"),
                                ),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/appliances_bloc.dart';
import '../bloc/appliances_event.dart';
import '../bloc/appliances_state.dart';

class AppliancesPage extends StatefulWidget {
  const AppliancesPage({super.key});

  @override
  State<AppliancesPage> createState() => _AppliancesPageState();
}

class _AppliancesPageState extends State<AppliancesPage> {
  @override
  void initState() {
    super.initState();
    context.read<AppliancesBloc>().add(AppliancesLoadRequested());
  }

  void _openAddDialog() {
    final name = TextEditingController();
    final power = TextEditingController(text: "800");
    final duration = TextEditingController(text: "120");
    final earliest = TextEditingController(text: "0");
    final latest = TextEditingController(text: "1439");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Appliance"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: "Name")),
              const SizedBox(height: 10),
              TextField(controller: power, decoration: const InputDecoration(labelText: "Power (W)"), keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              TextField(controller: duration, decoration: const InputDecoration(labelText: "Duration (min)"), keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              TextField(controller: earliest, decoration: const InputDecoration(labelText: "Earliest start (min)"), keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              TextField(controller: latest, decoration: const InputDecoration(labelText: "Latest start (min)"), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          FilledButton(
            onPressed: () {
              context.read<AppliancesBloc>().add(ApplianceAddRequested(
                    name: name.text.trim().isEmpty ? "New Appliance" : name.text.trim(),
                    powerW: int.tryParse(power.text) ?? 800,
                    durationMin: int.tryParse(duration.text) ?? 120,
                    earliestMin: int.tryParse(earliest.text) ?? 0,
                    latestMin: int.tryParse(latest.text) ?? 1439,
                  ));
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppliancesBloc, AppliancesState>(
      builder: (context, s) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("Appliances", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _openAddDialog,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Appliance"),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (s.loading) const LinearProgressIndicator(minHeight: 2),

            const SizedBox(height: 12),

            Expanded(
              child: ListView.separated(
                itemCount: s.appliances.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final a = s.appliances[i];
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.electrical_services)),
                      title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text("${a.powerW} W  •  ${a.durationMin} min"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: a.enabled,
                            onChanged: (v) => context.read<AppliancesBloc>().add(ApplianceToggleRequested(a.id, v)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => context.read<AppliancesBloc>().add(ApplianceDeleteRequested(a.id)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

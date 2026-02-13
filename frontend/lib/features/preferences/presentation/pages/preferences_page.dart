// lib/features/preferences/presentation/pages/preferences_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/preferences_bloc.dart';
import '../../domain/entities/preferences.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});
  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  @override
  void initState() {
    super.initState();
    context.read<PreferencesBloc>().add(PreferencesLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreferencesBloc, PreferencesState>(
      builder: (context, s) {
        final p = s.prefs;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Preferences", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            if (s.loading) const LinearProgressIndicator(minHeight: 2),
            const SizedBox(height: 12),

            if (p == null)
              const Expanded(child: Center(child: Text("No preferences loaded")))
            else
              Expanded(
                child: ListView(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Comfort Level", style: TextStyle(fontWeight: FontWeight.w700)),
                            Slider(
                              value: p.comfortLevel,
                              onChanged: (v) => context.read<PreferencesBloc>().add(
                                    PreferencesChanged(Preferences(
                                      id: p.id,
                                      comfortLevel: v,
                                      maxDelayMin: p.maxDelayMin,
                                      nightUsageAllowed: p.nightUsageAllowed,
                                      costSavingPriority: p.costSavingPriority,
                                    )),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Max Delay Allowed (minutes)", style: TextStyle(fontWeight: FontWeight.w700)),
                            Slider(
                              min: 0,
                              max: 240,
                              divisions: 24,
                              label: "${p.maxDelayMin}",
                              value: p.maxDelayMin.toDouble(),
                              onChanged: (v) => context.read<PreferencesBloc>().add(
                                    PreferencesChanged(Preferences(
                                      id: p.id,
                                      comfortLevel: p.comfortLevel,
                                      maxDelayMin: v.round(),
                                      nightUsageAllowed: p.nightUsageAllowed,
                                      costSavingPriority: p.costSavingPriority,
                                    )),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: SwitchListTile(
                        title: const Text("Night Usage Allowed", style: TextStyle(fontWeight: FontWeight.w700)),
                        value: p.nightUsageAllowed,
                        onChanged: (v) => context.read<PreferencesBloc>().add(
                              PreferencesChanged(Preferences(
                                id: p.id,
                                comfortLevel: p.comfortLevel,
                                maxDelayMin: p.maxDelayMin,
                                nightUsageAllowed: v,
                                costSavingPriority: p.costSavingPriority,
                              )),
                            ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Cost Saving Priority", style: TextStyle(fontWeight: FontWeight.w700)),
                            Slider(
                              value: p.costSavingPriority,
                              onChanged: (v) => context.read<PreferencesBloc>().add(
                                    PreferencesChanged(Preferences(
                                      id: p.id,
                                      comfortLevel: p.comfortLevel,
                                      maxDelayMin: p.maxDelayMin,
                                      nightUsageAllowed: p.nightUsageAllowed,
                                      costSavingPriority: v,
                                    )),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        FilledButton(
                          onPressed: s.saving ? null : () => context.read<PreferencesBloc>().add(PreferencesSaveRequested()),
                          child: Text(s.saving ? "Saving..." : "Save"),
                        ),
                        if (s.error != null) ...[
                          const SizedBox(width: 12),
                          Expanded(child: Text(s.error!, style: const TextStyle(color: Colors.redAccent))),
                        ],
                      ],
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

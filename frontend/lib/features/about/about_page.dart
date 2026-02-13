import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        color: Colors.white.withOpacity(0.04),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("About IntelliHEMS", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Smart Home Energy Management System using CSP (Constraint Satisfaction Problem)",
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
                const SizedBox(height: 16),

                const Text("System Architecture", style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),

                Row(
                  children: [
                    _pill("User Input"),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_ios, size: 14),
                    const SizedBox(width: 10),
                    _pill("CSP Engine"),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_ios, size: 14),
                    const SizedBox(width: 10),
                    _pill("Schedule Output"),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_ios, size: 14),
                    const SizedBox(width: 10),
                    _pill("Home Control"),
                  ],
                ),

                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 10),

                Text(
                  "Technologies Used: Flutter, BLoC, FastAPI, SQLite, SQLAlchemy\n"
                  "Optimization: Backtracking CSP + Objective (Cost + Peak)\n",
                  style: TextStyle(color: Colors.white.withOpacity(0.75)),
                ),

                const SizedBox(height: 6),
                Text(
                  "Developed by: Your Name",
                  style: TextStyle(color: Colors.white.withOpacity(0.75)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

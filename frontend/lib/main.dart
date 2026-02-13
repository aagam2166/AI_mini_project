import 'package:flutter/material.dart';
import 'core/di/injector.dart';
import 'core/theme/app_theme.dart';
import 'shell/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDI();
  runApp(const IntelliHEMSApp());
}

class IntelliHEMSApp extends StatelessWidget {
  const IntelliHEMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const AppShell(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rehab_app/core/theme.dart';
import 'package:rehab_app/data/models/workout_session.dart';
import 'package:rehab_app/ui/screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(WorkoutSessionAdapter());
  await Hive.openBox<WorkoutSession>('workout_sessions');
  await Hive.openBox('settings');
  runApp(const RehabApp());
}

class RehabApp extends StatelessWidget {
  const RehabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Rehab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const WelcomeScreen(),
    );
  }
}

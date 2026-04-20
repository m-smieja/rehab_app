import 'package:flutter/material.dart';
import 'package:rehab_app/data/models/exercise.dart';
import 'package:rehab_app/data/services/api_service.dart';
import 'package:rehab_app/ui/screens/exercise_detail_screen.dart';
import 'package:rehab_app/ui/widgets/glass_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Exercise>> _exercisesFuture;
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _exercisesFuture = _api.fetchExercises();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFF2A1B54),
              Color(0xFF0F172A),
              Color(0xFF05050A),
            ],
            center: Alignment.topLeft,
            radius: 1.5,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'DIGITAL REHAB',
                    textAlign: TextAlign.center,
                    style: textTheme.displayLarge,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Your AI-powered recovery companion',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 40),
                _buildExerciseSection(textTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseSection(TextTheme textTheme) {
    return FutureBuilder<List<Exercise>>(
      future: _exercisesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 64),
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7C5CFF),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'Failed to load exercises.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.redAccent.shade100,
                ),
              ),
            ),
          );
        }

        final exercises = snapshot.data ?? const <Exercise>[];
        if (exercises.isEmpty) {
          return Center(
            child: Text('No exercises available.', style: textTheme.bodyMedium),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: exercises.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return GlassCard(
              exercise: exercise,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ExerciseDetailScreen(exercise: exercise),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

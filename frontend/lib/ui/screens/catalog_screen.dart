import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rehab_app/data/models/exercise.dart';
import 'package:rehab_app/data/services/api_service.dart';
import 'package:rehab_app/ui/screens/exercise_detail_screen.dart';
import 'package:rehab_app/ui/screens/welcome_screen.dart';
import 'package:rehab_app/ui/widgets/glass_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Exercise>> _exercisesFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _exercisesFuture = _api.fetchExercises();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showWeightDialog(BuildContext context) async {
    final box = Hive.isBoxOpen('settings')
        ? Hive.box('settings')
        : await Hive.openBox('settings');
    if (!context.mounted) return;
    final current =
        (box.get('weight', defaultValue: 70.0) as num).toDouble();
    final controller =
        TextEditingController(text: current.toStringAsFixed(0));
    String? error;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF140D2E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Your Weight',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Used to calculate calories burned.',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.5)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  style: GoogleFonts.inter(color: Colors.white),
                  onChanged: (_) {
                    final val = int.tryParse(controller.text);
                    setDialogState(() {
                      error = (val == null || val < 20 || val > 300)
                          ? 'Enter a value between 20 and 300'
                          : null;
                    });
                  },
                  decoration: InputDecoration(
                    suffixText: 'kg',
                    suffixStyle: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.5)),
                    errorText: error,
                    errorStyle: const TextStyle(
                        color: Colors.redAccent, fontSize: 11),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF7C5CFF)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.redAccent),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.redAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.5))),
            ),
            ElevatedButton(
              onPressed: error != null
                  ? null
                  : () {
                      final val = int.tryParse(controller.text);
                      if (val != null && val >= 20 && val <= 300) {
                        box.put('weight', val.toDouble());
                      }
                      Navigator.pop(ctx);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C5CFF),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFF7C5CFF).withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Save',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );

    controller.dispose();
  }

  List<Exercise> _filter(List<Exercise> all) {
    if (_query.isEmpty) return all;
    return all.where((e) => e.name.toLowerCase().contains(_query)).toList();
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Wyloguj',
                          icon: const Icon(Icons.logout_rounded),
                          color: Colors.white.withValues(alpha: 0.6),
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const WelcomeScreen(),
                              ),
                              (_) => false,
                            );
                          },
                        ),
                        Expanded(
                          child: Text(
                            'DIGITAL REHAB',
                            textAlign: TextAlign.center,
                            style:
                                textTheme.displayLarge?.copyWith(fontSize: 36),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Ustawienia',
                          icon: const Icon(Icons.settings_rounded),
                          color: Colors.white.withValues(alpha: 0.6),
                          onPressed: () => _showWeightDialog(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _SearchField(
                      controller: _searchController,
                      onChanged: (v) =>
                          setState(() => _query = v.trim().toLowerCase()),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Exercise>>(
                  future: _exercisesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF7C5CFF),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(32),
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

                    final all = snapshot.data ?? const <Exercise>[];
                    final filtered = _filter(all);

                    if (filtered.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            _query.isEmpty
                                ? 'No exercises available.'
                                : 'No matches for "$_query".',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final exercise = filtered[index];
                        return GlassCard(
                          exercise: exercise,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ExerciseDetailScreen(exercise: exercise),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      cursorColor: const Color(0xFF7C5CFF),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search exercises',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: Colors.white.withValues(alpha: 0.55),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
      ),
    );
  }
}

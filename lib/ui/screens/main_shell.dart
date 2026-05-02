import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehab_app/ui/screens/catalog_screen.dart';
import 'package:rehab_app/ui/screens/workout_history_screen.dart';

class MainShell extends StatefulWidget {
  // Static notifier so any screen in the push stack can switch tabs without
  // needing the notifier threaded through constructors.
  static final tabNotifier = ValueNotifier<int>(0);

  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    MainShell.tabNotifier.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    MainShell.tabNotifier.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final index = MainShell.tabNotifier.value;

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          CatalogScreen(),
          WorkoutHistoryScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) => MainShell.tabNotifier.value = i,
          backgroundColor: const Color(0xFF0A0A12),
          selectedItemColor: const Color(0xFF7C5CFF),
          unselectedItemColor: Colors.white.withValues(alpha: 0.38),
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 11,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_rounded),
              label: 'Exercises',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}

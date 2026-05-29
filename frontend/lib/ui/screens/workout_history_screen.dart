import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rehab_app/data/models/workout_session.dart';
import 'package:rehab_app/ui/screens/session_detail_screen.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  late final Box<WorkoutSession> _box;
  String? _selectedExercise;

  @override
  void initState() {
    super.initState();
    _box = Hive.box<WorkoutSession>('workout_sessions');
  }

  List<WorkoutSession> _sortedSessions() {
    final all = _box.values.toList();
    all.sort((a, b) => a.date.compareTo(b.date));
    return all;
  }

  List<String> _exerciseNames(List<WorkoutSession> sessions) {
    final seen = <String>{};
    return sessions.map((s) => s.exerciseName).where(seen.add).toList();
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<WorkoutSession>>(
      valueListenable: _box.listenable(),
      builder: (context, box, _) {
        final sessions = _sortedSessions();
        final exercises = _exerciseNames(sessions);

        if (_selectedExercise == null && exercises.isNotEmpty) {
          _selectedExercise = exercises.first;
        }
        if (_selectedExercise != null &&
            !exercises.contains(_selectedExercise)) {
          _selectedExercise = exercises.isNotEmpty ? exercises.first : null;
        }

        final filtered = _selectedExercise == null
            ? <WorkoutSession>[]
            : sessions
                .where((s) => s.exerciseName == _selectedExercise)
                .toList();

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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Text(
                      'HISTORY',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 44,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: sessions.isEmpty
                        ? _buildEmptyState()
                        : _buildContent(exercises, filtered),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.fitness_center_rounded,
            size: 56,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No sessions yet',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete an exercise to see your history here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      List<String> exercises, List<WorkoutSession> filtered) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        if (exercises.length > 1) ...[
          _buildExerciseDropdown(exercises),
          const SizedBox(height: 20),
        ] else ...[
          _buildExerciseLabel(),
          const SizedBox(height: 20),
        ],
        _buildChart(filtered),
        const SizedBox(height: 28),
        Text(
          'SESSIONS',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 12),
        ...filtered.reversed.map((s) => _buildSessionCard(s)),
      ],
    );
  }

  Widget _buildExerciseLabel() {
    final name = _selectedExercise ?? '';
    final capitalized =
        name.isEmpty ? '' : name[0].toUpperCase() + name.substring(1);
    return Text(
      capitalized,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildExerciseDropdown(List<String> exercises) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedExercise,
          dropdownColor: const Color(0xFF1A0F3A),
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.white54),
          onChanged: (v) => setState(() => _selectedExercise = v),
          items: exercises.map((e) {
            final label = e.isEmpty ? e : e[0].toUpperCase() + e.substring(1);
            return DropdownMenuItem(value: e, child: Text(label));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildChart(List<WorkoutSession> sessions) {
    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: sessions.isEmpty
          ? Center(
              child: Text(
                'No data for this exercise',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            )
          : LineChart(_chartData(sessions)),
    );
  }

  LineChartData _chartData(List<WorkoutSession> sessions) {
    final spots = sessions.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.repCount.toDouble());
    }).toList();

    final maxY = sessions.map((s) => s.repCount).reduce((a, b) => a > b ? a : b);

    return LineChartData(
      minX: 0,
      maxX: (sessions.length - 1).toDouble(),
      minY: 0,
      maxY: (maxY + 2).toDouble(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.white.withValues(alpha: 0.07),
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      titlesData: FlTitlesData(
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: _yInterval(maxY),
            getTitlesWidget: (value, meta) {
              if (value == meta.max || value < 0) return const SizedBox();
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= sessions.length) {
                return const SizedBox();
              }
              final step = (sessions.length / 4).ceil().clamp(1, sessions.length);
              if (idx % step != 0 && idx != sessions.length - 1) {
                return const SizedBox();
              }
              final d = sessions[idx].date;
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${d.day}/${d.month}',
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: sessions.length > 2,
          curveSmoothness: 0.3,
          color: const Color(0xFF7C5CFF),
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
              radius: 4,
              color: const Color(0xFF7C5CFF),
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            color: const Color(0xFF7C5CFF).withValues(alpha: 0.12),
          ),
        ),
      ],
    );
  }

  double _yInterval(int maxY) {
    if (maxY <= 5) return 1;
    if (maxY <= 20) return 5;
    return 10;
  }

  Widget _buildSessionCard(WorkoutSession session) {
    final capitalized = session.exerciseName.isEmpty
        ? session.exerciseName
        : session.exerciseName[0].toUpperCase() +
            session.exerciseName.substring(1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SessionDetailScreen(session: session),
            ),
          ),
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF7C5CFF).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: Color(0xFF7C5CFF),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    capitalized,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(session.date),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${session.repCount} reps',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDuration(session.durationSeconds),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }
}

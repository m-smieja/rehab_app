import 'package:flutter/material.dart';
import 'package:rehab_app/ui/screens/coach/patient_list_screen.dart';
import 'package:rehab_app/ui/screens/coach/plan_editor_screen.dart';

class PatientDetailScreen extends StatelessWidget {
  final PatientData patient;

  const PatientDetailScreen({super.key, required this.patient});

  static const _currentPlan = [
    ('Squats', '3 sets × 12 reps', '60s rest'),
    ('Leg Press', '3 sets × 15 reps', '90s rest'),
    ('Hamstring Curl', '4 sets × 10 reps', '60s rest'),
    ('Calf Raises', '3 sets × 20 reps', '45s rest'),
    ('Balance Board', '2 sets × 60 sec', '30s rest'),
  ];

  Color get _statusColor => switch (patient.status) {
        PatientStatus.active => const Color(0xFF30E070),
        PatientStatus.missedSessions => const Color(0xFFFF4B55),
        PatientStatus.reportedPain => const Color(0xFFFFC947),
      };

  String get _statusLabel => switch (patient.status) {
        PatientStatus.active => 'Active',
        PatientStatus.missedSessions => 'Missed Sessions',
        PatientStatus.reportedPain => 'Reported Pain',
      };

  String get _initials =>
      patient.name.split(' ').map((w) => w[0]).take(2).join();

  List<({String label, String value, IconData icon, Color color})>
      get _telemetry => [
            (
              label: 'Avg. Squat Depth',
              value: '87°',
              icon: Icons.straighten_rounded,
              color: const Color(0xFF7C5CFF),
            ),
            (
              label: 'Rep Consistency',
              value: '92%',
              icon: Icons.timeline_rounded,
              color: const Color(0xFF30E070),
            ),
            (
              label: 'Sessions / Week',
              value: '4 / 5',
              icon: Icons.calendar_today_rounded,
              color: const Color(0xFF7C5CFF),
            ),
            (
              label: 'Avg. Duration',
              value: '38 min',
              icon: Icons.timer_rounded,
              color: const Color(0xFFFFC947),
            ),
            (
              label: 'Pain Level (avg)',
              value: '2.4 / 10',
              icon: Icons.favorite_rounded,
              color: const Color(0xFF30E070),
            ),
            (
              label: 'Completion Rate',
              value: '${patient.completionRate}%',
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF30E070),
            ),
          ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF2A1B54), Color(0xFF0F172A), Color(0xFF05050A)],
            center: Alignment.topLeft,
            radius: 1.5,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(context, textTheme),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                sliver: SliverToBoxAdapter(
                  child: _SectionLabel(label: 'AI TELEMETRY'),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.45,
                  children: _telemetry
                      .map((t) => _TelemetryCell(
                            label: t.label,
                            value: t.value,
                            icon: t.icon,
                            color: t.color,
                          ))
                      .toList(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const _SectionLabel(label: 'CURRENT PLAN'),
                      const Spacer(),
                      Text(
                        'Week 3 · Day 2',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList.separated(
                  itemCount: _currentPlan.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final (name, reps, rest) = _currentPlan[i];
                    return _PlanRow(
                      index: i + 1,
                      name: name,
                      reps: reps,
                      rest: rest,
                    );
                  },
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                sliver: SliverToBoxAdapter(
                  child: _PrimaryButton(
                    label: 'EDIT PLAN',
                    icon: Icons.edit_rounded,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PlanEditorScreen(
                          patientName: patient.name,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF7C5CFF).withValues(alpha: 0.12),
                  border: Border.all(
                    color: const Color(0xFF7C5CFF).withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      color: Color(0xFF7C5CFF),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      patient.injuryType,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _statusColor,
                            boxShadow: [
                              BoxShadow(
                                color: _statusColor.withValues(alpha: 0.6),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _statusLabel,
                          style: TextStyle(
                            fontSize: 13,
                            color: _statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          patient.nextSession,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.white.withValues(alpha: 0.35),
        letterSpacing: 1.5,
      ),
    );
  }
}

class _TelemetryCell extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _TelemetryCell({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.12),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  final int index;
  final String name;
  final String reps;
  final String rest;

  const _PlanRow({
    required this.index,
    required this.name,
    required this.reps,
    required this.rest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7C5CFF).withValues(alpha: 0.15),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7C5CFF),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            reps,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              rest,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C5CFF), Color(0xFF5A3FCC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C5CFF).withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

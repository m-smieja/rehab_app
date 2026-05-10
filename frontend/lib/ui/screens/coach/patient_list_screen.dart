import 'package:flutter/material.dart';
import 'package:rehab_app/ui/screens/coach/patient_detail_screen.dart';

enum PatientStatus { active, missedSessions, reportedPain }

class PatientData {
  final String id;
  final String name;
  final String injuryType;
  final PatientStatus status;
  final String nextSession;
  final int completionRate;

  const PatientData({
    required this.id,
    required this.name,
    required this.injuryType,
    required this.status,
    required this.nextSession,
    required this.completionRate,
  });
}

class PatientListScreen extends StatelessWidget {
  const PatientListScreen({super.key});

  static const _mockPatients = [
    PatientData(
      id: '1',
      name: 'Alex Johnson',
      injuryType: 'Post-ACL Surgery',
      status: PatientStatus.active,
      nextSession: 'Today, 3:00 PM',
      completionRate: 87,
    ),
    PatientData(
      id: '2',
      name: 'Maria Garcia',
      injuryType: 'Rotator Cuff Repair',
      status: PatientStatus.reportedPain,
      nextSession: 'Tomorrow, 10:00 AM',
      completionRate: 72,
    ),
    PatientData(
      id: '3',
      name: 'James Chen',
      injuryType: 'Lower Back Rehab',
      status: PatientStatus.missedSessions,
      nextSession: 'Fri, 2:00 PM',
      completionRate: 45,
    ),
    PatientData(
      id: '4',
      name: 'Sarah Williams',
      injuryType: 'Ankle Sprain Recovery',
      status: PatientStatus.active,
      nextSession: 'Today, 5:00 PM',
      completionRate: 93,
    ),
    PatientData(
      id: '5',
      name: 'David Kim',
      injuryType: 'Post-Hip Replacement',
      status: PatientStatus.active,
      nextSession: 'Thu, 11:00 AM',
      completionRate: 78,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [Color(0xFF2A1B54), Color(0xFF0F172A), Color(0xFF05050A)],
          center: Alignment.topLeft,
          radius: 1.5,
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MY PATIENTS',
                    style: textTheme.displayLarge?.copyWith(fontSize: 44),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_mockPatients.length} active cases',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _StatusLegend(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                itemCount: _mockPatients.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final patient = _mockPatients[index];
                  return _PatientCard(
                    patient: patient,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PatientDetailScreen(patient: patient),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _dot(const Color(0xFF30E070)),
          const SizedBox(width: 6),
          Text(
            'Active',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(width: 16),
          _dot(const Color(0xFFFFC947)),
          const SizedBox(width: 6),
          Text(
            'Pain Reported',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(width: 16),
          _dot(const Color(0xFFFF4B55)),
          const SizedBox(width: 6),
          Text(
            'Missed Sessions',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      );
}

class _PatientCard extends StatelessWidget {
  final PatientData patient;
  final VoidCallback onTap;

  const _PatientCard({required this.patient, required this.onTap});

  Color get _statusColor => switch (patient.status) {
        PatientStatus.active => const Color(0xFF30E070),
        PatientStatus.missedSessions => const Color(0xFFFF4B55),
        PatientStatus.reportedPain => const Color(0xFFFFC947),
      };

  String get _statusLabel => switch (patient.status) {
        PatientStatus.active => 'Active',
        PatientStatus.missedSessions => 'Missed',
        PatientStatus.reportedPain => 'Pain',
      };

  String get _initials =>
      patient.name.split(' ').map((w) => w[0]).take(2).join();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const borderRadius = BorderRadius.all(Radius.circular(20));

    return Material(
      color: Colors.white.withValues(alpha: 0.03),
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: const Color(0xFF7C5CFF).withValues(alpha: 0.08),
        highlightColor: Colors.white.withValues(alpha: 0.02),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              _Avatar(initials: _initials, statusColor: _statusColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            patient.name,
                            style: textTheme.headlineMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _StatusPill(
                          label: _statusLabel,
                          color: _statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      patient.injuryType,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          patient.nextSession,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                        const Spacer(),
                        _CompletionBadge(rate: patient.completionRate),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.18),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  final Color statusColor;

  const _Avatar({required this.initials, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF7C5CFF).withValues(alpha: 0.12),
            border: Border.all(
              color: const Color(0xFF7C5CFF).withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: Color(0xFF7C5CFF),
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 1,
          right: 1,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor,
              border: Border.all(
                color: const Color(0xFF05050A),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.6),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _CompletionBadge extends StatelessWidget {
  final int rate;

  const _CompletionBadge({required this.rate});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle_outline_rounded,
          size: 12,
          color: Colors.white.withValues(alpha: 0.3),
        ),
        const SizedBox(width: 4),
        Text(
          '$rate%',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.4),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

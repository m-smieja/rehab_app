import 'package:flutter/material.dart';

class PlanEditorScreen extends StatefulWidget {
  final String? patientName;

  const PlanEditorScreen({super.key, this.patientName});

  @override
  State<PlanEditorScreen> createState() => _PlanEditorScreenState();
}

class _PlanEditorScreenState extends State<PlanEditorScreen> {
  final List<_ExerciseEntry> _exercises = [];

  static const _exerciseLibrary = [
    'Push-ups',
    'Squats',
    'Lunges',
    'Plank',
    'Leg Press',
    'Hamstring Curl',
    'Calf Raises',
    'Hip Abduction',
    'Hip Extension',
    'Single-Leg Balance',
    'Step-ups',
    'Glute Bridge',
    'Dead Bug',
    'Bird Dog',
    'Shoulder Press',
    'Lateral Raises',
    'Rotator Cuff External Rotation',
    'Bicep Curl',
    'Tricep Extension',
    'Lat Pulldown',
    'Seated Row',
    'Hip Flexor Stretch',
    'Ankle Circles',
    'Quad Stretch',
    'Calf Stretch',
  ];

  @override
  void dispose() {
    for (final e in _exercises) {
      e.dispose();
    }
    super.dispose();
  }

  void _addExercise(String name) {
    setState(() => _exercises.add(_ExerciseEntry(name)));
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises[index].dispose();
      _exercises.removeAt(index);
    });
  }

  void _showExerciseSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExerciseSearchSheet(
        library: _exerciseLibrary,
        onSelect: (name) {
          Navigator.of(context).pop();
          _addExercise(name);
        },
      ),
    );
  }

  void _sendPlan() {
    final name = widget.patientName ?? 'patient';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Plan sent to $name (${_exercises.length} exercises)',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF7C5CFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sendLabel = widget.patientName != null
        ? 'SEND TO ${widget.patientName!.split(' ').first.toUpperCase()}'
        : 'SEND TO PATIENT';

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
          child: Column(
            children: [
              _buildHeader(context, textTheme),
              Expanded(
                child: _exercises.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        itemCount: _exercises.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => _ExerciseCard(
                          entry: _exercises[i],
                          index: i + 1,
                          onRemove: () => _removeExercise(i),
                        ),
                      ),
              ),
              _buildBottomBar(sendLabel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white.withValues(alpha: 0.7),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PLAN BUILDER',
                  style: textTheme.displayLarge?.copyWith(fontSize: 32),
                ),
                if (widget.patientName != null)
                  Text(
                    widget.patientName!,
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF7C5CFF).withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_circle_outline_rounded,
            size: 64,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          const SizedBox(height: 16),
          Text(
            'No exercises added yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Add Exercise" to build the plan',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(String sendLabel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _OutlineButton(
              label: 'ADD EXERCISE',
              icon: Icons.add_rounded,
              onTap: _showExerciseSearch,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _FilledButton(
              label: sendLabel,
              icon: Icons.send_rounded,
              enabled: _exercises.isNotEmpty,
              onTap: _exercises.isNotEmpty ? _sendPlan : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseEntry {
  final String name;
  final TextEditingController setsCtrl;
  final TextEditingController repsCtrl;
  final TextEditingController restCtrl;
  final TextEditingController notesCtrl;

  _ExerciseEntry(this.name)
      : setsCtrl = TextEditingController(text: '3'),
        repsCtrl = TextEditingController(text: '10'),
        restCtrl = TextEditingController(text: '60'),
        notesCtrl = TextEditingController();

  void dispose() {
    setsCtrl.dispose();
    repsCtrl.dispose();
    restCtrl.dispose();
    notesCtrl.dispose();
  }
}

class _ExerciseCard extends StatelessWidget {
  final _ExerciseEntry entry;
  final int index;
  final VoidCallback onRemove;

  const _ExerciseCard({
    required this.entry,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF7C5CFF).withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  entry.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _NumberInput(
                label: 'Sets',
                controller: entry.setsCtrl,
              ),
              const SizedBox(width: 10),
              _NumberInput(
                label: 'Reps',
                controller: entry.repsCtrl,
              ),
              const SizedBox(width: 10),
              _NumberInput(
                label: 'Rest (s)',
                controller: entry.restCtrl,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _NotesInput(controller: entry.notesCtrl),
        ],
      ),
    );
  }
}

class _NumberInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _NumberInput({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.35),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 10,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF7C5CFF),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesInput extends StatelessWidget {
  final TextEditingController controller;

  const _NotesInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Coach Notes',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.35),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: 2,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Focus on form, keep core engaged...',
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.2),
              fontSize: 13,
            ),
            isDense: true,
            contentPadding: const EdgeInsets.all(12),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.04),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF7C5CFF),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExerciseSearchSheet extends StatefulWidget {
  final List<String> library;
  final ValueChanged<String> onSelect;

  const _ExerciseSearchSheet({
    required this.library,
    required this.onSelect,
  });

  @override
  State<_ExerciseSearchSheet> createState() => _ExerciseSearchSheetState();
}

class _ExerciseSearchSheetState extends State<_ExerciseSearchSheet> {
  final _searchCtrl = TextEditingController();
  late List<String> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.library;
    _searchCtrl.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.library
          : widget.library
              .where((e) => e.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: Color(0xFF7C5CFF), width: 1),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ADD EXERCISE',
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchCtrl,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Search exercises...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.white.withValues(alpha: 0.3),
                        size: 20,
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF7C5CFF),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                itemCount: _filtered.length,
                itemBuilder: (context, i) {
                  final name = _filtered[i];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => widget.onSelect(name),
                      borderRadius: BorderRadius.circular(12),
                      splashColor: const Color(0xFF7C5CFF)
                          .withValues(alpha: 0.1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.fitness_center_rounded,
                              size: 18,
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.add_rounded,
                              size: 18,
                              color: const Color(0xFF7C5CFF)
                                  .withValues(alpha: 0.6),
                            ),
                          ],
                        ),
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

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlineButton({
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
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF7C5CFF).withValues(alpha: 0.4),
            ),
            color: const Color(0xFF7C5CFF).withValues(alpha: 0.08),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF7C5CFF), size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF7C5CFF),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilledButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  const _FilledButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: enabled
                ? const LinearGradient(
                    colors: [Color(0xFF7C5CFF), Color(0xFF5A3FCC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: enabled ? null : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: const Color(0xFF7C5CFF).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: enabled
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.25),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: enabled
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.25),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class _ReviewItem {
  final String patientName;
  final String exercise;
  final String timeAgo;
  final Color accentColor;
  final String duration;

  const _ReviewItem({
    required this.patientName,
    required this.exercise,
    required this.timeAgo,
    required this.accentColor,
    required this.duration,
  });
}

const _pendingReviews = [
  _ReviewItem(
    patientName: 'Alex Johnson',
    exercise: 'Squats',
    timeAgo: '2h ago',
    accentColor: Color(0xFF7C5CFF),
    duration: '0:42',
  ),
  _ReviewItem(
    patientName: 'Maria Garcia',
    exercise: 'Shoulder Press',
    timeAgo: '4h ago',
    accentColor: Color(0xFF3D8EFF),
    duration: '0:31',
  ),
  _ReviewItem(
    patientName: 'Sarah Williams',
    exercise: 'Single-Leg Balance',
    timeAgo: 'Yesterday',
    accentColor: Color(0xFF30E070),
    duration: '1:05',
  ),
  _ReviewItem(
    patientName: 'David Kim',
    exercise: 'Hip Extension',
    timeAgo: 'Yesterday',
    accentColor: Color(0xFFFFC947),
    duration: '0:58',
  ),
  _ReviewItem(
    patientName: 'Alex Johnson',
    exercise: 'Lunges',
    timeAgo: '2 days ago',
    accentColor: Color(0xFF7C5CFF),
    duration: '0:37',
  ),
  _ReviewItem(
    patientName: 'James Chen',
    exercise: 'Dead Bug',
    timeAgo: '2 days ago',
    accentColor: Color(0xFFFF4B55),
    duration: '0:49',
  ),
];

class VideoReviewScreen extends StatelessWidget {
  const VideoReviewScreen({super.key});

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
                    'VIDEO REVIEW',
                    style: textTheme.displayLarge?.copyWith(fontSize: 40),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFF4B55),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x99FF4B55),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_pendingReviews.length} pending reviews',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: _pendingReviews.length,
                itemBuilder: (context, i) => _VideoThumbnail(
                  item: _pendingReviews[i],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          _ReviewDetailScreen(item: _pendingReviews[i]),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoThumbnail extends StatelessWidget {
  final _ReviewItem item;
  final VoidCallback onTap;

  const _VideoThumbnail({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: item.accentColor.withValues(alpha: 0.1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.accentColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ThumbnailPreview(item: item),
              ),
              _ThumbnailInfo(item: item),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThumbnailPreview extends StatelessWidget {
  final _ReviewItem item;

  const _ThumbnailPreview({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
        gradient: LinearGradient(
          colors: [
            item.accentColor.withValues(alpha: 0.25),
            const Color(0xFF05050A),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.sports_gymnastics_rounded,
            size: 40,
            color: item.accentColor.withValues(alpha: 0.25),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.4),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: Colors.white.withValues(alpha: 0.9),
              size: 26,
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.duration,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF4B55),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF4B55).withValues(alpha: 0.6),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThumbnailInfo extends StatelessWidget {
  final _ReviewItem item;

  const _ThumbnailInfo({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.exercise,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            item.patientName.split(' ').first,
            style: TextStyle(
              fontSize: 12,
              color: item.accentColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            item.timeAgo,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewDetailScreen extends StatefulWidget {
  final _ReviewItem item;

  const _ReviewDetailScreen({required this.item});

  @override
  State<_ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<_ReviewDetailScreen> {
  final _feedbackCtrl = TextEditingController();
  bool _isRecording = false;

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() => _isRecording = !_isRecording);
    if (_isRecording) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _isRecording = false);
      });
    }
  }

  void _submitFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Feedback sent to patient',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF30E070),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final item = widget.item;

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.exercise,
                            style: textTheme.headlineMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            item.patientName,
                            style: TextStyle(
                              fontSize: 13,
                              color: item.accentColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      item.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _VideoPlayerPlaceholder(item: item),
                const SizedBox(height: 24),
                _SectionHeader(label: 'TEXT FEEDBACK'),
                const SizedBox(height: 10),
                TextField(
                  controller: _feedbackCtrl,
                  maxLines: 4,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Great form on the descent! Watch your knee alignment on the way up — keep it tracking over your second toe...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.2),
                      fontSize: 13,
                      height: 1.5,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.04),
                    contentPadding: const EdgeInsets.all(16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF7C5CFF),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _VideoFeedbackButton(
                  isRecording: _isRecording,
                  onTap: _toggleRecording,
                ),
                const SizedBox(height: 14),
                _SubmitFeedbackButton(onTap: _submitFeedback),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoPlayerPlaceholder extends StatelessWidget {
  final _ReviewItem item;

  const _VideoPlayerPlaceholder({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            item.accentColor.withValues(alpha: 0.2),
            const Color(0xFF05050A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: item.accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.sports_gymnastics_rounded,
            size: 80,
            color: item.accentColor.withValues(alpha: 0.12),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.45),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          Positioned(
            bottom: 14,
            left: 14,
            right: 14,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.videocam_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Video placeholder · ${item.duration}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '720p',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

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

class _VideoFeedbackButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onTap;

  const _VideoFeedbackButton({
    required this.isRecording,
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
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isRecording
                ? const Color(0xFFFF4B55).withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.04),
            border: Border.all(
              color: isRecording
                  ? const Color(0xFFFF4B55).withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isRecording
                      ? Icons.stop_circle_rounded
                      : Icons.videocam_rounded,
                  key: ValueKey(isRecording),
                  size: 18,
                  color: isRecording
                      ? const Color(0xFFFF4B55)
                      : Colors.white.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isRecording ? 'RECORDING... TAP TO STOP' : 'RECORD VIDEO FEEDBACK',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isRecording
                      ? const Color(0xFFFF4B55)
                      : Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubmitFeedbackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SubmitFeedbackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C5CFF), Color(0xFF5A3FCC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C5CFF).withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.send_rounded, color: Colors.white, size: 16),
              SizedBox(width: 10),
              Text(
                'SEND FEEDBACK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
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

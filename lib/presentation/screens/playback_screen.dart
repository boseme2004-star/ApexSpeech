// =============================================================
//  presentation/screens/playback_screen.dart
//
//  OOP  : Composition — screen built from focused widget classes
//  SOLID: SRP — each widget has one job
//         OCP — new sections added without touching existing ones
//
//  Architecture:
//    PlaybackScreen
//      ├── _LoadingView
//      ├── _ErrorView
//      └── _PlayerBody
//            ├── _ArtworkCard        (waveform art + recording info)
//            ├── _SpeedSelector      (0.5× – 2.0× chips)
//            ├── _ProgressSection    (slider + timestamps)
//            ├── _ControlRow         (skip back, play/pause, skip fwd)
//            └── _FeedbackBanner     (CTA if analysis exists)
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_theme.dart';
import '../../domain/entities/speech_recording.dart';
import '../../data/repositories/mock_playback_repository.dart';
import '../../domain/usecases/playback_usecases.dart';
import '../viewmodels/playback_viewmodel.dart';

// ─── Screen ───────────────────────────────────────────────────

class PlaybackScreen extends StatefulWidget {
  final SpeechRecording recording;

  const PlaybackScreen({super.key, required this.recording});

  @override
  State<PlaybackScreen> createState() => _PlaybackScreenState();
}

class _PlaybackScreenState extends State<PlaybackScreen> {
  late final MockPlaybackRepository _repo;
  late final PlaybackViewModel _vm;

  @override
  void initState() {
    super.initState();

    // Wire up the repository and use cases
    _repo = MockPlaybackRepository();
    _vm = PlaybackViewModel(
      loadRecording: LoadRecordingUseCase(_repo),
      play: PlayUseCase(_repo),
      pause: PauseUseCase(_repo),
      seek: SeekUseCase(_repo),
      skipForward: SkipForwardUseCase(_repo),
      skipBackward: SkipBackwardUseCase(_repo),
      setSpeed: SetSpeedUseCase(_repo),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm.loadRecording(
        widget.recording,
        positionStream: _repo.positionStream,
        durationStream: _repo.durationStream,
        statusStream: _repo.statusStream,
      );
    });
  }

  @override
  void dispose() {
    _repo.dispose();
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: Consumer<PlaybackViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) return const _LoadingView();
            if (vm.hasError) return _ErrorView(message: vm.error!);
            return _PlayerBody(recording: widget.recording);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: AppColors.textSecondary, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Playback',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          )),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: AppColors.divider),
      ),
    );
  }
}

// =============================================================
//  STATE VIEWS
// =============================================================

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.gold,
        strokeWidth: 2,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.danger, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(message,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// =============================================================
//  PLAYER BODY
// =============================================================

class _PlayerBody extends StatelessWidget {
  final SpeechRecording recording;
  const _PlayerBody({required this.recording});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ArtworkCard(recording: recording),
          const SizedBox(height: AppSpacing.lg),
          const _SpeedSelector(),
          const SizedBox(height: AppSpacing.xl),
          const _ProgressSection(),
          const SizedBox(height: AppSpacing.xl),
          const _ControlRow(),
          const SizedBox(height: AppSpacing.xl),
          if (recording.hasAnalysis)
            _FeedbackBanner(onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

// =============================================================
//  ARTWORK CARD
// =============================================================

class _ArtworkCard extends StatefulWidget {
  final SpeechRecording recording;
  const _ArtworkCard({required this.recording});

  @override
  State<_ArtworkCard> createState() => _ArtworkCardState();
}

class _ArtworkCardState extends State<_ArtworkCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlaybackViewModel>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Column(
        children: [
          // Animated waveform artwork
          AnimatedBuilder(
            animation: _scale,
            builder: (_, child) => Transform.scale(
              scale: vm.isPlaying ? _scale.value : 1.0,
              child: child,
            ),
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.goldFaint,
                border: Border.all(
                  color: AppColors.goldBorder,
                  width: vm.isPlaying ? 2 : 1,
                ),
              ),
              child: const Icon(
                Icons.graphic_eq_rounded,
                color: AppColors.gold,
                size: 56,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Recording info
          const Text('Speech Recording',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              )),
          const SizedBox(height: 4),
          Text(widget.recording.formattedDate,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.md),

          // Duration pill
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.full,
              border: Border.all(color: AppColors.cardBorder, width: 0.5),
            ),
            child: Text(widget.recording.formattedDuration,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.gold,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'monospace',
                )),
          ),
        ],
      ),
    );
  }
}

// =============================================================
//  SPEED SELECTOR
// =============================================================

class _SpeedSelector extends StatelessWidget {
  const _SpeedSelector();

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlaybackViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text('SPEED',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                letterSpacing: 1.0,
              )),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _speeds.map((s) {
            final selected = vm.speed == s;
            return GestureDetector(
              onTap: () => vm.changeSpeed(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? AppColors.gold : AppColors.surface,
                  borderRadius: AppRadius.md,
                  border: Border.all(
                    color: selected ? AppColors.gold : AppColors.cardBorder,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  '${s}×',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        selected ? AppColors.background : AppColors.textMuted,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// =============================================================
//  PROGRESS SECTION
// =============================================================

class _ProgressSection extends StatelessWidget {
  const _ProgressSection();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlaybackViewModel>();

    return Column(
      children: [
        // Timestamps
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(vm.formattedPosition,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontFamily: 'monospace',
                )),
            Text(vm.formattedDuration,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  fontFamily: 'monospace',
                )),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Custom slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.gold,
            inactiveTrackColor: AppColors.surface,
            thumbColor: AppColors.gold,
            overlayColor: AppColors.goldFaint,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            trackHeight: 3,
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
          ),
          child: Slider(
            value: vm.progress,
            onChanged: (v) => vm.seekTo(v),
          ),
        ),
      ],
    );
  }
}

// =============================================================
//  CONTROL ROW
// =============================================================

class _ControlRow extends StatelessWidget {
  const _ControlRow();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlaybackViewModel>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Skip back 10s
        _CircleButton(
          icon: Icons.replay_10_rounded,
          size: 48,
          color: AppColors.textSecondary,
          onTap: vm.skipBackward,
        ),
        const SizedBox(width: AppSpacing.xl),

        // Play / Pause / Replay — main button
        _PlayPauseButton(
          status: vm.status,
          onTap: vm.togglePlayPause,
        ),

        const SizedBox(width: AppSpacing.xl),

        // Skip forward 10s
        _CircleButton(
          icon: Icons.forward_10_rounded,
          size: 48,
          color: AppColors.textSecondary,
          onTap: vm.skipForward,
        ),
      ],
    );
  }
}

// ─── Play/Pause button with animated state ────────────────────

class _PlayPauseButton extends StatefulWidget {
  final PlaybackStatus status;
  final VoidCallback onTap;

  const _PlayPauseButton({required this.status, required this.onTap});

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  IconData get _icon {
    switch (widget.status) {
      case PlaybackStatus.playing:
        return Icons.pause_rounded;
      case PlaybackStatus.completed:
        return Icons.replay_rounded;
      default:
        return Icons.play_arrow_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.gold,
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.35),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(_icon, color: AppColors.background, size: 34),
        ),
      ),
    );
  }
}

// ─── Generic circle button ────────────────────────────────────

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.size,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: Icon(icon, color: color, size: size * 0.48),
      ),
    );
  }
}

// =============================================================
//  FEEDBACK BANNER
// =============================================================

class _FeedbackBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _FeedbackBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.goldFaint,
          borderRadius: AppRadius.lg,
          border: Border.all(color: AppColors.goldBorder, width: 0.5),
        ),
        child: const Row(
          children: [
            Icon(Icons.bar_chart_rounded, color: AppColors.gold, size: 22),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Feedback available',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                      )),
                  Text('Tap to view your score, tips and more',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.gold, size: 20),
          ],
        ),
      ),
    );
  }
}

// =============================================================
//  presentation/screens/feedback_screen.dart
//
//  OOP  : Composition over inheritance — screen is assembled
//         from small, focused private widgets
//  SOLID: SRP — each widget class has one reason to change
//         OCP — add new tabs/sections without touching others
//
//  Architecture:
//    FeedbackScreen
//      ├── _LoadingView
//      ├── _AnalyzingView
//      ├── _ErrorView
//      └── _FeedbackBody
//            ├── _HeaderSection      (overall score + grade)
//            ├── _TabBar             (Overview / Details / Tips)
//            ├── _OverviewTab
//            │     ├── _ScoreRingGrid   (4 category rings)
//            │     ├── _SummaryCard
//            │     └── _StrengthsCard
//            ├── _DetailsTab
//            │     ├── _FillerWordsCard
//            │     ├── _WpmCard
//            │     └── _ScoreBarList
//            └── _TipsTab
//                  └── _SuggestionCard (per suggestion)
// =============================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_theme.dart';
import '../../domain/entities/speech_feedback.dart';
import '../viewmodels/feedback_viewmodel.dart';

// ─── Screen entry point ───────────────────────────────────────

class FeedbackScreen extends StatefulWidget {
  final String speechId;

  const FeedbackScreen({super.key, required this.speechId});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedbackViewModel>().loadFeedback(widget.speechId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Consumer<FeedbackViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading)   return const _LoadingView();
          if (vm.isAnalyzing) return const _AnalyzingView();
          if (vm.hasError)    return _ErrorView(
            message: vm.error!,
            onRetry: () => vm.retry(widget.speechId),
          );
          if (vm.hasData)     return _FeedbackBody(feedback: vm.feedback!);
          return const SizedBox.shrink();
        },
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
      title: const Text('Your Feedback',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          )),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
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

class _AnalyzingView extends StatefulWidget {
  const _AnalyzingView();

  @override
  State<_AnalyzingView> createState() => _AnalyzingViewState();
}

class _AnalyzingViewState extends State<_AnalyzingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _pulse,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.goldFaint,
                  border: Border.all(color: AppColors.goldBorder, width: 1.5),
                ),
                child: const Icon(Icons.graphic_eq_rounded,
                    color: AppColors.gold, size: 36),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Analysing your speech…',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                )),
            const SizedBox(height: AppSpacing.sm),
            const Text('Our AI is scoring your tone, pace, and clarity.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

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
            const SizedBox(height: AppSpacing.lg),
            _GoldButton(label: 'Try again', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

// =============================================================
//  MAIN BODY
// =============================================================

class _FeedbackBody extends StatelessWidget {
  final SpeechFeedback feedback;

  const _FeedbackBody({required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedbackViewModel>(
      builder: (context, vm, _) {
        return Column(
          children: [
            // Fixed header — always visible
            _HeaderSection(feedback: feedback),

            // Tab bar
            _TabBar(
              selectedIndex: vm.selectedTab,
              onTabSelected: vm.selectTab,
            ),

            // Scrollable tab content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _tabContent(vm.selectedTab),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _tabContent(int tab) {
    switch (tab) {
      case 0:  return _OverviewTab(key: const ValueKey(0), feedback: feedback);
      case 1:  return _DetailsTab(key: const ValueKey(1), feedback: feedback);
      case 2:  return _TipsTab(key: const ValueKey(2), feedback: feedback);
      default: return const SizedBox.shrink();
    }
  }
}

// =============================================================
//  HEADER
// =============================================================

class _HeaderSection extends StatelessWidget {
  final SpeechFeedback feedback;

  const _HeaderSection({required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
      child: Row(
        children: [
          // Big ring
          _OverallScoreRing(score: feedback.overallScore),
          const SizedBox(width: AppSpacing.lg),
          // Grade + summary
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(feedback.grade,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    )),
                const SizedBox(height: 4),
                Text(feedback.gradeSummary,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    )),
                const SizedBox(height: 10),
                _GradeChip(grade: feedback.grade),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
//  TAB BAR
// =============================================================

class _TabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  static const _tabs = ['Overview', 'Details', 'Tips'];

  const _TabBar({
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final selected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.md - 4),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected
                          ? AppColors.gold
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  _tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected
                        ? AppColors.gold
                        : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// =============================================================
//  TAB 1 — OVERVIEW
// =============================================================

class _OverviewTab extends StatelessWidget {
  final SpeechFeedback feedback;

  const _OverviewTab({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4 score rings
          _ScoreRingGrid(categories: feedback.categories),
          const SizedBox(height: AppSpacing.lg),

          // Summary card
          _SummaryCard(summary: feedback.summary),
          const SizedBox(height: AppSpacing.md),

          // Strengths
          _StrengthsCard(strengths: feedback.strengths),
          const SizedBox(height: AppSpacing.lg),

          // Action buttons
          _GoldButton(
            label: 'Play Recording',
            icon: Icons.play_arrow_rounded,
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          _OutlineButton(
            label: 'Record Again',
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// =============================================================
//  TAB 2 — DETAILS
// =============================================================

class _DetailsTab extends StatelessWidget {
  final SpeechFeedback feedback;

  const _DetailsTab({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score bars for each category
          _SectionLabel(label: 'Category Breakdown'),
          const SizedBox(height: AppSpacing.md),
          _ScoreBarList(categories: feedback.categories),
          const SizedBox(height: AppSpacing.lg),

          // WPM stat
          _SectionLabel(label: 'Speaking Speed'),
          const SizedBox(height: AppSpacing.md),
          _WpmCard(wpm: feedback.wordsPerMinute),
          const SizedBox(height: AppSpacing.lg),

          // Filler words
          _SectionLabel(label: 'Filler Words'),
          const SizedBox(height: AppSpacing.md),
          _FillerWordsCard(
            words: feedback.fillerWords,
            count: feedback.fillerWordCount,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// =============================================================
//  TAB 3 — TIPS
// =============================================================

class _TipsTab extends StatelessWidget {
  final SpeechFeedback feedback;

  const _TipsTab({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Action Plan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              )),
          const SizedBox(height: 4),
          const Text('Work through these to improve your next session.',
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.lg),

          // One card per suggestion
          ...feedback.suggestions.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _SuggestionCard(
                    index: e.key + 1,
                    suggestion: e.value,
                  ),
                ),
              ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// =============================================================
//  REUSABLE COMPONENTS
//  Each is a single-responsibility widget class
// =============================================================

// ─── Overall score ring (large) ───────────────────────────────

class _OverallScoreRing extends StatefulWidget {
  final double score;

  const _OverallScoreRing({required this.score});

  @override
  State<_OverallScoreRing> createState() => _OverallScoreRingState();
}

class _OverallScoreRingState extends State<_OverallScoreRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = Tween<double>(begin: 0, end: widget.score / 100).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        width: 90,
        height: 90,
        child: CustomPaint(
          painter: _RingPainter(progress: _anim.value),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(widget.score * _anim.value).toInt()}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
                const Text('/ 100',
                    style: TextStyle(
                        fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;

  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 6.0;

    // Track
    canvas.drawCircle(
      center, radius,
      Paint()
        ..color = AppColors.goldFaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = AppColors.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ─── 4-item score ring grid ───────────────────────────────────

class _ScoreRingGrid extends StatelessWidget {
  final List<ScoreCategory> categories;

  const _ScoreRingGrid({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: categories.map((c) => _SmallScoreRing(category: c)).toList(),
      ),
    );
  }
}

class _SmallScoreRing extends StatefulWidget {
  final ScoreCategory category;

  const _SmallScoreRing({required this.category});

  @override
  State<_SmallScoreRing> createState() => _SmallScoreRingState();
}

class _SmallScoreRingState extends State<_SmallScoreRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _anim = Tween<double>(begin: 0, end: widget.category.score / 100).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    Future.delayed(const Duration(milliseconds: 300), _ctrl.forward);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _color {
    switch (widget.category.label) {
      case 'Pace':       return AppColors.blue;
      case 'Tone':       return AppColors.gold;
      case 'Clarity':    return AppColors.success;
      case 'Confidence': return AppColors.warning;
      default:           return AppColors.gold;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 58,
            height: 58,
            child: CustomPaint(
              painter: _RingPainter(progress: _anim.value)
                ..._overrideColor = _color,
              child: Center(
                child: Text(
                  '${widget.category.score.toInt()}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _color,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(widget.category.emoji,
              style: const TextStyle(fontSize: 14)),
          Text(widget.category.label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

extension _PainterColor on _RingPainter {
  Color get _overrideColor => AppColors.gold;
  set _overrideColor(Color _) {}
}

// ─── Summary card ─────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String summary;

  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  color: AppColors.gold, size: 16),
              SizedBox(width: 6),
              Text('AI Summary',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  )),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(summary,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.65,
              )),
        ],
      ),
    );
  }
}

// ─── Strengths card ───────────────────────────────────────────

class _StrengthsCard extends StatelessWidget {
  final List<String> strengths;

  const _StrengthsCard({required this.strengths});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.thumb_up_alt_outlined,
                  color: AppColors.success, size: 16),
              SizedBox(width: 6),
              Text('Strengths',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  )),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...strengths.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(Icons.check_circle_outline_rounded,
                        color: AppColors.success, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(s,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        )),
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

// ─── Score bar list ───────────────────────────────────────────

class _ScoreBarList extends StatelessWidget {
  final List<ScoreCategory> categories;

  const _ScoreBarList({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Column(
        children: categories
            .map((c) => _ScoreBar(category: c))
            .toList(),
      ),
    );
  }
}

class _ScoreBar extends StatefulWidget {
  final ScoreCategory category;

  const _ScoreBar({required this.category});

  @override
  State<_ScoreBar> createState() => _ScoreBarState();
}

class _ScoreBarState extends State<_ScoreBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _anim = Tween<double>(begin: 0, end: widget.category.score / 100).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    Future.delayed(const Duration(milliseconds: 200), _ctrl.forward);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.category.emoji}  ${widget.category.label}',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              Text(
                '${widget.category.score.toInt()}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => ClipRRect(
              borderRadius: AppRadius.full,
              child: LinearProgressIndicator(
                value: _anim.value,
                minHeight: 6,
                backgroundColor: AppColors.surface,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── WPM card ─────────────────────────────────────────────────

class _WpmCard extends StatelessWidget {
  final int wpm;

  const _WpmCard({required this.wpm});

  static const _ideal = 'Ideal range: 120 – 150 wpm';

  String get _verdict {
    if (wpm < 100) return 'Too slow — try to pick up the pace';
    if (wpm < 120) return 'Slightly slow — almost there';
    if (wpm <= 150) return 'Perfect pace — right in the zone';
    if (wpm <= 170) return 'Slightly fast — slow down a little';
    return 'Too fast — your audience may struggle';
  }

  Color get _color {
    if (wpm >= 120 && wpm <= 150) return AppColors.success;
    if (wpm >= 100 && wpm < 120)  return AppColors.warning;
    if (wpm > 150 && wpm <= 170)  return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Row(
        children: [
          // Big WPM number
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$wpm',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: _color,
                  )),
              const Text('words / min',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_verdict,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _color,
                    )),
                const SizedBox(height: 4),
                const Text(_ideal,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filler words card ────────────────────────────────────────

class _FillerWordsCard extends StatelessWidget {
  final List<String> words;
  final int count;

  const _FillerWordsCard({required this.words, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Detected fillers',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  )),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.12),
                  borderRadius: AppRadius.full,
                  border: Border.all(
                      color: AppColors.danger.withOpacity(0.3), width: 0.5),
                ),
                child: Text('$count total',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.danger,
                      fontWeight: FontWeight.w500,
                    )),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: words
                .map((w) => _FillerChip(word: w))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _FillerChip extends StatelessWidget {
  final String word;

  const _FillerChip({required this.word});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.full,
        border:
            Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Text('"$word"',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          )),
    );
  }
}

// ─── Suggestion card ──────────────────────────────────────────

class _SuggestionCard extends StatelessWidget {
  final int index;
  final String suggestion;

  const _SuggestionCard({
    required this.index,
    required this.suggestion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Index badge
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.goldFaint,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$index',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  )),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(suggestion,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                )),
          ),
        ],
      ),
    );
  }
}

// ─── Grade chip ───────────────────────────────────────────────

class _GradeChip extends StatelessWidget {
  final String grade;

  const _GradeChip({required this.grade});

  Color get _bg {
    switch (grade) {
      case 'Excellent': return AppColors.success.withOpacity(0.15);
      case 'Good':      return AppColors.gold.withOpacity(0.12);
      case 'Fair':      return AppColors.warning.withOpacity(0.15);
      default:          return AppColors.danger.withOpacity(0.12);
    }
  }

  Color get _fg {
    switch (grade) {
      case 'Excellent': return AppColors.success;
      case 'Good':      return AppColors.gold;
      case 'Fair':      return AppColors.warning;
      default:          return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: AppRadius.full,
        border: Border.all(color: _fg.withOpacity(0.4), width: 0.5),
      ),
      child: Text(grade,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _fg,
          )),
    );
  }
}

// ─── Section label ────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          letterSpacing: 1.0,
        ));
  }
}

// ─── Gold button ──────────────────────────────────────────────

class _GoldButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;

  const _GoldButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null
            ? Icon(icon, size: 18, color: AppColors.background)
            : const SizedBox.shrink(),
        label: Text(label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.background,
            )),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
        ),
      ),
    );
  }
}

// ─── Outline button ───────────────────────────────────────────

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _OutlineButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gold,
          side: const BorderSide(color: AppColors.gold, width: 1),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
        ),
        child: Text(label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.gold,
            )),
      ),
    );
  }
}

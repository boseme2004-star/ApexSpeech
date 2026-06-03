import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:apex_speech/core/constants/app_constants.dart';
import 'package:apex_speech/core/themes/app_theme.dart';
import 'package:apex_speech/core/utils/validators.dart';
import 'package:apex_speech/domain/entities/speech.dart';
import 'package:apex_speech/presentation/viewmodels/auth_viewmodel.dart';
import 'package:apex_speech/presentation/viewmodels/home_viewmodel.dart';
import 'package:apex_speech/presentation/widgets/common_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  void _loadHistory() {
    final userId = context.read<AuthViewModel>().currentUser?.id;
    if (userId != null) {
      context.read<HomeViewModel>().loadSpeeches(userId);
    }
  }

  Future<void> _handleRecordTap() async {
    final homeVM = context.read<HomeViewModel>();
    final authVM = context.read<AuthViewModel>();
    final userId = authVM.currentUser?.id;

    if (userId == null) return;

    if (homeVM.isRecording) {
      // Stop & upload
      final speech = await homeVM.stopAndUpload(userId);
      if (!mounted) return;
      if (speech != null) {
        Navigator.pushNamed(context, AppConstants.feedbackRoute,
            arguments: speech.id);
      } else if (homeVM.errorMessage != null) {
        _showError(homeVM.errorMessage!);
      }
    } else {
      await homeVM.startRecording();
      if (!mounted) return;
      if (homeVM.errorMessage != null) {
        _showError(homeVM.errorMessage!);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeVM = context.watch<HomeViewModel>();
    final authVM = context.watch<AuthViewModel>();

    return ApexScaffold(
      title: AppConstants.appName,
      actions: [
        IconButton(
          onPressed: () async {
            await authVM.signOut();
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
          },
          icon: const Icon(Icons.logout_rounded, color: AppTheme.textSecondary),
        ),
      ],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ─── Welcome Header ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.pagePadding),
              child: _buildWelcomeHeader(authVM, homeVM),
            ),

            const SizedBox(height: 32),

            // ─── Recording Area ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.pagePadding),
              child: _buildRecordingCard(homeVM),
            ),

            const SizedBox(height: 32),

            // ─── Recent Speeches ──────────────────────────────
            Expanded(
              child: _buildSpeechHistory(homeVM),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(AuthViewModel authVM, HomeViewModel homeVM) {
    final name = authVM.currentUser?.name.split(' ').first ?? 'there';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $name 👋',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 4),
              Text(
                '${authVM.currentUser?.totalRecordings ?? 0} sessions recorded',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: const Icon(Icons.mic_rounded,
              color: AppTheme.goldAccent, size: 28),
        ),
      ],
    );
  }

  Widget _buildRecordingCard(HomeViewModel homeVM) {
    final isRecording = homeVM.isRecording;
    final isProcessing = homeVM.isProcessing;

    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Camera placeholder / posture AI preview area
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.videocam_outlined,
                  color: AppTheme.textMuted,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  'Posture AI — Coming Soon',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Waveform / Duration
          if (isRecording) ...[
            AmplitudeBar(amplitude: homeVM.amplitude),
            const SizedBox(height: 12),
            Text(
              DurationFormatter.format(homeVM.recordingDuration),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.goldAccent,
                    fontFamily: 'monospace',
                  ),
            ),
          ] else if (isProcessing) ...[
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppTheme.goldAccent),
            ),
            const SizedBox(height: 12),
            Text('Uploading & analyzing...',
                style: Theme.of(context).textTheme.bodyMedium),
          ] else ...[
            Text(
              'Tap to begin recording',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],

          const SizedBox(height: 24),

          // Record Button
          GestureDetector(
            onTap: isProcessing ? null : _handleRecordTap,
            child: AnimatedContainer(
              duration: AppConstants.mediumAnimation,
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isRecording ? null : AppTheme.goldGradient,
                color: isRecording ? AppTheme.errorColor : null,
                boxShadow: [
                  BoxShadow(
                    color: (isRecording
                            ? AppTheme.errorColor
                            : AppTheme.goldAccent)
                        .withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                color: isRecording ? Colors.white : AppTheme.primary,
                size: 36,
              ),
            ),
          ).animate(target: isRecording ? 1 : 0).scale(
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05),
                duration: 800.ms,
                curve: Curves.easeInOut,
              ),
        ],
      ),
    );
  }

  Widget _buildSpeechHistory(HomeViewModel homeVM) {
    final speeches = homeVM.speeches;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.pagePadding),
          child: Text(
            'Recent Sessions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 12),
        if (speeches.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.graphic_eq,
                      color: AppTheme.textMuted, size: 48),
                  const SizedBox(height: 12),
                  Text('No recordings yet.\nTap the mic to get started!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.pagePadding),
              itemCount: speeches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _buildSpeechTile(speeches[i]),
            ),
          ),
      ],
    );
  }

  Widget _buildSpeechTile(Speech speech) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.pushNamed(
        context,
        speech.status == SpeechStatus.analyzed
            ? AppConstants.feedbackRoute
            : AppConstants.playbackRoute,
        arguments: speech.id,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: speech.status == SpeechStatus.analyzed
                  ? AppTheme.goldGradient
                  : const LinearGradient(
                      colors: [AppTheme.cardBackground, AppTheme.surfaceColor]),
              shape: BoxShape.circle,
            ),
            child: Icon(
              speech.status == SpeechStatus.analyzed
                  ? Icons.bar_chart_rounded
                  : Icons.graphic_eq,
              color: speech.status == SpeechStatus.analyzed
                  ? AppTheme.primary
                  : AppTheme.textMuted,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session ${speech.createdAt.day}/${speech.createdAt.month}/${speech.createdAt.year}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      speech.duration != null
                          ? DurationFormatter.format(speech.duration!)
                          : '—',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (speech.feedback != null) ...[
                      const Text(' · ',
                          style: TextStyle(color: AppTheme.textMuted)),
                      Text(
                        '${speech.feedback!.overallScore.toInt()}% ${speech.feedback!.grade}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppTheme.goldAccent),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
        ],
      ),
    );
  }
}

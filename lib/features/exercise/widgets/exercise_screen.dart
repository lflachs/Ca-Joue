import 'dart:async';
import 'dart:math' as math;

import 'package:ca_joue/core/content/expression_model.dart';
import 'package:ca_joue/core/content/lesson_names.dart';
import 'package:ca_joue/core/spaced_repetition/review_provider.dart';
import 'package:ca_joue/features/exercise/models/exercise_state.dart';
import 'package:ca_joue/features/exercise/providers/exercise_provider.dart';
import 'package:ca_joue/features/exercise/providers/session_position_provider.dart';
import 'package:ca_joue/features/exercise/widgets/answer_button.dart';
import 'package:ca_joue/features/exercise/widgets/category_strip.dart';
import 'package:ca_joue/features/exercise/widgets/discovery_card_animated.dart';
import 'package:ca_joue/features/exercise/widgets/feedback_card.dart';
import 'package:ca_joue/features/exercise/widgets/gold_badge.dart';
import 'package:ca_joue/features/exercise/widgets/progress_bar.dart';
import 'package:ca_joue/features/exercise/widgets/typing_input.dart';
import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:ca_joue/widgets/cta_button.dart';
import 'package:ca_joue/widgets/dahu.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The main exercise screen for a lesson.
///
/// Watches [exerciseProvider] and renders based on the current
/// [ExerciseState]: discovery -> active -> feedback -> ... -> complete.
class ExerciseScreen extends ConsumerStatefulWidget {
  /// Creates an [ExerciseScreen] for the given [lessonId].
  const ExerciseScreen({
    required this.lessonId,
    this.startIndex = 0,
    super.key,
  });

  /// The kebab-case lesson identifier.
  final String lessonId;

  /// The expression index to start at (0 for new, >0 for resume).
  final int startIndex;

  @override
  ConsumerState<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Timer? _advanceTimer;
  late final AnimationController _dahuController;
  late final Animation<double> _dahuBob;
  late final Animation<double> _dahuTilt;
  bool _hapticFired = false;
  late final TextEditingController _typingController;
  late final FocusNode _typingFocusNode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _typingController = TextEditingController();
    _typingFocusNode = FocusNode();
    _dahuController = AnimationController(
      vsync: this,
      duration: CaJoueAnimations.ambient,
    );

    _dahuBob = Tween<double>(begin: 0, end: -4).animate(
      CurvedAnimation(
        parent: _dahuController,
        curve: CaJoueAnimations.ambientCurve,
      ),
    );

    _dahuTilt =
        Tween<double>(
          begin: 0,
          end: 6 * math.pi / 180,
        ).animate(
          CurvedAnimation(
            parent: _dahuController,
            curve: CaJoueAnimations.ambientCurve,
          ),
        );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _advanceTimer?.cancel();
    _dahuController.dispose();
    _typingController.dispose();
    _typingFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveCurrentPosition();
    }
  }

  /// Returns "Revision" for review mode, else the lesson name.
  String get _lessonDisplayName => widget.lessonId == reviewLessonId
      ? 'Revision'
      : LessonNames.of(widget.lessonId);

  void _saveCurrentPosition() {
    // Review sessions don't persist position.
    if (widget.lessonId == reviewLessonId) return;

    final current = ref
        .read(exerciseProvider(widget.lessonId, widget.startIndex))
        .value;
    if (current == null) return;

    final index = switch (current) {
      ExerciseDiscovery(:final progressIndex) => progressIndex,
      ExerciseActive(:final progressIndex) => progressIndex,
      ExerciseFeedback(:final progressIndex) => progressIndex,
      ExerciseTypingActive(:final progressIndex) => progressIndex,
      ExerciseTypingFeedback(:final progressIndex) => progressIndex,
      ExerciseLoading() || ExerciseComplete() => null,
    };

    if (index != null) {
      unawaited(
        ref
            .read(sessionPositionProvider.notifier)
            .savePosition(widget.lessonId, index),
      );
    }
  }

  void _scheduleAdvance() {
    _advanceTimer?.cancel();
    _advanceTimer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      unawaited(
        ref
            .read(
              exerciseProvider(widget.lessonId, widget.startIndex).notifier,
            )
            .advance(),
      );
    });
  }

  void _updateDahuAnimation(
    ExerciseState state, {
    required bool reducedMotion,
  }) {
    if (reducedMotion) return;
    if (state is ExerciseFeedback || state is ExerciseTypingFeedback) {
      if (!_dahuController.isAnimating) {
        unawaited(_dahuController.repeat(reverse: true));
      }
    } else {
      _dahuController
        ..stop()
        ..value = 0;
    }
  }

  void _submitTypingAnswer() {
    final text = _typingController.text;
    if (text.trim().isEmpty) return;
    unawaited(
      ref
          .read(
            exerciseProvider(widget.lessonId, widget.startIndex).notifier,
          )
          .submitTypingAnswer(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(
      exerciseProvider(widget.lessonId, widget.startIndex),
    );
    final reducedMotion = MediaQuery.disableAnimationsOf(context);

    return ColoredBox(
      color: CaJoueColors.snow,
      child: SafeArea(
        child: asyncState.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => Center(
            child: CtaButton(
              label: 'Reessayer',
              onPressed: () => ref.invalidate(
                exerciseProvider(widget.lessonId, widget.startIndex),
              ),
            ),
          ),
          data: (state) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _updateDahuAnimation(
                state,
                reducedMotion: reducedMotion,
              );
            });

            return AnimatedSwitcher(
              duration: reducedMotion
                  ? Duration.zero
                  : CaJoueAnimations.feedback,
              child: switch (state) {
                ExerciseLoading() => const SizedBox.shrink(
                  key: ValueKey('loading'),
                ),
                ExerciseDiscovery() => _buildDiscovery(state),
                ExerciseActive() => _buildActive(state, reducedMotion),
                ExerciseFeedback() => _buildFeedback(state, reducedMotion),
                ExerciseTypingActive() => _buildTypingActive(
                  state,
                  reducedMotion,
                ),
                ExerciseTypingFeedback() => _buildTypingFeedback(
                  state,
                  reducedMotion,
                ),
                ExerciseComplete() => _buildComplete(state),
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDiscovery(ExerciseDiscovery state) {
    return Column(
      key: ValueKey('discovery-${state.expression.id}'),
      children: [
        CategoryStrip(
          lessonName: _lessonDisplayName,
          progressIndex: state.progressIndex,
          totalExpressions: state.totalExpressions,
          onBack: () => context.pop(),
        ),
        const SizedBox(height: CaJoueSpacing.sm),
        ProgressBar(
          progressIndex: state.progressIndex,
          totalExpressions: state.totalExpressions,
        ),
        Expanded(
          child: Center(
            child: DiscoveryCardAnimated(
              expression: state.expression,
              onDismiss: () => unawaited(
                ref
                    .read(
                      exerciseProvider(
                        widget.lessonId,
                        widget.startIndex,
                      ).notifier,
                    )
                    .dismissDiscovery(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActive(ExerciseActive state, bool reducedMotion) {
    _hapticFired = false;
    return _buildExerciseLayout(
      key: ValueKey('active-${state.expression.id}'),
      progressIndex: state.progressIndex,
      totalExpressions: state.totalExpressions,
      expression: state.expression,
      options: state.options,
      buttonStates: {
        for (final option in state.options)
          option: AnswerButtonState.defaultState,
      },
      onTap: (answer) => unawaited(
        ref
            .read(
              exerciseProvider(widget.lessonId, widget.startIndex).notifier,
            )
            .submitAnswer(answer),
      ),
      feedbackText: null,
      isFeedback: false,
      isCorrect: false,
      reducedMotion: reducedMotion,
    );
  }

  Widget _buildFeedback(ExerciseFeedback state, bool reducedMotion) {
    // Schedule auto-advance.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scheduleAdvance();
    });

    // Haptic on correct (once per feedback).
    if (state.isCorrect && !_hapticFired) {
      _hapticFired = true;
      unawaited(HapticFeedback.lightImpact());
    }

    final buttonStates = <String, AnswerButtonState>{};
    for (final option in state.options) {
      if (option == state.correctAnswer) {
        buttonStates[option] = AnswerButtonState.correct;
      } else if (option == state.selectedAnswer) {
        buttonStates[option] = AnswerButtonState.incorrect;
      } else {
        buttonStates[option] = AnswerButtonState.dimmed;
      }
    }

    return _buildExerciseLayout(
      key: ValueKey('feedback-${state.expression.id}'),
      progressIndex: state.progressIndex,
      totalExpressions: state.totalExpressions,
      expression: state.expression,
      options: state.options,
      buttonStates: buttonStates,
      onTap: null,
      feedbackText: state.isCorrect ? null : 'Pas tout a fait...',
      isFeedback: true,
      isCorrect: state.isCorrect,
      reducedMotion: reducedMotion,
    );
  }

  Widget _buildTypingActive(
    ExerciseTypingActive state,
    bool reducedMotion,
  ) {
    _hapticFired = false;

    // Auto-focus the typing input.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_typingFocusNode.hasFocus) {
        _typingFocusNode.requestFocus();
      }
    });

    return Column(
      key: ValueKey('typing-active-${state.expression.id}'),
      children: [
        CategoryStrip(
          lessonName: _lessonDisplayName,
          progressIndex: state.progressIndex,
          totalExpressions: state.totalExpressions,
          onBack: () => context.pop(),
        ),
        const SizedBox(height: CaJoueSpacing.sm),
        ProgressBar(
          progressIndex: state.progressIndex,
          totalExpressions: state.totalExpressions,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: 20,
              bottom: CaJoueSpacing.xl,
            ),
            child: Column(
              children: [
                const Dahu(size: DahuSize.exercise),
                const SizedBox(height: CaJoueSpacing.lg),

                // Hint text.
                Padding(
                  padding: CaJoueSpacing.horizontal,
                  child: Text(
                    'Écris l\'expression romande',
                    style: CaJoueTypography.uiLabel.copyWith(
                      color: CaJoueColors.stone,
                      letterSpacing: 0.08 * 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),

                // French expression.
                Padding(
                  padding: CaJoueSpacing.horizontal,
                  child: Text(
                    state.expression.french,
                    style: CaJoueTypography.expressionTitle.copyWith(
                      color: CaJoueColors.slate,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: CaJoueSpacing.lg),

                // Typing input.
                Padding(
                  padding: CaJoueSpacing.horizontal,
                  child: ListenableBuilder(
                    listenable: _typingFocusNode,
                    builder: (context, _) {
                      return TypingInput(
                        controller: _typingController,
                        focusNode: _typingFocusNode,
                        inputState: _typingFocusNode.hasFocus
                            ? TypingInputState.focused
                            : TypingInputState.unfocused,
                        reducedMotion: reducedMotion,
                        onSubmitted: (_) => _submitTypingAnswer(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: CaJoueSpacing.md),

                // Valider button.
                Padding(
                  padding: CaJoueSpacing.horizontal,
                  child: CtaButton(
                    label: 'Valider',
                    onPressed: _submitTypingAnswer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypingFeedback(
    ExerciseTypingFeedback state,
    bool reducedMotion,
  ) {
    // Haptic on correct (once per feedback).
    if (state.isCorrect && !_hapticFired) {
      _hapticFired = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(HapticFeedback.lightImpact());
      });
    }

    return Column(
      key: ValueKey('typing-feedback-${state.expression.id}'),
      children: [
        CategoryStrip(
          lessonName: _lessonDisplayName,
          progressIndex: state.progressIndex,
          totalExpressions: state.totalExpressions,
          onBack: () => context.pop(),
        ),
        const SizedBox(height: CaJoueSpacing.sm),
        ProgressBar(
          progressIndex: state.progressIndex,
          totalExpressions: state.totalExpressions,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: 20,
              bottom: CaJoueSpacing.xl,
            ),
            child: Column(
              children: [
                // Dahu with animation.
                AnimatedBuilder(
                  animation: _dahuController,
                  builder: (context, child) {
                    if (state.isCorrect && !reducedMotion) {
                      return Transform.translate(
                        offset: Offset(0, _dahuBob.value),
                        child: child,
                      );
                    }
                    if (!state.isCorrect && !reducedMotion) {
                      return Transform(
                        alignment: Alignment.bottomCenter,
                        transform: Matrix4.rotationZ(
                          _dahuTilt.value,
                        ),
                        child: child,
                      );
                    }
                    return child!;
                  },
                  child: const Dahu(size: DahuSize.exercise),
                ),
                const SizedBox(height: CaJoueSpacing.lg),

                // Hint text.
                Padding(
                  padding: CaJoueSpacing.horizontal,
                  child: Text(
                    'Écris l\'expression romande',
                    style: CaJoueTypography.uiLabel.copyWith(
                      color: CaJoueColors.stone,
                      letterSpacing: 0.08 * 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),

                // French expression.
                Padding(
                  padding: CaJoueSpacing.horizontal,
                  child: Text(
                    state.expression.french,
                    style: CaJoueTypography.expressionTitle.copyWith(
                      color: CaJoueColors.slate,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: CaJoueSpacing.lg),

                if (state.isCorrect) ...[
                  // Correct: static display (no EditableText to avoid
                  // sharing the controller during AnimatedSwitcher crossfade).
                  Padding(
                    padding: CaJoueSpacing.horizontal,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 56),
                      decoration: BoxDecoration(
                        color: CaJoueColors.goldSoft,
                        border: Border.all(
                          color: CaJoueColors.gold,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(
                          CaJoueAnimations.buttonRadius,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        state.userAnswer,
                        style: CaJoueTypography.uiBody.copyWith(
                          color: CaJoueColors.slate,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: CaJoueSpacing.md),
                  GoldBadge(reducedMotion: reducedMotion),
                ] else ...[
                  // Incorrect: show feedback cards.
                  Padding(
                    padding: CaJoueSpacing.horizontal,
                    child: FeedbackCard(
                      variant: FeedbackCardVariant.wrong,
                      text: state.userAnswer,
                    ),
                  ),
                  const SizedBox(height: CaJoueSpacing.sm),
                  Padding(
                    padding: CaJoueSpacing.horizontal,
                    child: FeedbackCard(
                      variant: FeedbackCardVariant.correct,
                      text: state.correctAnswer,
                    ),
                  ),
                  const SizedBox(height: CaJoueSpacing.md),
                  Text(
                    'Pas tout à fait...',
                    style: CaJoueTypography.uiBody.copyWith(
                      color: CaJoueColors.dusk,
                    ),
                  ),
                ],

                const SizedBox(height: CaJoueSpacing.lg),

                // Continuer button (no auto-advance for typing).
                Padding(
                  padding: CaJoueSpacing.horizontal,
                  child: CtaButton(
                    label: 'Continuer',
                    onPressed: () {
                      _typingController.clear();
                      unawaited(
                        ref
                            .read(
                              exerciseProvider(
                                widget.lessonId,
                                widget.startIndex,
                              ).notifier,
                            )
                            .advance(),
                      );
                    },
                  ),
                ),

                // Accessibility announcement.
                Semantics(
                  liveRegion: true,
                  child: Text(
                    state.isCorrect
                        ? 'Correct, ça joue!'
                        : 'Incorrect, la bonne réponse'
                              ' est ${state.correctAnswer}',
                    style: const TextStyle(fontSize: 0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseLayout({
    required Key key,
    required int progressIndex,
    required int totalExpressions,
    required Expression expression,
    required List<String> options,
    required Map<String, AnswerButtonState> buttonStates,
    required void Function(String)? onTap,
    required String? feedbackText,
    required bool isFeedback,
    required bool isCorrect,
    required bool reducedMotion,
  }) {
    return Column(
      key: key,
      children: [
        CategoryStrip(
          lessonName: _lessonDisplayName,
          progressIndex: progressIndex,
          totalExpressions: totalExpressions,
          onBack: () => context.pop(),
        ),
        const SizedBox(height: CaJoueSpacing.sm),
        ProgressBar(
          progressIndex: progressIndex,
          totalExpressions: totalExpressions,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: 20,
              bottom: CaJoueSpacing.xl,
            ),
            child: Column(
              children: [
                // Dahu with animation.
                AnimatedBuilder(
                  animation: _dahuController,
                  builder: (context, child) {
                    if (isFeedback && isCorrect && !reducedMotion) {
                      return Transform.translate(
                        offset: Offset(0, _dahuBob.value),
                        child: child,
                      );
                    }
                    if (isFeedback && !isCorrect && !reducedMotion) {
                      return Transform(
                        alignment: Alignment.bottomCenter,
                        transform: Matrix4.rotationZ(
                          _dahuTilt.value,
                        ),
                        child: child,
                      );
                    }
                    return child!;
                  },
                  child: const Dahu(
                    size: DahuSize.exercise,
                  ),
                ),

                const SizedBox(height: CaJoueSpacing.lg),

                // Hint text.
                Padding(
                  padding: CaJoueSpacing.horizontal,
                  child: Text(
                    'Quelle est l\'expression romande ?',
                    style: CaJoueTypography.uiLabel.copyWith(
                      color: CaJoueColors.stone,
                      letterSpacing: 0.08 * 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),

                // French expression.
                Padding(
                  padding: CaJoueSpacing.horizontal,
                  child: Text(
                    expression.french,
                    style: CaJoueTypography.expressionTitle.copyWith(
                      color: CaJoueColors.slate,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: CaJoueSpacing.lg),

                // Answer buttons.
                Padding(
                  padding: CaJoueSpacing.horizontal,
                  child: Column(
                    children: [
                      for (var i = 0; i < options.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        AnswerButton(
                          text: options[i],
                          buttonState: buttonStates[options[i]]!,
                          index: i,
                          onTap: onTap != null ? () => onTap(options[i]) : null,
                        ),
                      ],
                    ],
                  ),
                ),

                // Incorrect feedback text.
                if (feedbackText != null) ...[
                  const SizedBox(height: CaJoueSpacing.md),
                  Text(
                    feedbackText,
                    style: CaJoueTypography.uiBody.copyWith(
                      color: CaJoueColors.dusk,
                    ),
                  ),
                ],

                if (isFeedback)
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      isCorrect
                          ? 'Correct'
                          : 'Incorrect, la bonne reponse'
                                ' est ${expression.romand}',
                      style: const TextStyle(fontSize: 0),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComplete(ExerciseComplete state) {
    if (state.isTierComplete) {
      return _buildTierComplete(state);
    }

    final isReview = state.lessonId == reviewLessonId;
    final title = isReview ? 'Revision terminee !' : 'Lecon terminee !';
    final subtitle = isReview
        ? '${state.expressionsCount} expressions revisees'
        : '${state.expressionsCount} expressions apprises';

    return Center(
      key: const ValueKey('complete'),
      child: Padding(
        padding: CaJoueSpacing.horizontal,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Dahu(size: DahuSize.completion),
            const SizedBox(height: CaJoueSpacing.lg),
            Text(
              title,
              style: CaJoueTypography.expressionTitle.copyWith(
                color: CaJoueColors.slate,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: CaJoueSpacing.sm),
            Text(
              subtitle,
              style: CaJoueTypography.uiBody.copyWith(
                color: CaJoueColors.stone,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: CaJoueSpacing.xl),
            CtaButton(
              label: 'Retour',
              onPressed: () => context.go('/home', extra: 'slideDown'),
            ),
            Semantics(
              liveRegion: true,
              child: Text(
                '$title $subtitle',
                style: const TextStyle(fontSize: 0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierComplete(ExerciseComplete state) {
    return Center(
      key: const ValueKey('tier-complete'),
      child: Padding(
        padding: CaJoueSpacing.horizontal,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: 1.15,
              child: const Dahu(size: DahuSize.completion),
            ),
            const SizedBox(height: CaJoueSpacing.lg),
            Text(
              'Bravo !',
              style: CaJoueTypography.expressionTitle.copyWith(
                color: CaJoueColors.slate,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: CaJoueSpacing.sm),
            Text(
              'Tu as termine ${state.tierName}',
              style: CaJoueTypography.uiBody.copyWith(
                color: CaJoueColors.gold,
              ),
              textAlign: TextAlign.center,
            ),
            if (state.nextTierName != null) ...[
              const SizedBox(height: CaJoueSpacing.sm),
              Text(
                '${state.nextTierName} est maintenant accessible',
                style: CaJoueTypography.uiBody.copyWith(
                  color: CaJoueColors.stone,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: CaJoueSpacing.xl),
            CtaButton(
              label: 'Continuer',
              onPressed: () => context.go('/home', extra: 'slideDown'),
            ),
            Semantics(
              liveRegion: true,
              child: Text(
                'Bravo, tu as termine ${state.tierName}',
                style: const TextStyle(fontSize: 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

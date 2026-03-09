import 'dart:async';
import 'dart:math' as math;

import 'package:ca_joue/features/exercise/models/exercise_state.dart';
import 'package:ca_joue/features/exercise/widgets/category_strip.dart';
import 'package:ca_joue/features/exercise/widgets/feedback_card.dart';
import 'package:ca_joue/features/exercise/widgets/gold_badge.dart';
import 'package:ca_joue/features/exercise/widgets/progress_bar.dart';
import 'package:ca_joue/features/exercise/widgets/typing_input.dart';
import 'package:ca_joue/features/placement/models/placement_state.dart';
import 'package:ca_joue/features/placement/providers/placement_provider.dart';
import 'package:ca_joue/features/placement/widgets/placement_result_screen.dart';
import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:ca_joue/widgets/cta_button.dart';
import 'package:ca_joue/widgets/dahu.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The placement test screen shown during onboarding.
///
/// Uses the same layout and widgets as the exercise screen for visual
/// consistency: CategoryStrip, ProgressBar, Dahu, FeedbackCard, GoldBadge.
class PlacementScreen extends ConsumerWidget {
  const PlacementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(placementProvider);

    return asyncState.when(
      loading: () => const ColoredBox(color: CaJoueColors.snow),
      error: (_, _) => const ColoredBox(color: CaJoueColors.snow),
      data: (state) {
        if (state.isComplete) {
          return PlacementResultScreen(state: state);
        }
        return _PlacementQuiz(state: state);
      },
    );
  }
}

class _PlacementQuiz extends ConsumerStatefulWidget {
  const _PlacementQuiz({required this.state});

  final PlacementState state;

  @override
  ConsumerState<_PlacementQuiz> createState() => _PlacementQuizState();
}

class _PlacementQuizState extends ConsumerState<_PlacementQuiz>
    with TickerProviderStateMixin {
  late final TextEditingController _typingController;
  late final FocusNode _typingFocusNode;
  late final AnimationController _dahuController;
  late final Animation<double> _dahuBob;
  late final Animation<double> _dahuTilt;
  bool _hapticFired = false;

  @override
  void initState() {
    super.initState();
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
        Tween<double>(begin: 0, end: 6 * math.pi / 180).animate(
          CurvedAnimation(
            parent: _dahuController,
            curve: CaJoueAnimations.ambientCurve,
          ),
        );
  }

  @override
  void dispose() {
    _dahuController.dispose();
    _typingController.dispose();
    _typingFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _PlacementQuiz oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset typing controller when moving to a new question.
    if (oldWidget.state.currentIndex != widget.state.currentIndex) {
      _typingController.clear();
      _hapticFired = false;
    }
  }

  /// Double haptic for wrong answers.
  Future<void> _wrongHaptic() async {
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
  }

  void _updateDahuAnimation({required bool reducedMotion}) {
    if (reducedMotion) return;
    if (widget.state.hasAnswered) {
      if (!_dahuController.isAnimating) {
        unawaited(_dahuController.repeat(reverse: true));
      }
    } else {
      _dahuController
        ..stop()
        ..value = 0;
    }
  }

  void _submitTyping() {
    final text = _typingController.text;
    if (text.trim().isEmpty) return;
    unawaited(ref.read(placementProvider.notifier).answerTyping(text));
  }

  /// Builds a sentence with `___` rendered as a highlighted gap or filled text.
  Widget _buildSentenceText(String sentence, {String? filledAnswer}) {
    final parts = sentence.split('___');
    final spans = <InlineSpan>[];

    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        spans.add(
          TextSpan(
            text: parts[i],
            style: CaJoueTypography.uiBody.copyWith(
              color: CaJoueColors.slate,
              fontSize: 17,
              height: 1.6,
            ),
          ),
        );
      }
      if (i < parts.length - 1) {
        if (filledAnswer != null) {
          spans.add(
            TextSpan(
              text: filledAnswer,
              style: CaJoueTypography.uiBody.copyWith(
                color: CaJoueColors.gold,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                height: 1.6,
              ),
            ),
          );
        } else {
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                width: 80,
                height: 28,
                decoration: BoxDecoration(
                  color: CaJoueColors.cream,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: CaJoueColors.stone.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return Padding(
      padding: CaJoueSpacing.horizontal,
      child: Text.rich(
        TextSpan(children: spans),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final question = state.currentQuestion;
    final hasAnswered = state.hasAnswered;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateDahuAnimation(reducedMotion: reducedMotion);
    });

    final isBlankTyping = question.exerciseType == ExerciseType.blankTyping;

    return ColoredBox(
      color: CaJoueColors.snow,
      child: SafeArea(
        child: AnimatedSwitcher(
          duration: reducedMotion
              ? Duration.zero
              : CaJoueAnimations.feedback,
          child: hasAnswered
              ? (isBlankTyping
                  ? _buildBlankTypingFeedback(state, reducedMotion)
                  : _buildTypingFeedback(state, reducedMotion))
              : (isBlankTyping
                  ? _buildBlankTypingActive(state, reducedMotion)
                  : _buildTypingActive(state, reducedMotion)),
        ),
      ),
    );
  }

  // -- Typing active --

  Widget _buildTypingActive(PlacementState state, bool reducedMotion) {
    _hapticFired = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_typingFocusNode.hasFocus) {
        _typingFocusNode.requestFocus();
      }
    });

    final question = state.currentQuestion;

    return Column(
      key: ValueKey('typing-active-${state.currentIndex}'),
      children: [
        CategoryStrip(
          lessonName: 'Placement',
          progressIndex: state.currentIndex,
          totalExpressions: state.questions.length,
          onBack: () => context.pop(),
        ),
        const SizedBox(height: CaJoueSpacing.sm),
        ProgressBar(
          progressIndex: state.currentIndex,
          totalExpressions: state.questions.length,
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
                    "Écris l'expression romande",
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
                    question.expression.french,
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
                        onSubmitted: (_) => _submitTyping(),
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
                    onPressed: _submitTyping,
                  ),
                ),
                const SizedBox(height: CaJoueSpacing.md),
                GestureDetector(
                  onTap: () =>
                      ref.read(placementProvider.notifier).skip(),
                  child: Text(
                    'Je ne sais pas',
                    style: CaJoueTypography.uiBody.copyWith(
                      color: CaJoueColors.stone,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // -- Typing feedback --

  Widget _buildTypingFeedback(PlacementState state, bool reducedMotion) {
    final question = state.currentQuestion;
    final isCorrect = state.answers.last;
    final userAnswer = state.selectedAnswer ?? '';

    if (!_hapticFired) {
      _hapticFired = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isCorrect) {
          unawaited(HapticFeedback.lightImpact());
        } else {
          unawaited(_wrongHaptic());
        }
      });
    }

    return Column(
      key: ValueKey('typing-feedback-${state.currentIndex}'),
      children: [
        CategoryStrip(
          lessonName: 'Placement',
          progressIndex: state.currentIndex,
          totalExpressions: state.questions.length,
          onBack: () => context.pop(),
        ),
        const SizedBox(height: CaJoueSpacing.sm),
        ProgressBar(
          progressIndex: state.currentIndex,
          totalExpressions: state.questions.length,
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
                    if (isCorrect && !reducedMotion) {
                      return Transform.translate(
                        offset: Offset(0, _dahuBob.value),
                        child: child,
                      );
                    }
                    if (!isCorrect && !reducedMotion) {
                      return Transform(
                        alignment: Alignment.bottomCenter,
                        transform: Matrix4.rotationZ(_dahuTilt.value),
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
                    "Écris l'expression romande",
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
                    question.expression.french,
                    style: CaJoueTypography.expressionTitle.copyWith(
                      color: CaJoueColors.slate,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: CaJoueSpacing.lg),

                if (isCorrect) ...[
                  // Correct: static gold box.
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
                        userAnswer,
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
                  // Wrong: feedback cards.
                  if (userAnswer.isNotEmpty) ...[
                    Padding(
                      padding: CaJoueSpacing.horizontal,
                      child: FeedbackCard(
                        variant: FeedbackCardVariant.wrong,
                        text: userAnswer,
                      ),
                    ),
                    const SizedBox(height: CaJoueSpacing.sm),
                  ],
                  Padding(
                    padding: CaJoueSpacing.horizontal,
                    child: FeedbackCard(
                      variant: FeedbackCardVariant.correct,
                      text: question.correctAnswer,
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

                // Continuer button.
                Padding(
                  padding: CaJoueSpacing.horizontal,
                  child: CtaButton(
                    label: 'Continuer',
                    onPressed: () {
                      _typingController.clear();
                      ref.read(placementProvider.notifier).next();
                    },
                  ),
                ),

                // Accessibility announcement.
                Semantics(
                  liveRegion: true,
                  child: Text(
                    isCorrect
                        ? 'Correct, ça joue!'
                        : 'Incorrect, la bonne réponse'
                              ' est ${question.correctAnswer}',
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

  // -- Blank typing active --

  Widget _buildBlankTypingActive(PlacementState state, bool reducedMotion) {
    _hapticFired = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_typingFocusNode.hasFocus) {
        _typingFocusNode.requestFocus();
      }
    });

    final question = state.currentQuestion;

    return Column(
      key: ValueKey('blank-typing-active-${state.currentIndex}'),
      children: [
        CategoryStrip(
          lessonName: 'Placement',
          progressIndex: state.currentIndex,
          totalExpressions: state.questions.length,
          onBack: () => context.pop(),
        ),
        const SizedBox(height: CaJoueSpacing.sm),
        ProgressBar(
          progressIndex: state.currentIndex,
          totalExpressions: state.questions.length,
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

                // Instruction.
                Padding(
                  padding: CaJoueSpacing.horizontal,
                  child: Text(
                    'Complete la phrase',
                    style: CaJoueTypography.uiLabel.copyWith(
                      color: CaJoueColors.stone,
                      letterSpacing: 0.08 * 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: CaJoueSpacing.md),

                // Sentence with blank.
                _buildSentenceText(question.sentence ?? ''),
                const SizedBox(height: CaJoueSpacing.sm),

                // Hint: French meaning.
                Padding(
                  padding: CaJoueSpacing.horizontal,
                  child: Text(
                    '= ${question.expression.french}',
                    style: CaJoueTypography.uiBody.copyWith(
                      color: CaJoueColors.stone,
                      fontSize: 14,
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
                        onSubmitted: (_) => _submitTyping(),
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
                    onPressed: _submitTyping,
                  ),
                ),
                const SizedBox(height: CaJoueSpacing.md),
                GestureDetector(
                  onTap: () =>
                      ref.read(placementProvider.notifier).skip(),
                  child: Text(
                    'Je ne sais pas',
                    style: CaJoueTypography.uiBody.copyWith(
                      color: CaJoueColors.stone,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // -- Blank typing feedback --

  Widget _buildBlankTypingFeedback(PlacementState state, bool reducedMotion) {
    final question = state.currentQuestion;
    final isCorrect = state.answers.last;
    final userAnswer = state.selectedAnswer ?? '';

    if (!_hapticFired) {
      _hapticFired = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isCorrect) {
          unawaited(HapticFeedback.lightImpact());
        } else {
          unawaited(_wrongHaptic());
        }
      });
    }

    return Column(
      key: ValueKey('blank-typing-feedback-${state.currentIndex}'),
      children: [
        CategoryStrip(
          lessonName: 'Placement',
          progressIndex: state.currentIndex,
          totalExpressions: state.questions.length,
          onBack: () => context.pop(),
        ),
        const SizedBox(height: CaJoueSpacing.sm),
        ProgressBar(
          progressIndex: state.currentIndex,
          totalExpressions: state.questions.length,
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
                    if (isCorrect && !reducedMotion) {
                      return Transform.translate(
                        offset: Offset(0, _dahuBob.value),
                        child: child,
                      );
                    }
                    if (!isCorrect && !reducedMotion) {
                      return Transform(
                        alignment: Alignment.bottomCenter,
                        transform: Matrix4.rotationZ(_dahuTilt.value),
                        child: child,
                      );
                    }
                    return child!;
                  },
                  child: const Dahu(size: DahuSize.exercise),
                ),
                const SizedBox(height: CaJoueSpacing.lg),

                // Sentence with blank filled.
                _buildSentenceText(
                  question.sentence ?? '',
                  filledAnswer: question.correctAnswer,
                ),

                const SizedBox(height: CaJoueSpacing.lg),

                if (isCorrect) ...[
                  GoldBadge(reducedMotion: reducedMotion),
                ] else ...[
                  if (userAnswer.isNotEmpty) ...[
                    Padding(
                      padding: CaJoueSpacing.horizontal,
                      child: FeedbackCard(
                        variant: FeedbackCardVariant.wrong,
                        text: userAnswer,
                      ),
                    ),
                    const SizedBox(height: CaJoueSpacing.sm),
                  ],
                  Padding(
                    padding: CaJoueSpacing.horizontal,
                    child: FeedbackCard(
                      variant: FeedbackCardVariant.correct,
                      text: question.correctAnswer,
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

                // Continuer button.
                Padding(
                  padding: CaJoueSpacing.horizontal,
                  child: CtaButton(
                    label: 'Continuer',
                    onPressed: () {
                      _typingController.clear();
                      ref.read(placementProvider.notifier).next();
                    },
                  ),
                ),

                // Accessibility announcement.
                Semantics(
                  liveRegion: true,
                  child: Text(
                    isCorrect
                        ? 'Correct, ça joue!'
                        : 'Incorrect, la bonne réponse'
                              ' est ${question.correctAnswer}',
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
}

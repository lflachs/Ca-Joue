import 'package:ca_joue/core/content/content_provider.dart';
import 'package:ca_joue/core/content/tier_model.dart';
import 'package:ca_joue/core/progress/lesson_progress_provider.dart';
import 'package:ca_joue/features/home/widgets/lesson_row.dart';
import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:ca_joue/widgets/cta_button.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Screen showing all lessons within a given tier.
class LessonListScreen extends ConsumerWidget {
  /// Creates a [LessonListScreen] for the given [tierNum].
  const LessonListScreen({required this.tierNum, super.key});

  /// The tier number (1–4) to display lessons for.
  final int tierNum;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsByTierProvider(tierNum));
    final tierName = Tier.nameForTier(tierNum);

    return ColoredBox(
      color: CaJoueColors.snow,
      child: SafeArea(
        child: lessonsAsync.when(
          loading: SizedBox.shrink,
          error: (err, stack) => Padding(
            padding: CaJoueSpacing.horizontal,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    err.toString(),
                    style: CaJoueTypography.uiBody.copyWith(
                      color: CaJoueColors.stone,
                    ),
                  ),
                  const SizedBox(height: CaJoueSpacing.md),
                  CtaButton(
                    label: 'Reessayer',
                    fullWidth: false,
                    onPressed: () => ref.invalidate(
                      lessonsByTierProvider(tierNum),
                    ),
                  ),
                ],
              ),
            ),
          ),
          data: (lessons) => CustomScrollView(
            slivers: [
              // -- Header (back + title) --
              SliverToBoxAdapter(
                child: Padding(
                  padding: CaJoueSpacing.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: CaJoueSpacing.md),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Semantics(
                          label: 'Retour',
                          button: true,
                          excludeSemantics: true,
                          child: SizedBox(
                            height: 48,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Icon(
                                LucideIcons.arrowLeft,
                                size: 22,
                                color: CaJoueColors.slate,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Semantics(
                        header: true,
                        child: Text(
                          tierName,
                          style: CaJoueTypography.expressionTitle.copyWith(
                            color: CaJoueColors.slate,
                            fontSize: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: CaJoueSpacing.lg),
                    ],
                  ),
                ),
              ),

              // -- Lesson cards --
              SliverPadding(
                padding: CaJoueSpacing.horizontal,
                sliver: SliverList.builder(
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];
                    final completedAsync = ref.watch(
                      completedCountByLessonProvider(lesson.name),
                    );
                    final completedCount = completedAsync.value ?? 0;
                    return LessonRow(
                      lesson: lesson,
                      completedCount: completedCount,
                      onTap: () => context.push(
                        '/exercise/${lesson.name}',
                      ),
                    );
                  },
                ),
              ),

              // Bottom spacing.
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

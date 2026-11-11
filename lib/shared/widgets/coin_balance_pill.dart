import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/theme.dart';
import '../../core/providers/services_provider.dart';
import '../../features/game/providers/game_state.dart';
import 'pop_button.dart';

/// Modal dialog that gives users quick options to get free coins by watching an ad
/// and view their coin balance & perks.
void showCoinStoreModal({
  required BuildContext context,
  required WidgetRef ref,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalCtx) {
      return Consumer(
        builder: (ctx, ref, _) {
          final gameState = ref.watch(gameStateProvider);

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 28,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Header with Big Balance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xffffd000), Color(0xffff9900)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.sunnyYellow.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.monetization_on_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Coin Treasury',
                                style: theme.textTheme.displayMedium?.copyWith(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Watch ads & earn extra coins for hints',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 24),
                        onPressed: () => Navigator.pop(modalCtx),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Current Balance Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xff2a2315), const Color(0xff1f1b2e)]
                            : [const Color(0xfffffbeb), const Color(0xfffef3c7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppTheme.sunnyYellow.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'YOUR COIN BALANCE',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: const Color(0xffb45309),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: AppTheme.sunnyYellow,
                                  size: 30,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${gameState.stars}',
                                  style: theme.textTheme.displayLarge?.copyWith(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xffb45309),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Quick badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.sunnyYellow.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.bolt_rounded, color: AppTheme.sunnyYellow, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Instant Hints',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xffb45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // Option 1: Watch Ad for Free Coins (PRIMARY REWARD)
                        _buildRewardTile(
                          theme: theme,
                          isDark: isDark,
                          title: 'Watch Video Ad',
                          badgeText: '+50 COINS FREE',
                          badgeColor: AppTheme.mintGreen,
                          icon: Icons.video_library_rounded,
                          accentColor: AppTheme.coralPink,
                          description: 'Watch a quick sponsor ad to immediately earn 50 shiny coins for hints!',
                          buttonText: 'WATCH AD (+50 ⭐)',
                          buttonColor: AppTheme.coralPink,
                          shadowColor: const Color(0xffe11d48),
                          onTap: () {
                            ref.read(adServiceProvider).showRewardedAd(() {
                              ref.read(gameStateProvider.notifier).grantRewardedCoins(50);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(Icons.check_circle_rounded, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text('Success! +50 Coins added to your purse! 🎉'),
                                      ],
                                    ),
                                    backgroundColor: AppTheme.mintGreen,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                );
                              }
                            }, () {});
                          },
                        ),

                        const SizedBox(height: 14),

                        // Option 2: Coin Perks Summary
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xfff8fafc),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.dividerColor.withValues(alpha: 0.08),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.primaryColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    'How Coins Power Your Game:',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildPerkRow('💡 25 Coins', 'Reveal a correct letter tile during puzzles.'),
                              const SizedBox(height: 4),
                              _buildPerkRow('⚡ 15 Coins', 'Zap wrong letters away from your keyboard.'),
                              const SizedBox(height: 4),
                              _buildPerkRow('⏭️ 40 Coins', 'Skip any challenging puzzle with full reward.'),
                              const SizedBox(height: 4),
                              _buildPerkRow('🔥 Daily Streak', 'Earn coins every single day you play.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildPerkRow(String title, String desc) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$title: ',
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
      ),
      Expanded(
        child: Text(
          desc,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            height: 1.3,
          ),
        ),
      ),
    ],
  );
}

Widget _buildRewardTile({
  required ThemeData theme,
  required bool isDark,
  required String title,
  required String badgeText,
  required Color badgeColor,
  required IconData icon,
  required Color accentColor,
  required String description,
  String? buttonText,
  Color? buttonColor,
  Color? shadowColor,
  VoidCallback? onTap,
}) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xfff8fafc),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: accentColor.withValues(alpha: 0.22),
        width: 1.5,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: accentColor, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  color: badgeColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.75),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        if (buttonText != null && onTap != null)
          PopButton(
            backgroundColor: buttonColor ?? AppTheme.primaryColor,
            depth: 4,
            shadowColor: shadowColor ?? const Color(0xff4338ca),
            borderRadius: BorderRadius.circular(18),
            padding: const EdgeInsets.symmetric(vertical: 14),
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

/// Standalone Coin / Star Pill Button that users can tap from any top bar
/// to watch an ad and get extra coins.
class CoinBalancePill extends ConsumerWidget {
  const CoinBalancePill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gameState = ref.watch(gameStateProvider);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => showCoinStoreModal(
        context: context,
        ref: ref,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppTheme.sunnyYellow.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.sunnyYellow.withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star_rounded,
              color: AppTheme.sunnyYellow,
              size: 22,
            ),
            const SizedBox(width: 5),
            Text(
              '${gameState.stars}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xffb45309),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 6),
            // '+' button indicator signaling interactivity & ad reward
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppTheme.sunnyYellow,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Color(0xff78350f),
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

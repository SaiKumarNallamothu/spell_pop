import 'dart:ui';
import 'package:flutter/material.dart';

/// Modern card container featuring soft glassmorphism, rounded geometry, and delicate depth.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final double? elevation;
  final BorderSide? borderSide;
  final bool enableBlur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.gradient,
    this.borderRadius,
    this.elevation,
    this.borderSide,
    this.enableBlur = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final radius = borderRadius ?? BorderRadius.circular(24);

    // Subtle modern border for crisp contrast without harsh borders
    final border = borderSide ??
        BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.04),
          width: 1.2,
        );

    final cardBg = backgroundColor ??
        (isDark
            ? theme.colorScheme.surface.withValues(alpha: enableBlur ? 0.8 : 1.0)
            : Colors.white.withValues(alpha: enableBlur ? 0.85 : 1.0));

    Widget content = Container(
      decoration: BoxDecoration(
        color: gradient == null ? cardBg : null,
        gradient: gradient,
        borderRadius: radius,
        border: Border.fromBorderSide(border),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xff64748b).withValues(alpha: 0.08),
            blurRadius: elevation ?? 16,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.15)
                : const Color(0xff64748b).withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20.0),
        child: child,
      ),
    );

    if (enableBlur) {
      return ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: content,
        ),
      );
    }

    return content;
  }
}

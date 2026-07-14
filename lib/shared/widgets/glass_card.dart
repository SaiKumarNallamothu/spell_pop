import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final double? elevation;
  final BorderSide? borderSide;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.gradient,
    this.borderRadius,
    this.elevation,
    this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final radius = borderRadius ?? BorderRadius.circular(24);
    
    // Default border styling for modern clean depth
    final border = borderSide ??
        BorderSide(
          color: isDark 
              ? Colors.white.withOpacity(0.08) 
              : Colors.black.withOpacity(0.05),
          width: 1.5,
        );

    final cardBg = backgroundColor ?? 
        (isDark ? theme.colorScheme.surface.withOpacity(0.7) : Colors.white.withOpacity(0.9));

    return Container(
      decoration: BoxDecoration(
        color: gradient == null ? cardBg : null,
        gradient: gradient,
        borderRadius: radius,
        border: Border.fromBorderSide(border),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.2) 
                : theme.colorScheme.onSurface.withOpacity(0.04),
            blurRadius: elevation ?? 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20.0),
        child: child,
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Modern 3D-styled tactile button inspired by casual puzzle games like Spell Pop.
/// Features a beveled 3D bottom edge, smooth spring press animation, and optional gradients.
class PopButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final AlignmentGeometry? alignment;
  final double depth; // 3D bevel depth
  final Color? shadowColor;

  const PopButton({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.gradient,
    this.borderRadius,
    this.padding,
    this.border,
    this.boxShadow,
    this.alignment,
    this.depth = 4.0,
    this.shadowColor,
  });

  @override
  State<PopButton> createState() => _PopButtonState();
}

class _PopButtonState extends State<PopButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = widget.backgroundColor ?? theme.colorScheme.primary;
    final radius = widget.borderRadius ?? BorderRadius.circular(22);
    final isEnabled = widget.onTap != null;

    // Derive a rich bottom bevel shadow color if not explicitly provided
    final HSLColor hsl = HSLColor.fromColor(buttonColor);
    final Color bevelColor = widget.shadowColor ??
        hsl.withLightness((hsl.lightness - 0.18).clamp(0.0, 1.0)).toColor();

    final currentOffset = (_isPressed && isEnabled) ? widget.depth : 0.0;
    final remainingDepth = (_isPressed && isEnabled) ? 0.0 : widget.depth;

    return GestureDetector(
      onTapDown: isEnabled ? _onTapDown : null,
      onTapUp: isEnabled ? _onTapUp : null,
      onTapCancel: isEnabled ? _onTapCancel : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutQuad,
        margin: EdgeInsets.only(
          top: currentOffset,
          bottom: widget.depth - currentOffset,
        ),
        decoration: BoxDecoration(
          color: widget.gradient == null ? buttonColor : null,
          gradient: widget.gradient,
          borderRadius: radius,
          border: widget.border ??
              Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.2,
              ),
          boxShadow: widget.boxShadow ??
              [
                if (remainingDepth > 0)
                  BoxShadow(
                    color: bevelColor,
                    offset: Offset(0, remainingDepth),
                    blurRadius: 0,
                  ),
                BoxShadow(
                  color: bevelColor.withValues(alpha: 0.35),
                  offset: Offset(0, remainingDepth + 3),
                  blurRadius: 8,
                ),
              ],
        ),
        child: Container(
          alignment: widget.alignment,
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          child: DefaultTextStyle(
            style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ) ??
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            child: IconTheme(
              data: const IconThemeData(color: Colors.white, size: 24),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

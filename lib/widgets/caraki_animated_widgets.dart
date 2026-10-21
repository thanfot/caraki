import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/caraki_theme.dart';

/// Direct wrapper (no generic fade-in on scroll)
class StaggeredFadeSlide extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration baseDelay;

  const StaggeredFadeSlide({
    super.key,
    required this.index,
    required this.child,
    this.baseDelay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) => child;
}

/// Native tactile press feedback
class BouncyTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;

  const BouncyTap({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.975,
  });

  @override
  State<BouncyTap> createState() => _BouncyTapState();
}

class _BouncyTapState extends State<BouncyTap> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        if (widget.onTap != null) {
          setState(() => _pressed = true);
        }
      },
      onTapUp: (_) {
        if (widget.onTap != null) {
          setState(() => _pressed = false);
          HapticFeedback.selectionClick();
          widget.onTap!();
        }
      },
      onTapCancel: () {
        if (_pressed) setState(() => _pressed = false);
      },
      child: AnimatedScale(
        scale: _pressed ? widget.scaleDown : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Smooth number counter for odometer
class AnimatedCounterText extends StatelessWidget {
  final int value;
  final TextStyle style;
  final String suffix;
  final Duration duration;

  const AnimatedCounterText({
    super.key,
    required this.value,
    required this.style,
    this.suffix = ' χλμ',
    this.duration = const Duration(milliseconds: 650),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: (value * 0.96), end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedVal, _) {
        final formatted = CarakiTheme.formatKm(animatedVal.round());
        return Text(
          suffix == ' χλμ' ? formatted : '${animatedVal.round()}$suffix',
          style: style,
        );
      },
    );
  }
}

/// Clean wrapper without neon glow borders
class PulsingUrgentBadge extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final bool active;

  const PulsingUrgentBadge({
    super.key,
    required this.child,
    required this.glowColor,
    this.active = true,
  });

  @override
  Widget build(BuildContext context) => child;
}

/// Crisp, solid progress bar (no neon box shadows)
class AnimatedLiquidBar extends StatelessWidget {
  final double ratio;
  final Color color;
  final double height;

  const AnimatedLiquidBar({
    super.key,
    required this.ratio,
    required this.color,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final target = ratio.clamp(0.03, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: target),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, val, _) {
        return Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(height),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: val,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Precision Instrument Dial (Clean Porsche/Apple Watch Ultra style, no neon blur)
class AnimatedTachometerGauge extends StatelessWidget {
  final int scorePercent;
  final double size;
  final VoidCallback? onTap;

  const AnimatedTachometerGauge({
    super.key,
    required this.scorePercent,
    this.size = 104,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final targetRatio = (scorePercent / 100.0).clamp(0.0, 1.0);
    final color = CarakiTheme.healthColor(targetRatio);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return BouncyTap(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: targetRatio),
        duration: const Duration(milliseconds: 850),
        curve: Curves.easeOutCubic,
        builder: (context, animRatio, _) {
          final animScore = (animRatio * 100).round().clamp(0, 100);
          return SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _PrecisionDialPainter(
                ratio: animRatio.clamp(0.0, 1.0),
                activeColor: color,
                trackColor: onSurface.withValues(alpha: 0.12),
                tickColor: onSurface.withValues(alpha: 0.25),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$animScore%',
                      style: TextStyle(
                        color: onSurface,
                        fontSize: size * 0.24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                    Text(
                      'Υγεία',
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.6),
                        fontSize: size * 0.11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PrecisionDialPainter extends CustomPainter {
  final double ratio;
  final Color activeColor;
  final Color trackColor;
  final Color tickColor;

  _PrecisionDialPainter({
    required this.ratio,
    required this.activeColor,
    required this.trackColor,
    required this.tickColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 6;

    const startAngle = 135 * (math.pi / 180);
    const totalSweep = 270 * (math.pi / 180);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep,
      false,
      trackPaint,
    );

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep * ratio,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PrecisionDialPainter oldDelegate) {
    return oldDelegate.ratio != ratio || oldDelegate.activeColor != activeColor;
  }
}

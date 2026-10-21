import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/caraki_theme.dart';

/// 1. Staggered Entrance Slide + Fade Animation for cards and lists
class StaggeredFadeSlide extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration baseDelay;

  const StaggeredFadeSlide({
    super.key,
    required this.index,
    required this.child,
    this.baseDelay = const Duration(milliseconds: 55),
  });

  @override
  Widget build(BuildContext context) {
    final durationMs = (350 + (index.clamp(0, 8) * baseDelay.inMilliseconds));
    return TweenAnimationBuilder<double>(
      key: ValueKey('stagger_$index'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: durationMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1.0 - value) * 22),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// 2. Spring Scale Tap Wrapper for tactile physical button/card feel
class BouncyTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;

  const BouncyTap({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.96,
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
          HapticFeedback.lightImpact();
          widget.onTap!();
        }
      },
      onTapCancel: () {
        if (_pressed) setState(() => _pressed = false);
      },
      child: AnimatedScale(
        scale: _pressed ? widget.scaleDown : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}

/// 3. Animated Rolling Odometer / Number Counter
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
    this.duration = const Duration(milliseconds: 950),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: (value * 0.92), end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutExpo,
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

/// 4. Pulsing Urgent Badge / Dot for overdue items
class PulsingUrgentBadge extends StatefulWidget {
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
  State<PulsingUrgentBadge> createState() => _PulsingUrgentBadgeState();
}

class _PulsingUrgentBadgeState extends State<PulsingUrgentBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final pulse = _ctrl.value;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.15 + (0.28 * pulse)),
                blurRadius: 6 + (10 * pulse),
                spreadRadius: 1 * pulse,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// 5. Animated Progress Bar that sweeps smoothly from 0 to target ratio
class AnimatedLiquidBar extends StatelessWidget {
  final double ratio;
  final Color color;
  final double height;

  const AnimatedLiquidBar({
    super.key,
    required this.ratio,
    required this.color,
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    final target = ratio.clamp(0.04, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: target),
      duration: const Duration(milliseconds: 900),
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
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.75),
                    color,
                  ],
                ),
                borderRadius: BorderRadius.circular(height),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 6. Custom Analog/Digital Motorsport Tachometer Gauge with Sweeping Needle!
class AnimatedTachometerGauge extends StatelessWidget {
  final int scorePercent;
  final double size;
  final VoidCallback? onTap;

  const AnimatedTachometerGauge({
    super.key,
    required this.scorePercent,
    this.size = 112,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final targetRatio = (scorePercent / 100.0).clamp(0.0, 1.0);
    final color = CarakiTheme.healthColor(targetRatio);

    return BouncyTap(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: targetRatio),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutBack,
        builder: (context, animRatio, _) {
          final animScore = (animRatio * 100).round().clamp(0, 100);
          return SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _TachometerPainter(
                ratio: animRatio.clamp(0.0, 1.0),
                activeColor: color,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      '$animScore%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size * 0.22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ΥΓΕΙΑ',
                        style: TextStyle(
                          color: color,
                          fontSize: size * 0.085,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
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

class _TachometerPainter extends CustomPainter {
  final double ratio;
  final Color activeColor;

  _TachometerPainter({
    required this.ratio,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 8;

    // Start at 135 degrees (bottom-left) and sweep 270 degrees to 45 degrees (bottom-right)
    const startAngle = 135 * (math.pi / 180);
    const totalSweep = 270 * (math.pi / 180);

    // 1. Track Background Arc
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep,
      false,
      trackPaint,
    );

    // 2. Tick Marks around the dial
    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    const tickCount = 18;
    for (int i = 0; i <= tickCount; i++) {
      final t = i / tickCount;
      final angle = startAngle + (totalSweep * t);
      final isMajor = i % 3 == 0;
      final innerR = radius - (isMajor ? 13 : 10);
      final outerR = radius - 6.5;
      final p1 = Offset(
        center.dx + innerR * math.cos(angle),
        center.dy + innerR * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + outerR * math.cos(angle),
        center.dy + outerR * math.sin(angle),
      );
      canvas.drawLine(p1, p2, tickPaint);
    }

    // 3. Glowing Active Arc
    final glowPaint = Paint()
      ..color = activeColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep * ratio,
      false,
      glowPaint,
    );

    final activePaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + totalSweep,
        colors: [
          CarakiTheme.primaryPapaya,
          activeColor,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep * ratio,
      false,
      activePaint,
    );

    // 4. Glowing Tip Indicator Dot on the arc
    final tipAngle = startAngle + (totalSweep * ratio);
    final tipPos = Offset(
      center.dx + radius * math.cos(tipAngle),
      center.dy + radius * math.sin(tipAngle),
    );
    canvas.drawCircle(
      tipPos,
      5.5,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      tipPos,
      3.0,
      Paint()..color = activeColor,
    );
  }

  @override
  bool shouldRepaint(covariant _TachometerPainter oldDelegate) {
    return oldDelegate.ratio != ratio || oldDelegate.activeColor != activeColor;
  }
}

import 'package:app/ui/helpers/font_size_helper.dart';
import 'package:flutter/material.dart';

class CustomGradientAnimationText extends StatefulWidget {
  final String text;
  final List<Color> colors;
  final Duration duration;
  final bool? reverse;
  final GradientTransform? transform;
  final Widget? icon; // 🔹 new optional icon widget
  final double? spacing; // 🔹 space between icon and text
  final TextStyle? style;

  const CustomGradientAnimationText({
    required this.text,
    required this.colors,
    required this.duration,
    this.reverse,
    this.transform,
    this.icon,
    this.spacing = 6.0,
    this.style,
    super.key,
  });

  @override
  State<CustomGradientAnimationText> createState() =>
      _GradientAnimationTextState();
}

class _GradientAnimationTextState extends State<CustomGradientAnimationText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late List<Color> colors;
  late int n;
  late double diff;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: widget.reverse ?? false);

    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() => setState(() {}));

    colors = [];
    colors.add(widget.colors.last);
    colors.addAll(widget.colors);
    colors.addAll(widget.colors);
    n = widget.colors.length;
    diff = (1 / n);
  }

  List<double> _stopsList() {
    int multiplier = -1 * n;
    List<double> stops = [];

    while (multiplier <= n) {
      stops.add(_animation.value + (multiplier * diff));
      multiplier++;
    }

    return stops;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (rect) {
        return LinearGradient(
          tileMode: TileMode.clamp,
          transform: widget.transform,
          stops: _stopsList(),
          colors: colors,
        ).createShader(rect);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            widget.icon!,
            SizedBox(width: widget.spacing),
          ],
          Text(
            widget.text,
            style:
                widget.style ??
                TextStyle(
                  fontSize: AppFontSize.f18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CustomShimmerCard extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const CustomShimmerCard({
    super.key,
    this.width = double.infinity,
    this.height = 100,
    this.borderRadius = 16,
    this.margin,
  });

  @override
  State<CustomShimmerCard> createState() => _CustomShimmerCardState();
}

class _CustomShimmerCardState extends State<CustomShimmerCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade200,
                    Colors.grey.shade100,
                    Colors.grey.shade200,
                  ],
                  stops: const [0.1, 0.5, 0.9],
                  transform: GradientRotation(_animation.value),
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcATop,
              child: Container(
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}

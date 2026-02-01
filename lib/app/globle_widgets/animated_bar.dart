import 'package:flutter/material.dart';

class AnimatedBar extends StatelessWidget {
  final AnimationController animController;
  final int position;
  final int currentIndex;

  const AnimatedBar({
    super.key,
    required this.animController,
    required this.position,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          _buildContainer(
            constraints.maxWidth,
            position < currentIndex ? Colors.white : Colors.white.withOpacity(0.3),
          ),
          position == currentIndex
              ? AnimatedBuilder(
            animation: animController,
            builder: (context, child) {
              return _buildContainer(
                constraints.maxWidth * animController.value,
                Colors.white,
              );
            },
          )
              : const SizedBox.shrink(),
        ],
      );
    });
  }

  Container _buildContainer(double width, Color color) {
    return Container(
      height: 3.0,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3.0),
      ),
    );
  }
}
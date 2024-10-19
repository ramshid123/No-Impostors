import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KickOutPageWidgets {
  static Widget whiteStars({
    required Size size,
  }) {
    return _WhiteStar(size: size);
  }
}

class _WhiteStar extends StatefulWidget {
  final Size size;
  const _WhiteStar({required this.size});

  @override
  State<_WhiteStar> createState() => __WhiteStarState();
}

class __WhiteStarState extends State<_WhiteStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;

  late Offset randomOffset;
  late double starRadius;

  @override
  void initState() {
    
    starRadius = (math.Random().nextInt(3) + 2).r;

    randomOffset = Offset(
        math.Random().nextInt(widget.size.width.toInt()).toDouble(),
        math.Random().nextInt(widget.size.height.toInt()).toDouble());

    _animationController = AnimationController(
        vsync: this,
        duration: Duration(seconds: math.Random().nextInt(20) + 15));

    changeDirection();

    super.initState();
  }

  Future changeDirection() async {
    while (true) {
      final randomX =
          math.Random().nextInt(widget.size.width.toInt()).toDouble();
      final randomY =
          math.Random().nextInt(widget.size.height.toInt()).toDouble();

      final previousOffset = randomOffset;
      randomOffset = Offset(randomX, randomY);

      _animation = Tween(begin: previousOffset, end: randomOffset).animate(
          CurvedAnimation(
              parent: _animationController, curve: Curves.linear));
      await _animationController.forward();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return Transform.translate(
            offset: _animation.value,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: starRadius,
            ),
          );
        });
  }
}

import 'dart:math' as math;

import 'package:amongus_lock/features/presentation/home%20page/cubit/passkey_cubit.dart';
import 'package:amongus_lock/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soundpool/soundpool.dart';

class HomePageWidgets {
  static Widget numberButton({
    required BuildContext context,
    required String value,
    required int pressSoundId,
    required bool isCorrect,
    required AnimationController animationController,
  }) {
    return _NumberButton(
        context: context,
        value: value,
        pressSoundId: pressSoundId,
        isCorrect: isCorrect,
        animationController: animationController);
  }

  static Widget inputDigitBox({required int index, required int length}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      height: 20.r,
      width: 20.r,
      decoration: BoxDecoration(
        color: const Color(0xff696969),
        gradient: LinearGradient(
          colors: index <= length
              ? [Colors.green, Colors.green]
              : [
                  Colors.white,
                  const Color(0xff696969),
                  const Color(0xff696969),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(1),
            offset: const Offset(0, 0),
            blurRadius: 0,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(2.r),
        child: Transform.rotate(
          angle: (math.pi / 4) * 6,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeCap: StrokeCap.round,
            strokeWidth: 3.r,
            value: 0.2,
          ),
        ),
      ),
    );
  }
}

class _NumberButton extends StatefulWidget {
  final BuildContext context;
  final String value;
  final AnimationController animationController;
  final int pressSoundId;
  final bool isCorrect;
  const _NumberButton({
    required this.context,
    required this.value,
    required this.animationController,
    required this.isCorrect,
    required this.pressSoundId,
  });

  @override
  State<_NumberButton> createState() => __NumberButtonState();
}

class __NumberButtonState extends State<_NumberButton>
    with SingleTickerProviderStateMixin {
  late Soundpool soundPool;

  late Animation _animation;

  late AnimationController _buttonPressAnimController;

  @override
  void initState() {
    _buttonPressAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));

    _animation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
    ]).animate(widget.animationController);

    soundPool = serviceLocator();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _buttonPressAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (delta) async {
        if (widget.animationController.isDismissed) {
          await _buttonPressAnimController.forward();
          _buttonPressAnimController.reset();
        }
      },
      onTap: () {
        if (widget.animationController.isDismissed) {
          soundPool.play(widget.pressSoundId);
          context.read<PasskeyCubit>().updatePassKey(widget.value);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(4.r),
            color: Colors.black,
            child: AnimatedBuilder(
                animation: _buttonPressAnimController,
                builder: (context, _) {
                  return Transform.scale(
                    scale: _buttonPressAnimController.isAnimating ? 0.9 : 1.0,
                    child: Container(
                      height: 60.r,
                      width: 60.r,
                      decoration: BoxDecoration(
                        color: _buttonPressAnimController.isAnimating
                            ? const Color.fromARGB(255, 186, 186, 186)
                            : const Color(0xffe1e0e1),
                        border: Border.symmetric(
                          vertical: BorderSide(
                            color: const Color(0xff616361),
                            width: _buttonPressAnimController.isAnimating
                                ? 11.r
                                : 8.r,
                          ),
                          horizontal: BorderSide(
                            color: const Color(0xff9b999b),
                            width: _buttonPressAnimController.isAnimating
                                ? 11.r
                                : 8.r,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
          AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                return Container(
                  height: 60.r,
                  width: 60.r,
                  color: widget.animationController.value > 0
                      ? widget.isCorrect
                          ? Colors.green.withOpacity(0.7)
                          : _animation.value > 0.5
                              ? Colors.red.withOpacity(0.7)
                              : Colors.transparent
                      : Colors.transparent,
                );
              }),
        ],
      ),
    );
  }
}

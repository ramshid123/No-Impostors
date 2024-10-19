import 'dart:math' as math;

import 'package:amongus_lock/core/widgets/common.dart';
import 'package:amongus_lock/features/presentation/kickout%20page/widget.dart';
import 'package:amongus_lock/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soundpool/soundpool.dart';

class KickOutPage extends StatefulWidget {
  const KickOutPage({super.key});

  // static final route = ;

  @override
  State<KickOutPage> createState() => _KickOutPageState();
}

class _KickOutPageState extends State<KickOutPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;

  late Soundpool soundPool;
  late int textSoundId;

  ValueNotifier<String> text = ValueNotifier('');

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _animation = Tween(begin: -1.2, end: 1.2).animate(_animationController);

    soundPool = serviceLocator();

    loadSounds();

    const finalText = 'Wrong Password. Please try again later';
    _animationController.addListener(() async {
      if (_animationController.value > 0.5) {
        // soundPool.play(textSoundId);
        double scaledValue = (_animationController.value - 0.5) / 0.5;
        int index = (scaledValue * finalText.length).round();
        text.value = finalText.substring(0, index);
        if (![' ', '.'].contains(finalText[index - 1])) {
          soundPool.play(textSoundId);
        }
      }
    });

    Future.delayed(const Duration(seconds: 3), () async {
      // loadSounds();
      await _animationController.forward();
      await Future.delayed(
        const Duration(seconds: 3),
        () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
      );
    });

    super.initState();
  }

  Future loadSounds() async {
    ByteData byteData = await rootBundle.load('assets/sounds/text.mp3');
    textSoundId = await soundPool.load(byteData);
    // await soundPool.play(textSoundId);
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          for (int i = 0; i < 30; i++)
            KickOutPageWidgets.whiteStars(
              size: size,
            ),
          Align(
            alignment: Alignment.center,
            child: AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  return Transform.translate(
                    offset: Offset((size.width / 2) * _animation.value, 0.0),
                    child: Transform.rotate(
                      angle: math.pi * -_animation.value,
                      child: Image.asset(
                        'assets/images/others/impostor.png',
                        height: 60.h,
                      ),
                      // child: Container(
                      //   height: 50.h,
                      //   width: 30.w,
                      //   color: Colors.blue,
                      // ),
                    ),
                  );
                }),
          ),
          Align(
            alignment: Alignment.center,
            child: ValueListenableBuilder(
                valueListenable: text,
                builder: (context, value, _) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: kText(
                      // text: 'test',
                      text: text.value,
                      textAlign: TextAlign.center,
                      redShadow: true,
                      color: Colors.white,
                      family: 'Baloo Paaji 2',
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }
}

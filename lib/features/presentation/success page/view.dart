import 'dart:developer';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:amongus_lock/core/states/passkey_state.dart';
import 'package:amongus_lock/core/widgets/common.dart';
import 'package:amongus_lock/features/presentation/splash%20screen/view.dart';
import 'package:amongus_lock/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundpool/soundpool.dart';

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController lockAnimationController;
  List<Animation> lockAnimations = [];

  late Soundpool soundPool;
  late int dialerSoundId;
  late int lockSoundId;

  bool isDialSoundPlaying = false;
  bool isLockSoundPlaying = false;

  @override
  void initState() {
    soundPool = serviceLocator();

    lockAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));

    lockAnimations.add(Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        parent: lockAnimationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOut))));

    lockAnimations.add(Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        parent: lockAnimationController,
        curve: const Interval(0.4, 0.6, curve: Curves.easeInOut))));

    lockAnimations.add(Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: lockAnimationController,
        curve: const Interval(0.8, 1.0, curve: Curves.easeInOut))));

    lockAnimationController.addListener(() {
      if (lockAnimationController.value > 0.4 &&
          lockAnimationController.value <= 0.6 &&
          !isLockSoundPlaying) {
        isLockSoundPlaying = true;
        soundPool.play(lockSoundId);
      } else if (lockAnimationController.value > 0.0 &&
          lockAnimationController.value <= 0.4 &&
          !isDialSoundPlaying) {
        isDialSoundPlaying = true;
        soundPool.play(dialerSoundId);
      } else if (lockAnimations[0].isCompleted ||
          lockAnimations[0].isDismissed) {
        isLockSoundPlaying = false;
      } else if (lockAnimations[1].isCompleted ||
          lockAnimations[1].isDismissed) {
        isDialSoundPlaying = false;
      }
    });

    Future.delayed(const Duration(milliseconds: 50), () async {
      await loadSounds();
      await Future.delayed(const Duration(milliseconds: 650));
      await lockAnimationController.forward();
    });

    super.initState();
  }

  Future loadSounds() async {
    ByteData byteData = await rootBundle.load('assets/sounds/dialer.mp3');
    dialerSoundId = await soundPool.load(byteData);

    byteData = await rootBundle.load('assets/sounds/lock.mp3');
    lockSoundId = await soundPool.load(byteData);

    // await soundPool.play(textSoundId);
  }

  Future resetPasword() async {
    SharedPreferences sharedPreference = serviceLocator();
    await sharedPreference.clear();
    if (mounted) {
      context.read<CorrectPasskeyCubit>().clearPassKey();
      await Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 1000),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(
              opacity: animation,
              child: child,
            ),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const SplashScreen(),
          ),
          (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 19, 19),
      body: AnimatedBuilder(
          animation: lockAnimations[2],
          builder: (context, _) {
            return Stack(
              children: [
                Transform.translate(
                  offset: Offset(0.0, -200.h * lockAnimations[2].value),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.scale(
                        scale: 0.6 * (1 - lockAnimations[2].value) + 0.4,
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            kWidth(double.infinity),
                            AnimatedBuilder(
                                animation: lockAnimations[1],
                                builder: (context, _) {
                                  return Transform.translate(
                                    offset: Offset(
                                        0,
                                        (80.r * lockAnimations[1].value) +
                                            40.r),
                                    child: Image.asset(
                                        'assets/images/lock/handle.png',
                                        width: 200.r),
                                  );
                                }),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/lock/body.png',
                                  width: 250.r,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/lock/marker.png',
                                      height: 15.r,
                                      width: 15.r,
                                      fit: BoxFit.fill,
                                    ),
                                    kHeight(5.h),
                                    AnimatedBuilder(
                                        animation: lockAnimations[0],
                                        builder: (context, _) {
                                          return Transform.rotate(
                                            angle: math.pi *
                                                lockAnimations[0].value,
                                            child: Image.asset(
                                              'assets/images/lock/dialer.png',
                                              width: 155.r,
                                              height: 155.r,
                                              fit: BoxFit.fill,
                                            ),
                                          );
                                        }),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      kHeight(100.h),
                      Opacity(
                        opacity: lockAnimations[2].value,
                        child: GestureDetector(
                          onTap: () async {
                            if (lockAnimationController.isCompleted) {
                              await lockAnimationController.reverse();
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            }
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              kText(
                                text: 'Keep your secrets here..',
                                color: Colors.white,
                                family: 'Silkscreen',
                              ),
                              kHeight(50.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  borderRadius: BorderRadius.circular(5.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.lock,
                                      color: Colors.white,
                                      size: 22.r,
                                    ),
                                    kWidth(10.w),
                                    kText(
                                      text: 'Lock it!',
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Opacity(
                  opacity: lockAnimations[2].value,
                  child: Transform.translate(
                    offset: Offset(
                        size.width / 2 * (1 - lockAnimations[2].value), 0.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Transform.translate(
                        offset: Offset(-20.r, -20.r),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Transform.translate(
                              offset: Offset(-50.r, 0),
                              child: kText(
                                text: 'Reset your password',
                                family: 'Shadows Into Light',
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(5.r, 12.h),
                              child: Container(
                                height: 50.r,
                                width: 2.r,
                                color: Colors.white,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Transform.translate(
                                  offset: Offset(5.r, 0.0),
                                  child: Container(
                                    height: 2.r,
                                    width: 100.r,
                                    color: Colors.white,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 20.r,
                                ),
                                kWidth(10.r),
                                GestureDetector(
                                  onTap: () async => await resetPasword(),
                                  child: SizedBox(
                                    child: Icon(
                                      Icons.refresh,
                                      size: 25.r,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }
}

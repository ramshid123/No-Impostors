import 'package:amongus_lock/core/states/passkey_state.dart';
import 'package:amongus_lock/core/widgets/common.dart';
import 'package:amongus_lock/features/presentation/home%20page/cubit/passkey_cubit.dart';
import 'package:amongus_lock/features/presentation/home%20page/view/widgets.dart';
import 'package:amongus_lock/features/presentation/kickout%20page/view.dart';
import 'package:amongus_lock/features/presentation/success%20page/view.dart';
import 'package:amongus_lock/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soundpool/soundpool.dart';

// const correctPass = '1234';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;
  late AnimationController _keyColorAnimationController;
  late AnimationController _imageMovementController;
  late Animation _imageMovementAnimation;
  late AnimationController _initialiseAnimController;
  late Animation _initialiseAnimation;

  late Soundpool soundPool;
  late int failSoundId;
  late int successSoundId;
  late int pressSoundId;
  late int initialiseSoundId;

  late String correctPass;

  ValueNotifier<bool> isCorrect = ValueNotifier(false);

  @override
  void initState() {
    correctPass = context.read<CorrectPasskeyCubit>().state;
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _keyColorAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _imageMovementController =
        AnimationController(vsync: this, duration: const Duration(seconds: 20));

    _initialiseAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    soundPool = serviceLocator();

    _initialiseAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _initialiseAnimController, curve: Curves.easeInOut));

    _imageMovementAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: Offset(0.w, 0.h), end: Offset(20.w, 20.h)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Offset(20.w, 20.h), end: Offset(20.w, -20.h)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Offset(20.w, -20.h), end: Offset(-20.w, -20.h)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Offset(-20.w, -20.h), end: Offset(-20.w, 20.h)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Offset(-20.w, 20.h), end: Offset(0.w, 0.h)),
          weight: 1),
    ]).animate(_imageMovementController);

    _animation = TweenSequence(
      [
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 2.0), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 2.0, end: -2.0), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -2.0, end: 1.0), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: -1.0), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -1.0, end: 0.0), weight: 1),
      ],
    ).animate(_animationController);

    loadSounds();

    _imageMovementController.repeat();

    // pressSoundId = pool.load(loadMp3AsUint8List());
    super.initState();
  }

  Future loadSounds() async {
    ByteData byteData = await rootBundle.load('assets/sounds/initialise.mp3');
    initialiseSoundId = await soundPool.load(byteData);

    byteData = await rootBundle.load('assets/sounds/fail.mp3');
    failSoundId = await soundPool.load(byteData);

    byteData = await rootBundle.load('assets/sounds/success.mp3');
    successSoundId = await soundPool.load(byteData);

    byteData = await rootBundle.load('assets/sounds/press.mp3');
    pressSoundId = await soundPool.load(byteData);

    // await soundPool.play(textSoundId);
  }

  Future runAnimation(AnimationController animCont) async {
    await animCont.forward();
    if (!isCorrect.value) {
      await Future.delayed(const Duration(seconds: 2), () async {
        if (mounted && animCont == _keyColorAnimationController) {
          await Navigator.of(context).push(PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(
              opacity: animation,
              child: child,
            ),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const KickOutPage(),
          ));
        }
        animCont.reset();
      });
    } else {
      if (mounted && animCont == _keyColorAnimationController) {
        await Navigator.of(context).push(PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SuccessPage(),
        ));
      }
      animCont.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _imageMovementController.dispose();
    _keyColorAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocListener<PasskeyCubit, String>(
      listener: (context, state) async {
        if (state.length >= 4) {
          if (state == correctPass) {
            isCorrect.value = true;
            runAnimation(_keyColorAnimationController);
            soundPool.play(successSoundId);
          } else {
            isCorrect.value = false;
            runAnimation(_animationController);
            soundPool.play(failSoundId);
            runAnimation(_keyColorAnimationController);
          }

          context.read<PasskeyCubit>().clearPassKey();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onVerticalDragUpdate: (details) async {
            if (details.primaryDelta!.isNegative &&
                _initialiseAnimController.isDismissed) {
              soundPool.play(initialiseSoundId);
              await _initialiseAnimController.forward();
            } else if (!details.primaryDelta!.isNegative &&
                _initialiseAnimController.isCompleted) {
              _initialiseAnimController.reverse();
            }
          },
          child: SizedBox(
            height: size.height,
            width: size.width,
            child: Stack(
              children: [
                AnimatedBuilder(
                    animation: _imageMovementAnimation,
                    builder: (context, _) {
                      return Transform.translate(
                        offset: _imageMovementAnimation.value,
                        child: Transform.scale(
                          scale: 1.1,
                          child: Image.asset(
                            'assets/images/others/background.jpg',
                            height: size.height,
                            width: size.width,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }),
                AnimatedBuilder(
                    animation: _initialiseAnimation,
                    builder: (context, _) {
                      return Container(
                        height: size.height,
                        width: size.width,
                        color: Colors.black
                            .withOpacity(0.45 * _initialiseAnimation.value),
                      );
                    }),
                AnimatedBuilder(
                    animation: _initialiseAnimation,
                    builder: (context, _) {
                      return Visibility(
                        visible: _initialiseAnimController.value > 0,
                        child: Transform.translate(
                          offset: Offset(
                              0.0, 50.h * (1 - _initialiseAnimation.value)),
                          child: Opacity(
                            opacity: _initialiseAnimation.value,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                BlocBuilder<PasskeyCubit, String>(
                                  builder: (context, state) {
                                    return AnimatedBuilder(
                                      animation: _animation,
                                      builder: (context, _) {
                                        return Transform.translate(
                                          offset: Offset(
                                              20.w * _animation.value, 0.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              for (int i = 0; i < 4; i++)
                                                HomePageWidgets.inputDigitBox(
                                                    index: i + 1,
                                                    length: state.length),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                                kHeight(40.h),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 25.w),
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      Transform.translate(
                                        offset: Offset(-30, 10.h),
                                        child: Container(
                                          height: 100.h,
                                          width: 100.w,
                                          color: const Color.fromARGB(
                                              255, 142, 142, 142),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black,
                                        padding: EdgeInsets.all(5.r),
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: const Color(0xffa8a9a9),
                                            border: Border.symmetric(
                                              vertical: BorderSide(
                                                color: const Color(0xff444444),
                                                width: 35.r,
                                              ),
                                              horizontal: BorderSide(
                                                color: const Color(0xffdadadb),
                                                width: 35.r,
                                              ),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 15.r),
                                            child: ValueListenableBuilder(
                                                valueListenable: isCorrect,
                                                builder: (context, value, _) {
                                                  return Wrap(
                                                    alignment:
                                                        WrapAlignment.center,
                                                    crossAxisAlignment:
                                                        WrapCrossAlignment
                                                            .center,
                                                    runAlignment:
                                                        WrapAlignment.center,
                                                    runSpacing: 10.r,
                                                    spacing: 10.r,
                                                    children: [
                                                      for (int i = 0;
                                                          i < 9;
                                                          i++)
                                                        HomePageWidgets
                                                            .numberButton(
                                                          context: context,
                                                          value: (i + 1)
                                                              .toString(),
                                                          animationController:
                                                              _keyColorAnimationController,
                                                          isCorrect:
                                                              isCorrect.value,
                                                          pressSoundId:
                                                              pressSoundId,
                                                        ),
                                                      HomePageWidgets
                                                          .numberButton(
                                                        context: context,
                                                        value: '0',
                                                        animationController:
                                                            _keyColorAnimationController,
                                                        isCorrect:
                                                            isCorrect.value,
                                                        pressSoundId:
                                                            pressSoundId,
                                                      )
                                                    ],
                                                  );
                                                }),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: Padding(
                //     padding: EdgeInsets.only(bottom: 10.h),
                //     child: kText(
                //       text: 'React0r v1.0',
                //       // family: 'Baloo Paaji 2',
                //       family: 'Ubuntu',
                //       color: const Color.fromARGB(255, 182, 182, 182),
                //       fontSize: 35,
                //       fontWeight: FontWeight.w100,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

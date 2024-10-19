import 'dart:math' as math;

import 'package:amongus_lock/core/constants/shared_pref_strings.dart';
import 'package:amongus_lock/core/states/passkey_state.dart';
import 'package:amongus_lock/core/widgets/common.dart';
import 'package:amongus_lock/features/presentation/home%20page/view/view.dart';
import 'package:amongus_lock/features/presentation/splash%20screen/widgets.dart';
import 'package:amongus_lock/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _initAnimationController;
  final List<Animation> _initAnimations = [];

  final passwordTextEditingController = TextEditingController();

  @override
  void initState() {
    
    _initAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000));

    _initAnimations.add(Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        parent: _initAnimationController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeInOut))));

    _initAnimations.add(Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        parent: _initAnimationController,
        curve: const Interval(0.4, 0.8, curve: Curves.elasticOut))));

    _initAnimations.add(Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _initAnimationController,
        curve: const Interval(0.8, 1.0, curve: Curves.easeInOut))));

    Future.delayed(
      const Duration(milliseconds: 300),
      () async {
        await _initAnimationController.animateTo(0.8);
        await initLocalStorage();
        await Future.delayed(const Duration(seconds: 2));
        await _initAnimationController.forward();
        if (mounted) {
          await Navigator.of(context).push(PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 1000),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(
              opacity: animation,
              child: child,
            ),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomePage(),
          ));
        }
      },
    );
    super.initState();
  }

  Future initLocalStorage() async {
    SharedPreferences sharedPreference = serviceLocator();
    // await sharedPreference.clear();

    final passKey = sharedPreference.getString(SharedPrefStrings.passKey) ?? '';
    if (passKey.isEmpty) {
      await showPasswordDialogue();
      await sharedPreference.setString(
          SharedPrefStrings.passKey, passwordTextEditingController.text);
      if (mounted) {
        context
            .read<CorrectPasskeyCubit>()
            .updatePassKey(passwordTextEditingController.text);
      }
    } else {
      if (mounted) {
        context.read<CorrectPasskeyCubit>().updatePassKey(passKey);
      }
    }
  }

  Future showPasswordDialogue() async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) =>
          PasswordChangeDialogueBox(
        textController: passwordTextEditingController,
      ),
    );
  }

  @override
  void dispose() {
    _initAnimationController.dispose();
    passwordTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: size.height,
              width: size.width,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.white,
                    Colors.black,
                  ],
                ),
              ),
              child: Transform.translate(
                offset: Offset(0.0, -10.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    kWidth(double.infinity),
                    AnimatedBuilder(
                        animation: _initAnimations[1],
                        builder: (context, _) {
                          return Transform.rotate(
                            angle: math.pi * _initAnimations[1].value,
                            child: Image.asset(
                              'assets/images/icon/logo.png',
                              height: 150.r,
                              width: 150.r,
                            ),
                          );
                        }),
                    kHeight(10.h),
                    kText(
                      text: 'No Impostors',
                      fontSize: 30,
                      family: 'Silkscreen',
                    ),
                  ],
                ),
              ),
            ),
            AnimatedBuilder(
                animation: _initAnimations[2],
                builder: (context, _) {

                  return AnimatedBuilder(
                      animation: _initAnimations[0],
                      builder: (context, _) {
                        return Opacity(
                          opacity: _initAnimationController.value < 0.5
                              ? _initAnimations[0].value
                              : _initAnimations[2].value,
                          child: Container(
                            height: size.height,
                            width: size.width,
                            color: Colors.black,
                          ),
                        );
                      });
                }),
          ],
        ),
      ),
    );
  }
}

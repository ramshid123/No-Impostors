import 'package:amongus_lock/core/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreenWidgets {
  static Widget passwordTextField(
      {required Size size, required TextEditingController textController}) {
    return SizedBox(
      width: size.width * 0.7,
      child: TextFormField(
        textAlign: TextAlign.center,
        controller: textController,
        cursorColor: Colors.black,
        showCursor: false,
        keyboardType: TextInputType.number,
        style: GoogleFonts.ubuntu(
          fontSize: 17,
          color: const Color.fromARGB(255, 0, 0, 0),
          fontWeight: FontWeight.bold,
        ),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
        maxLength: 4,
        decoration: InputDecoration(
          hintText: 'New Password',
          hintStyle: GoogleFonts.ubuntu(
            fontSize: 15,
            color: const Color.fromARGB(255, 95, 95, 95),
          ),
          filled: true,
          fillColor: const Color.fromARGB(255, 219, 219, 219),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.length < 4) {
            return '*Required';
          }
          return null;
        },
      ),
    );
  }
}

class PasswordChangeDialogueBox extends StatelessWidget {
  final TextEditingController textController;
  PasswordChangeDialogueBox({super.key, required this.textController});

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Material(
            color: Colors.transparent,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  kText(
                    text: 'Enter your new password',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    family: 'Ubuntu',
                  ),
                  kHeight(35.h),
                  SplashScreenWidgets.passwordTextField(
                      size: size, textController: textController),
                  kHeight(5.h),
                  GestureDetector(
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      width: size.width * 0.7,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Center(
                        child: kText(
                          text: 'Confirm',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          family: 'Ubuntu',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

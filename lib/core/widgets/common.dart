import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

Widget kText({
  required String text,
  Color color = Colors.black,
  double fontSize = 16,
  FontWeight fontWeight = FontWeight.normal,
  int? maxLines,
  TextAlign textAlign = TextAlign.start,
  bool applyHorizontalSpace = true,
  String family = 'Nunito',
  bool redShadow = false,
}) {
  return Text(
    text,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: TextOverflow.ellipsis,
    textHeightBehavior: TextHeightBehavior(
      applyHeightToFirstAscent: applyHorizontalSpace,
      applyHeightToLastDescent: applyHorizontalSpace,
    ),
    style: GoogleFonts.getFont(
      family,
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
      color: color,
      shadows: redShadow
          ? [
              const BoxShadow(
                color: Colors.red,
                offset: Offset(0, 0),
                blurRadius: 20,
                spreadRadius: 20,
              ),
            ]
          : [],
    ),
  );
}

Widget kHeight(double height) {
  return SizedBox(height: height);
}

Widget kWidth(double width) {
  return SizedBox(width: width);
}

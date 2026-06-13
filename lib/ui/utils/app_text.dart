import 'package:app/ui/helpers/color_helper.dart';
import 'package:app/ui/helpers/font_size_helper.dart';
import 'package:flutter/material.dart';
// ignore: must_be_immutable
class AppText extends StatelessWidget {
  AppText({
    super.key,
    required this.txt,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.fontFamily,
    this.textAlign,
    this.height,
    this.letterspacing,
    this.wordspacing,
    this.decoration,
    this.decorationColor,
    this.textStyle,
    this.maxLines,
    this.overflow,
    this.textDirection,
    this.fromAuthScreen,
  });
  final String txt;
  double? fontSize;
  FontWeight? fontWeight;
  Color? color;
  String? fontFamily;
  TextAlign? textAlign;
  double? height;
  TextDecoration? decoration;
  Color? decorationColor;
  TextStyle? textStyle;
  double? letterspacing;
  double? wordspacing;
  int? maxLines;
  TextOverflow? overflow;
  TextDirection? textDirection;

  // Auth screen
  final bool? fromAuthScreen;

// REASON : one dialog has button inside which  AppText is called
  @override
  Widget build(BuildContext context) {
    return Text(
      softWrap: true,
      txt,
      textDirection: (textDirection != null) ? TextDirection.ltr : null,
      maxLines: maxLines ?? 10,
      // softWrap: softWrap ?? false,
      textAlign: textAlign ?? TextAlign.start,
      overflow: overflow ?? TextOverflow.ellipsis,
      style: textStyle ??
          TextStyle(
            fontFamily: fontFamily ??
                // (ProviderScope.containerOf(context)
                //             .read(appViewModel)
                //             .appLocale
                //             .toString() ==
                //         "ar"
                //     ? "FrutigerLTArabic"
                     "Lato",
            fontSize: fontSize ?? AppFontSize.f14,
            fontWeight: fontWeight ?? FontWeight.w400,

            color: color ?? AppColor.c101010,
            //?? true with this -> not working for all screens

            height: height ?? 1.0,
            letterSpacing: letterspacing ?? 0,
            wordSpacing: wordspacing ?? 0,
            decoration: decoration ?? TextDecoration.none,
            decorationColor: decorationColor ?? color,
            decorationThickness: 1.5,
          ),
    );
  }
}

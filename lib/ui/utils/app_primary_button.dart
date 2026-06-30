import 'package:app/ui/helpers/app_layout_helper.dart';
import 'package:app/ui/helpers/color_helper.dart';
import 'package:app/ui/helpers/font_size_helper.dart';
import 'package:app/ui/utils/app_gradient.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    this.text,
    this.textColor,
    this.child,
    this.width,
    this.progressSize,
    this.progressStrokeWidth = 2,
    this.height,
    this.padding,
    this.isLoading = false,
    this.textStyle,
    this.fontSize,
    this.fontWeight,
    this.buttonStyle,
    this.textDecoration,
    this.color,
    this.buttonColor,
    this.isBorder = false,
    this.borderColor,
    this.borderWidth = 0.5,
    this.isButtonEnable = true,
    this.borderRadius,
    this.fromAuthScreen,
    this.textHeight,
    this.isRow = false,
    this.svg,
    this.boxShadow,
  });

  final String? text;
  final Color? textColor;
  final Widget? child;
  final List<BoxShadow>? boxShadow;
  final TextStyle? textStyle;
  final VoidCallback onPressed;
  final double? width;
  final double? progressSize;
  final double progressStrokeWidth;
  final double? height;
  final EdgeInsets? padding;
  final double? fontSize;
  final FontWeight? fontWeight;
  final BoxDecoration? buttonStyle;
  final bool isLoading;
  final TextDecoration? textDecoration;
  final Color? color;
  final Color? buttonColor;
  final bool isBorder;
  final Color? borderColor;
  final double borderWidth;
  final bool isButtonEnable;
  final double? borderRadius;
  final double? textHeight;
  final bool isRow;
  final Widget? svg;
  final bool? fromAuthScreen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading || !isButtonEnable
          ? null
          : () {
              FocusManager.instance.primaryFocus?.unfocus();
              onPressed();
            },
      child: Container(
        alignment: Alignment.center,
        padding: padding ?? EdgeInsets.zero,
        width: width ?? double.infinity,
        height: height ?? ch(45),
        decoration:
            buttonStyle ??
            BoxDecoration(
              boxShadow:
                  boxShadow ??
                  [
                    BoxShadow(
                      color: AppColor.c000000.withValues(alpha: 0.10),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
              borderRadius: BorderRadius.circular(borderRadius ?? cw(16)),
              color: isButtonEnable
                  ? (buttonColor ?? AppColor.blue2)
                  : AppColor.cFFFFFF,
              gradient: buttonColor == null ? AppGradients.redGradient : null,
              border: isBorder
                  ? Border.all(
                      color: borderColor ?? AppColor.cFFF7EF,
                      width: borderWidth,
                    )
                  : null,
            ),
        child:
            child ??
            (!isLoading
                ? Row(
                    mainAxisAlignment: isRow
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.center,
                    children: [
                      if (text != null)
                        Text(
                          text!,
                          style:
                              textStyle ??
                              TextStyle(
                                fontFamily: "Lato",
                                fontSize: fontSize ?? AppFontSize.f15,
                                color: isButtonEnable
                                    ? textColor ?? Colors.white
                                    : AppColor.c007077,
                                fontWeight: fontWeight ?? FontWeight.w600,
                                decoration:
                                    textDecoration ?? TextDecoration.none,
                                letterSpacing: 0,
                                height: textHeight,
                              ),
                        ),
                      if (isRow && svg != null) ...[const Spacer(), svg!],
                    ],
                  )
                : SizedBox(
                    height: progressSize ?? 20,
                    width: progressSize ?? 20,
                    child: CircularProgressIndicator(
                      strokeWidth: progressStrokeWidth,
                      color: AppColor.cFFFFFF,
                    ),
                  )),
      ),
    );
  }
}

import 'package:app/ui/helpers/app_layout_helper.dart';
import 'package:app/ui/helpers/color_helper.dart';
import 'package:app/ui/helpers/font_size_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget primaryTextField({
  required String hintText,
  TextEditingController? controller,
  Widget? prefixIcon,
  Widget? suffixIcon,
  VoidCallback? onSuffixTap,
  TextInputType? keyboardType,
  TextInputAction? textInputAction,
  List<TextInputFormatter>? inputFormatters,
  Function(String)? onChanged,
  String? Function(String?)? validator,
  Function()? onTap,
  FocusNode? focusNode,
  bool readOnly = false,
  bool obscureText = false,
  bool autoFocus = false,
  TextStyle? labelStyl,
  int? maxLength,
  int maxLines = 1,
  double? height,
  Color? fillColor,
}) {
  final fieldHeight = height ?? 45;
  final isMultiline = maxLines > 1;

  return Container(
    constraints: BoxConstraints(minHeight: fieldHeight),
    child: TextFormField(
      controller: controller,
      focusNode: focusNode,
      readOnly: readOnly,
      autofocus: autoFocus,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLength: maxLength,
      maxLines: obscureText ? 1 : maxLines,
      inputFormatters: inputFormatters,
      textAlignVertical: TextAlignVertical.center,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      cursorColor: AppColor.cFFFFFF,
      style: TextStyle(
        fontSize: AppFontSize.f14,
        fontWeight: FontWeight.w500,
        color: AppColor.cFFFFFF,
      ),
      decoration: InputDecoration(
        counterText: "",
        labelText: hintText,
        labelStyle:
            labelStyl ??
            TextStyle(fontSize: AppFontSize.f14, color: AppColor.themeGrey),
        hintStyle: TextStyle(
          fontSize: AppFontSize.f14,
          color: Colors.grey.shade500,
        ),
        filled: true,
        fillColor: fillColor ?? AppColor.c151515,

        prefixIcon: prefixIcon,

        suffixIcon: suffixIcon != null
            ? IconButton(onPressed: onSuffixTap, icon: suffixIcon)
            : null,

        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),

        suffixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),

        contentPadding: EdgeInsets.symmetric(
          horizontal: cw(14),
          vertical: isMultiline ? ch(14) : ch(12),
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColor.c151515),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColor.c151515),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColor.cFFFFFF, width: 1.3),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      onTap: onTap,
      onChanged: onChanged,
      validator: validator,
    ),
  );
}

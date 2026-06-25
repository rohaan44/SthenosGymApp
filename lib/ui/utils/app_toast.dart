// import 'dart:ui';

// import 'package:another_flushbar/flushbar.dart';
// import 'package:app/main.dart';
// import 'package:app/ui/helpers/app_layout_helper.dart';
// import 'package:app/ui/helpers/color_helper.dart';
// import 'package:app/ui/helpers/font_size_helper.dart';
// import 'package:app/ui/utils/app_text.dart';
// import 'package:app/ui/utils/asset_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';

// void appTopToast({
//   context,
//   message,
//   description,
//   textColor,
//   dismissText,
//   backgroundColor,
//   padding,
//   margin,
//   shape,
//   int? duration,
//   icon,
//   isDismissible = false,
//   ToastType? type,
// }) {
//   Widget getPresentIcon() {
//     switch (type) {
//       case ToastType.success:
//         return Icon(Icons.check, color: AppColor.red);
//       case ToastType.error:
//         return Icon(Icons.check);
//       case ToastType.warning:
//         return Icon(Icons.check);
//       case ToastType.info:
//         return Icon(Icons.check);
//       case ToastType.comingSoon:
//         return Icon(Icons.check);
//       default:
//         return Icon(Icons.check);
//     }
//   }

//   String getPresetTitle() {
//     switch (type) {
//       case ToastType.success:
//         return "Success";
//       case ToastType.error:
//         return "Error";
//       case ToastType.warning:
//         return "Warning";
//       case ToastType.info:
//         return "Info";
//       case ToastType.comingSoon:
//         return "Stay Tuned, Coming Soon!";
//       default:
//         return "Stay Tuned, Coming Soon!";
//     }
//   }
//   // Color getPresentBg() {
//   //   switch (type) {
//   //     case ToastType.success:
//   //       return AppColor.cE9F2EB;
//   //     case ToastType.error:
//   //       return AppColor.cE9F2EB;
//   //     case ToastType.warning:
//   //       return AppColor.cE9F2EB;
//   //     case ToastType.info:
//   //       return AppColor.cE9F2EB;
//   //     case ToastType.comingSoon:
//   //       return AppColor.c282828;
//   //     default:
//   //       return AppColor.cE9F2EB;
//   //   }
//   // }

//   Flushbar(
//     flushbarPosition: FlushbarPosition.TOP,
//     flushbarStyle: FlushbarStyle.FLOATING,
//     backgroundColor: Colors.transparent,
//     // boxShadows: [
//     //   BoxShadow(
//     //     color: AppColor.c000000.withValues(alpha:0.3),
//     //     blurRadius: 4,
//     //     offset: Offset(0, 2),
//     //   ),
//     //   BoxShadow(
//     //     color: AppColor.c000000.withValues(alpha:0.2),
//     //     blurRadius: 6,
//     //     offset: Offset(0, 0),
//     //   ),
//     // ],
//     isDismissible: isDismissible,
//     duration: Duration(seconds: duration ?? 3),
//     dismissDirection: FlushbarDismissDirection.VERTICAL,

//     titleText: Center(
//       child: IntrinsicWidth(
//         child: Container(
//           padding:
//               padding ??
//               EdgeInsets.symmetric(horizontal: cw(16), vertical: ch(14)),
//           decoration: BoxDecoration(
//             color: backgroundColor ?? AppColor.c282828,
//             borderRadius: BorderRadius.circular(cw(100)),
//             boxShadow: [
//               BoxShadow(
//                 color: AppColor.c000000.withValues(alpha: 0.3),
//                 blurRadius: 4,
//                 offset: const Offset(0, 2),
//               ),
//               BoxShadow(
//                 color: AppColor.c000000.withValues(alpha: 0.2),
//                 blurRadius: 6,
//                 offset: const Offset(0, 0),
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               icon ?? getPresentIcon(),
//               SizedBox(width: cw(12)),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     AppText(
//                       txt: (message == null || message.toString().isEmpty)
//                           ? getPresetTitle()
//                           : message,
//                       color: textColor ?? AppColor.cFFFFFF,
//                       fontSize: AppFontSize.f14,
//                       fontWeight:
//                           (description == null ||
//                               description.toString().isEmpty)
//                           ? FontWeight.w500
//                           : FontWeight.w700,
//                       height: 1.2,
//                     ),
//                     if (description != null &&
//                         description.toString().isNotEmpty)
//                       Padding(
//                         padding: EdgeInsets.only(top: ch(2)),
//                         child: AppText(
//                           txt: description ?? "",
//                           color: textColor ?? AppColor.cFFFFFF,
//                           fontSize: AppFontSize.f12,
//                           fontWeight: FontWeight.w500,
//                           height: 1.2,
//                           textAlign: TextAlign.left,
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),

//     messageText: const SizedBox.shrink(),

//     // mainButton: Padding(
//     //   padding: EdgeInsets.only(top: ch(30)),
//     //   child: ButtonBar(
//     //     children: [
//     //       InkWell(
//     //         onTap: () {
//     //           Navigator.pop(appLevelKey.currentContext!);
//     //         },
//     //         child: AppText(
//     //           txt: "Dismiss",
//     //           color: AppColor.cFFFFFF,
//     //           fontSize: AppFontSize.f12,
//     //           fontWeight: FontWeight.w700,
//     //         ),
//     //       )
//     //     ],
//     //   ),
//     // ),
//     margin:
//         margin ??
//         EdgeInsets.only(
//           top: ch(14),
//           left: cw(16),
//           right: cw(16),
//           bottom: ch(16),
//         ),
//     borderRadius: BorderRadius.circular(cw(16)),
//   ).show(appLevelKey.currentContext!);
// }

// enum ToastType { success, error, warning, info, comingSoon }

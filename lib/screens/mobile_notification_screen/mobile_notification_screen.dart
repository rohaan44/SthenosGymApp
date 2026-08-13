import 'package:app/providers/main_dashboard_provider.dart';
import 'package:app/screens/main_dashboard_screen.dart';
import 'package:app/ui/helpers/app_layout_helper.dart';
import 'package:app/ui/helpers/color_helper.dart';
import 'package:app/ui/utils/app_gradient.dart';
import 'package:app/ui/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:app/utils/whatsapp_helper.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MobileNotificationScreen extends StatelessWidget {
  const MobileNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },

          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.c151515,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: AppColor.cFFFFFF),
          ),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppGradients.redGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: AppColor.cFFFFFF,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            AppText(
              txt: "Notifications",
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
      ),
      body: Consumer<MainDashboardProvider>(
        builder: (context, model, _) {
          return Column(
            children: [
              /// Header
              // Container(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 16,
              //     vertical: 14,
              //   ),
              //   child: Row(
              //     children: [
              //       Container(
              //         decoration: BoxDecoration(
              //           gradient: AppGradients.redGradient,
              //         ),
              //         child: Icon(
              //           Icons.notifications_outlined,
              //           color: AppColor.cFFFFFF,
              //         ),
              //       ),

              //       const SizedBox(width: 8),

              //       Expanded(
              //         child: AppText(
              //           txt: "Notifications",
              //           fontSize: 16,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),

              //       // TextButton(
              //       //   onPressed: () {},
              //       //   child: AppText(
              //       //     txt: "View All",
              //       //     fontSize: AppFontSize.f12,
              //       //   ),
              //       // ),
              //     ],
              //   ),
              // ),
              Divider(height: 1),
              Expanded(
                child: Skeletonizer(
                  enabled: false,

                  child: ListView.builder(
                    itemCount: model.visibleCount > model.notifications.length
                        ? model.notifications.length
                        : model.visibleCount,
                    shrinkWrap: true,
                    primary: false,
                    padding: EdgeInsets.zero,

                    itemBuilder: (context, index) {
                      final item = model.notifications[index];

                      return Column(
                        children: [
                          NotificationTile(
                            onNotificationTap: () {},
                            sendReminder: () {
                              final rawPhone = item["phone"]?.toString() ?? "";
                              final phone = rawPhone.replaceAll(
                                RegExp(r'\D'),
                                '',
                              );
                              if (phone.isNotEmpty) {
                                final message = Uri.encodeComponent(
                                  "your fees monthly has beeen expired kindly pay the fees",
                                );
                                launchWhatsApp(phone, message);
                              }
                            },
                            color: item["color"],
                            icon: item["icon"],
                            title: item["title"],
                            subtitle: item["subtitle"],
                            time: item["time"],
                          ),
                          // NotificationTile(
                          //   color: Colors.amber,
                          //   icon: Icons.schedule,
                          //   title: "Membership expires in 3 days",
                          //   subtitle: "Ahmed Ali",
                          //   time: "Today",
                          // ),

                          // NotificationTile(
                          //   color: Colors.red,
                          //   icon: Icons.warning,
                          //   title: "Membership expired today",
                          //   subtitle: "Ali Khan",
                          //   time: "Today",
                          // ),

                          // NotificationTile(
                          //   color: Colors.orange,
                          //   icon: Icons.payment,
                          //   title: "1 Month Fee Pending",
                          //   subtitle: "Salman",
                          //   time: "Yesterday",
                          // ),

                          // NotificationTile(
                          //   color: Colors.grey,
                          //   icon: Icons.person_off,
                          //   title: "Admission Expired",
                          //   subtitle: "Huzaifa",
                          //   time: "15 Jul",
                          // ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              if (model.notifications.length > model.visibleCount)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: ch(10)),
                  child: InkWell(
                    onTap: () {
                      model.setCount();
                      // notificationOverlay?.markNeedsBuild();/
                      // setState(() {
                      //   visibleCount += 10;
                      // });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: ch(12)),
                      child: Text(
                        "Load More",
                        style: TextStyle(
                          color: AppColor.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

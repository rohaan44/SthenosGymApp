import 'dart:ui';
import 'package:app/auth/auth_providers/auth_provider.dart';
import 'package:app/screens/main_dashboard_screen.dart';
import 'package:app/ui/app_primary_button.dart';
import 'package:app/ui/helpers/app_layout_helper.dart';
import 'package:app/ui/helpers/color_helper.dart';
import 'package:app/ui/helpers/font_size_helper.dart';
import 'package:app/ui/utils/app_gradient.dart';
import 'package:app/ui/utils/app_text.dart';
import 'package:app/ui/utils/asset_utils.dart';
import 'package:app/ui/utils/primary_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminSignIn extends StatelessWidget {
  const AdminSignIn({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Full Screen Blur
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppGradients.redGradient,
                    ),
                  ),
                ),
              ),

              Center(
                child: Container(
                  width: isMobile ? double.infinity : 400,
                  height: isMobile ? double.infinity : 600,
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: AppColor.c252525,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          width: isMobile ? double.infinity : 400,
                          // constraints: const BoxConstraints(maxWidth: 500),
                          // padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            // border: Border.all(color: Colors.white12),
                          ),

                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Image.asset(
                                  AssetUtils.titleLogo1,
                                  height: ch(140),
                                  width: cw(140),
                                ),

                                const SizedBox(height: 20),
                                AppText(
                                  txt: "Admin Login",
                                  fontWeight: FontWeight.w700,
                                  fontSize: AppFontSize.f24,
                                ),

                                SizedBox(height: ch(10)),

                                AppText(
                                  txt: "Access your gym management dashboard",
                                  textAlign: TextAlign.center,
                                  fontSize: AppFontSize.f15,
                                  fontWeight: FontWeight.w400,
                                  height: 1.3,
                                  color: AppColor.c5B4B4B4,
                                ),

                                SizedBox(height: ch(20)),

                                // EMAIL FIELD
                                primaryTextField(
                                  controller: auth.emailController,
                                  hintText: "Email",
                                  prefixIcon: Icon(Icons.mail_outline),
                                ),
                                SizedBox(height: ch(20)),

                                primaryTextField(
                                  controller: auth.passwordController,
                                  hintText: "Password",
                                  obscureText: auth.obscurePassword,
                                  prefixIcon: const Icon(
                                    Icons.password_outlined,
                                  ),
                                  suffixIcon: Icon(
                                    auth.obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onSuffixTap: auth.togglePasswordVisibility,
                                ),
                                SizedBox(height: ch(12)),
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: () {},
                                      child: AppText(txt: "Change Password?"),
                                    ),
                                    const Spacer(),

                                    TextButton(
                                      onPressed: () => _forgotPassword(
                                        context,
                                        auth.emailController,
                                        () async {
                                          final success = await auth
                                              .forgotPassword(
                                                auth.emailController.text,
                                              );
                                          if (success) {
                                            Navigator.pop(context);
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  auth.error ?? 'Login failed',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                      child: AppText(
                                        txt: "Forgot Password?",
                                        color: AppColor.blue2,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: ch(24)),
                                AppButton(
                                  isLoading: auth.isLoading,
                                  onPressed: () async {
                                    final success = await auth.signIn(
                                      auth.emailController.text,
                                      auth.passwordController.text,
                                    );
                                    if (success) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MainDashboardScreen(),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            auth.error ?? 'Login failed',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  text: "Login",
                                ),

                                SizedBox(height: ch(20)),

                                Container(
                                  width: double.infinity,
                                  height: 1,
                                  color: AppColor.cFFFFFF,
                                ),
                                const SizedBox(height: 20),

                                const Text(
                                  "STHENOS GYM ADMIN PANEL",
                                  style: TextStyle(
                                    color: Colors.white38,
                                    letterSpacing: 1.5,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

void _forgotPassword(
  BuildContext context,
  TextEditingController email,
  void Function() onPressed,
) async {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: AppColor.c252525,
        title: AppText(txt: "Reset Password", fontSize: AppFontSize.f18),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              txt:
                  "Enter your registered email to receive a password reset link.",
              fontSize: AppFontSize.f14,
            ),
            SizedBox(height: ch(25)),
            primaryTextField(
              controller: email,
              hintText: "Email",
              prefixIcon: Icon(Icons.mail_outline),
            ),
            // TextField(
            //   controller: email,
            //   decoration: const InputDecoration(
            //     labelText: "Email Address",
            //     border: OutlineInputBorder(),
            //   ),
            //   keyboardType: TextInputType.emailAddress,
            // ),
          ],
        ),
        actions: [
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: AppText(
                  txt: "Cancel",
                  fontSize: AppFontSize.f14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.red,
                ),
              ),
              Spacer(),
              AppButton(width: cw(80), onPressed: onPressed, text: "Send Link"),
            ],
          ),
        ],
      );
    },
  );
}

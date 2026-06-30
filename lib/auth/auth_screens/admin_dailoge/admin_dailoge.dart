import 'dart:ui';
import 'package:app/auth/auth_providers/auth_provider.dart';
import 'package:app/screens/main_dashboard_screen.dart';
import 'package:app/ui/helpers/app_layout_helper.dart';
import 'package:app/ui/helpers/color_helper.dart';
import 'package:app/ui/helpers/font_size_helper.dart';
import 'package:app/ui/utils/app_gradient.dart';
import 'package:app/ui/utils/app_text.dart';
import 'package:app/ui/utils/asset_utils.dart';
import 'package:app/ui/utils/primary_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminAuthDialog extends StatefulWidget {
  const AdminAuthDialog({super.key});

  @override
  State<AdminAuthDialog> createState() => _AdminAuthDialogState();
}

class _AdminAuthDialogState extends State<AdminAuthDialog> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  void _signIn() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final email = emailController.text.trim();
    final pass = passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email & Password required")),
      );
      return;
    }

    final success = await auth.signIn(email, pass);

    if (success) {
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainDashboardScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(auth.error ?? "Login failed")));
    }
  }

  void _forgotPassword() async {
    final email = emailController.text.trim();
    final emailInputController = TextEditingController(text: email);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Reset Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Enter your registered email to receive a password reset link.",
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailInputController,
                decoration: const InputDecoration(
                  labelText: "Email Address",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final targetEmail = emailInputController.text.trim();
                if (targetEmail.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Email is required")),
                  );
                  return;
                }
                Navigator.pop(dialogContext);

                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: targetEmail,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Password reset email sent! Check your inbox.",
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  if (mounted) {
                    String errMsg = e.message ?? "Failed to send reset email";
                    if (e.code == 'user-not-found') {
                      errMsg = "No user found with this email address.";
                    } else if (e.code == 'invalid-email') {
                      errMsg = "Invalid email format.";
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errMsg),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text("Send Link"),
            ),
          ],
        );
      },
    );
  }

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
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: AppColor.c252525,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      // Blur Background
                      // BackdropFilter(
                      //   filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      //   child: Container(),
                      // ),
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
                                  height: ch(120),
                                  width: cw(120),
                                ),

                                const SizedBox(height: 20),
                                AppText(
                                  txt: "Admin Login",
                                  fontWeight: FontWeight.w700,
                                  fontSize: AppFontSize.f22,
                                ),

                                // const Text(
                                //   "Admin Login",
                                //   style: TextStyle(
                                //     color: Colors.white,
                                //     fontWeight: FontWeight.bold,
                                //   ),
                                // ),
                                SizedBox(height: 8),

                                const Text(
                                  "Access your gym management dashboard",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 14,
                                  ),
                                ),

                                SizedBox(height: ch(20)),

                                // EMAIL FIELD
                                primaryTextField(
                                  hintText: "Email",
                                  prefixIcon: Icon(Icons.mail_outline),
                                ),
                                const SizedBox(height: 16),

                                primaryTextField(
                                  hintText: "password",
                                  obscureText: true,
                                  prefixIcon: Icon(Icons.password_outlined),

                                  suffixIcon: Icon(Icons.visibility),
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
                                      onPressed: () {},
                                      child: AppText(
                                        txt: "Forgot Password?",
                                        color: AppColor.blue2,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: ch(24)),

                                // LOGIN BUTTON
                                Container(
                                  height: 45,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    gradient: AppGradients.redGradient,
                                  ),
                                  child: Center(child: AppText(txt: "Login")),
                                ),

                                const SizedBox(height: 20),

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

import 'package:app/auth/auth_providers/auth_provider.dart';
import 'package:app/auth/auth_screens/sign_in/sign_in_screen.dart';
import 'package:app/ui/helpers/app_layout_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _signUp() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final email = emailController.text;
    final pass = passwordController.text;

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email & Password required")),
      );
      return;
    }

    final success = await auth.signUp(context, email, pass);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Admin Created Successfully")),
      );

      emailController.clear();
      passwordController.clear();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(auth.error ?? "Signup failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Sign Up")),

      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _signUp,
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Create Admin"),
                  ),
                ),
                SizedBox(height: ch(100)),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignInScreen()),
                    );
                  },

                  child: Text("Sign IN"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

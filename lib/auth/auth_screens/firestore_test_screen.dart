import 'package:app/auth/auth_providers/test_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FirestoreTestScreen extends StatelessWidget {
  const FirestoreTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firestore Test")),
      body: Consumer<FirestoreTestProvider>(
        builder: (context, provider, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () {
                          provider.saveDummyData();
                        },
                  child: provider.isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Save Dummy Data"),
                ),

                const SizedBox(height: 20),

                Text(provider.message, style: const TextStyle(fontSize: 16)),
              ],
            ),
          );
        },
      ),
    );
  }
}

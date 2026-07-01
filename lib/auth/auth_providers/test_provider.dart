import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreTestProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  String message = '';

  Future<void> saveDummyData() async {
    try {
      isLoading = true;
      message = '';
      notifyListeners();

      await _firestore.collection('members').add({
        'name': 'Huzaifa',
        'gym': 'Sthenos Gym',
        'createdAt': Timestamp.now(),
      });

      message = "✅ Data Saved Successfully";
      debugPrint(message);
    } catch (e) {
      message = "❌ Error: $e";
      debugPrint(message);
    }

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
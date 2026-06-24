import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import '../models/models.dart';
import '../service/cloudinary_service.dart';
import 'gym_provider.dart';
import 'package:image_picker/image_picker.dart';

class AddMemberProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final signatureCtrl = TextEditingController();
  final dateSignedCtrl = TextEditingController();
  final startDateCtrl = TextEditingController();
  final otherGoalCtrl = TextEditingController();

  static const membershipPlans = [
    'Monthly - \$40 / month',
    '3-Month Plan - \$110',
    '6-Month Plan - \$210',
    'Annual Plan - \$390',
  ];

  static const fitnessGoalOptions = [
    'General Fitness',
    'Weight Loss',
    'Cardio / Endurance',
    'Flexibility / Mobility',
  ];

  static const addOnOptions = [
    'Personal Training - \$25 / session',
    'Group Classes - \$15 / month',
    'Nutrition Coaching - \$30 / month',
    'Locker Rental - \$10 / month',
    'Towel Service - \$5 / month',
  ];

  static const paymentMethods = ['Credit Card', 'Bank Transfer', 'Cash'];
  static const billingFrequencies = [
    'Monthly',
    'Quarterly',
    'One-time Full Payment',
  ];

  String membership = membershipPlans.first;
  final List<String> fitnessGoals = [];
  String? otherGoal;

  final List<String> addOns = [];
  String paymentMethod = paymentMethods.first;
  String billingFrequency = billingFrequencies.first;

  XFile? imageFile;
  String? imageUrl; // class-level so saveData() can access it
  bool isLoading = false;

  CameraController? cameraController;
  bool isCameraInitialized = false;

  Future<void> initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint("No cameras found");
        return;
      }
      cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await cameraController!.initialize();
      isCameraInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  Future<void> capturePhoto(BuildContext context) async {
    if (cameraController == null || !isCameraInitialized) return;
    try {
      final picked = await cameraController!.takePicture();
      imageFile = picked;
      notifyListeners();
      await disposeCamera();
    } catch (e) {
      debugPrint("Error taking picture: $e");
    }
  }

  Future<void> disposeCamera() async {
    if (cameraController != null) {
      await cameraController!.dispose();
      cameraController = null;
      isCameraInitialized = false;
      notifyListeners();
    }
  }

  final CloudinaryService _cloudinaryService = CloudinaryService();

  void setMembership(String val) {
    membership = val;
    notifyListeners();
  }

  void toggleFitnessGoal(String goal, bool value) {
    value ? fitnessGoals.add(goal) : fitnessGoals.remove(goal);
    notifyListeners();
  }

  void setOtherGoalCheckbox(bool value) {
    otherGoal = value ? '' : null;
    notifyListeners();
  }

  void setOtherGoalText(String val) {
    otherGoal = val;
  }

  void toggleAddOn(String service, bool value) {
    value ? addOns.add(service) : addOns.remove(service);
    notifyListeners();
  }

  void setPaymentMethod(String val) {
    paymentMethod = val;
    notifyListeners();
  }

  void setBillingFrequency(String val) {
    billingFrequency = val;
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source, BuildContext context) async {
    if (!kIsWeb && source == ImageSource.camera) {
      var status = await Permission.camera.status;
      if (status.isDenied) {
        status = await Permission.camera.request();
      }

      if (!status.isGranted) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Camera Permission Required'),
              content: const Text(
                'This app needs camera access to take a profile photo. '
                'Please enable camera permissions in settings.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    openAppSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
        return;
      }
    }

    try {
      final picked = await ImagePicker().pickImage(source: source);
      if (picked != null) {
        imageFile = picked;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> submit(BuildContext context) async {
    if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Email are required.')),
      );
      return;
    }

    if (phoneCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number is required.')),
      );
      return;
    }

    isLoading = true;
    notifyListeners();

    // ── 1. Duplicate phone check ──────────────────────────────────────────
    final duplicate = await _firestore
        .collection('members')
        .where('phone', isEqualTo: phoneCtrl.text.trim())
        .limit(1)
        .get();

    if (duplicate.docs.isNotEmpty) {
      isLoading = false;
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'A member with phone "${phoneCtrl.text.trim()}" already exists.',
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
      return;
    }

    // ── 2. Upload image ───────────────────────────────────────────────────
    if (imageFile != null) {
      imageUrl = await _cloudinaryService.uploadImage(imageFile!);
    }

    if (!context.mounted) return;

    // ── 3. Add to local state ─────────────────────────────────────────────
    final gym = context.read<GymProvider>();
    final newId = gym.members.length + 1;

    if (otherGoal != null && otherGoal!.isNotEmpty) {
      fitnessGoals.add(otherGoal!);
    }

    DateTime parsedJoinDate;
    try {
      parsedJoinDate = DateTime.parse(startDateCtrl.text);
    } catch (_) {
      parsedJoinDate = DateTime.now();
    }

    DateTime expiryDateCalc;
    if (membership.contains('3-Month')) {
      expiryDateCalc = DateTime(
        parsedJoinDate.year,
        parsedJoinDate.month + 3,
        parsedJoinDate.day,
      );
    } else if (membership.contains('6-Month')) {
      expiryDateCalc = DateTime(
        parsedJoinDate.year,
        parsedJoinDate.month + 6,
        parsedJoinDate.day,
      );
    } else if (membership.contains('Annual')) {
      expiryDateCalc = DateTime(
        parsedJoinDate.year + 1,
        parsedJoinDate.month,
        parsedJoinDate.day,
      );
    } else {
      expiryDateCalc = DateTime(
        parsedJoinDate.year,
        parsedJoinDate.month + 1,
        parsedJoinDate.day,
      );
    }

    final newMember = Member(
      id: newId,
      name: nameCtrl.text,
      email: emailCtrl.text,
      phone: phoneCtrl.text,
      membership: membership,
      status: 'Active',
      joinDate: parsedJoinDate.toIso8601String().split('T')[0],
      expiryDate: expiryDateCalc.toIso8601String().split('T')[0],
      profileImageUrl: imageUrl,
      dateOfBirth: dobCtrl.text,
      address: addressCtrl.text,
      fitnessGoals: List.from(fitnessGoals),
      addOnServices: List.from(addOns),
      paymentMethod: paymentMethod,
      billingFrequency: billingFrequency,
      preferredStartDate: startDateCtrl.text,
      signature: signatureCtrl.text,
      dateSigned: dateSignedCtrl.text,
    );

    gym.addMember(newMember);

    // ── 4. Persist to Firestore ───────────────────────────────────────────
    await saveData();

    isLoading = false;
    notifyListeners();

    // ── 5. Clear form on success ──────────────────────────────────────────
    if (message.startsWith('✅')) {
      reset();
      if (context.mounted) Navigator.pop(context);
    } else {
      // Firestore write failed — show error but stay on screen
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Future<int> _getNextMemberId() async {
    final counterRef = _firestore.collection('counters').doc('members');

    return _firestore.runTransaction<int>((transaction) async {
      final snapshot = await transaction.get(counterRef);

      int nextId;
      if (!snapshot.exists) {
        nextId = 1;
        transaction.set(counterRef, {'count': nextId});
      } else {
        final currentCount = (snapshot.data()?['count'] ?? 0) as int;
        nextId = currentCount + 1;
        transaction.update(counterRef, {'count': nextId});
      }
      return nextId;
    });
  }

  // bool isLoading = false;
  String message = '';

  /// Saves member data to Firestore.
  /// Call after [imageUrl] has been set (done automatically by [submit]).
  Future<void> saveData() async {
    DateTime parsedJoinDate;
    try {
      parsedJoinDate = DateTime.parse(startDateCtrl.text);
    } catch (_) {
      parsedJoinDate = DateTime.now();
    }

    DateTime expiryDateCalc;
    if (membership.contains('3-Month')) {
      expiryDateCalc = DateTime(
        parsedJoinDate.year,
        parsedJoinDate.month + 3,
        parsedJoinDate.day,
      );
    } else if (membership.contains('6-Month')) {
      expiryDateCalc = DateTime(
        parsedJoinDate.year,
        parsedJoinDate.month + 6,
        parsedJoinDate.day,
      );
    } else if (membership.contains('Annual')) {
      expiryDateCalc = DateTime(
        parsedJoinDate.year + 1,
        parsedJoinDate.month,
        parsedJoinDate.day,
      );
    } else {
      expiryDateCalc = DateTime(
        parsedJoinDate.year,
        parsedJoinDate.month + 1,
        parsedJoinDate.day,
      );
    }

    try {
      final newId = await _getNextMemberId();
      await _firestore.collection('members').add({
        'gymId': newId.toString(),
        'name': nameCtrl.text,
        'email': emailCtrl.text,
        'phone': phoneCtrl.text.trim(),
        'membership': membership,
        'status': 'Active',
        'joinDate': parsedJoinDate.toIso8601String().split('T')[0],
        'expiryDate': expiryDateCalc.toIso8601String().split('T')[0],
        'lastPaymentDate': DateTime.now().toIso8601String(),
        'image': imageUrl,
        'dateOfBirth': dobCtrl.text,
        'address': addressCtrl.text,
        'fitnessGoals': fitnessGoals,
        'addOnServices': addOns,
        'paymentMethod': paymentMethod,
        'billingFrequency': billingFrequency,
        'preferredStartDate': startDateCtrl.text,
        'signature': signatureCtrl.text,
        'dateSigned': dateSignedCtrl.text,
      });

      message = '✅ Data Saved Successfully';
      debugPrint(message);
    } catch (e) {
      message = '❌ Error: $e';
      debugPrint(message);
    }

    notifyListeners();
  }

  /// Clears all form fields and resets state back to defaults.
  /// Called automatically after a successful save.
  void reset() {
    nameCtrl.clear();
    emailCtrl.clear();
    phoneCtrl.clear();
    dobCtrl.clear();
    addressCtrl.clear();
    signatureCtrl.clear();
    dateSignedCtrl.clear();
    startDateCtrl.clear();
    otherGoalCtrl.clear();

    membership = membershipPlans.first;
    fitnessGoals.clear();
    otherGoal = null;
    addOns.clear();
    paymentMethod = paymentMethods.first;
    billingFrequency = billingFrequencies.first;
    imageFile = null;
    imageUrl = null;
    message = '';

    notifyListeners();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    dobCtrl.dispose();
    addressCtrl.dispose();
    signatureCtrl.dispose();
    dateSignedCtrl.dispose();
    startDateCtrl.dispose();
    otherGoalCtrl.dispose();
    cameraController?.dispose();
    super.dispose();
  }
}

import 'package:app/models/models.dart';
import 'package:app/ui/helpers/web_cam_screen.dart';
import 'package:app/ui/utils/app_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import '../../service/cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';

class EditMemberProvider extends ChangeNotifier {
  Member? originalMember;
  final formKey = GlobalKey<FormState>();

  final emergencyCtrl = TextEditingController();
  final cnicCtrl = TextEditingController();
  final injuryCtrl = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final signatureCtrl = TextEditingController();
  final manuallyAmountCtrl = TextEditingController();

  final dateSignedCtrl = TextEditingController();
  final startDateCtrl = TextEditingController();
  final otherGoalCtrl = TextEditingController();

  static const membershipPlans = ['Monthly - Rs. 4000 / month', "Manually"];

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

  static const paymentMethods = [
    // 'Credit Card',
    'Bank Transfer', 'Cash',
  ];
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

  void loadMemberData(Member member) {
    print("LOAD HASH => $hashCode");
    originalMember = member;
    imageFile = null; // <-- IMPORTANT

    imageUrl = member.profileImageUrl ?? "";
    nameCtrl.text = member.name;
    emailCtrl.text = member.email;
    phoneCtrl.text = member.phone;
    emergencyCtrl.text = member.emergencyContact;
    dobCtrl.text = member.dateOfBirth ?? "";
    addressCtrl.text = member.address ?? "";
    cnicCtrl.text = member.cnic;
    injuryCtrl.text = member.injury ?? "";
    startDateCtrl.text = member.joinDate;

    // ❗ Missing tha
    membership = member.membership;

    notifyListeners();
  }

  bool hasAnyChanges() {
    if (originalMember == null) return false;
    // print("imageFile => ${imageFile != null}");
    // print(
    //   "name: ${nameCtrl.text.trim()} != ${originalMember!.name} => ${nameCtrl.text.trim() != originalMember!.name}",
    // );
    // print(
    //   "email: ${emailCtrl.text.trim()} != ${originalMember!.email} => ${emailCtrl.text.trim() != originalMember!.email}",
    // );
    // print(
    //   "phone: ${phoneCtrl.text.trim()} != ${originalMember!.phone} => ${phoneCtrl.text.trim() != originalMember!.phone}",
    // );
    // print(
    //   "address: '${addressCtrl.text.trim()}' != '${originalMember!.address}' => ${addressCtrl.text.trim() != (originalMember!.address ?? '')}",
    // );
    // print(
    //   "dob: '${dobCtrl.text.trim()}' != '${originalMember!.dateOfBirth}' => ${dobCtrl.text.trim() != (originalMember!.dateOfBirth ?? '')}",
    // );
    // print(
    //   "cnic: '${cnicCtrl.text.trim()}' != '${originalMember!.cnic}' => ${cnicCtrl.text.trim() != originalMember!.cnic}",
    // );
    // print(
    //   "emergency: '${emergencyCtrl.text.trim()}' != '${originalMember!.emergencyContact}' => ${emergencyCtrl.text.trim() != originalMember!.emergencyContact}",
    // );
    // print(
    //   "injury: '${injuryCtrl.text.trim()}' != '${originalMember!.injury}' => ${injuryCtrl.text.trim() != (originalMember!.injury ?? '')}",
    // );
    // print(
    //   "membership: '$membership' != '${originalMember!.membership}' => ${membership != originalMember!.membership}",
    // );
    // print(
    //   "joinDate: '${startDateCtrl.text.trim()}' != '${originalMember!.joinDate}' => ${startDateCtrl.text.trim() != originalMember!.joinDate}",
    // );
    // print(
    //   "image: '$imageUrl' != '${originalMember!.profileImageUrl}' => ${imageUrl != (originalMember!.profileImageUrl ?? '')}",
    // );

    return nameCtrl.text.trim() != originalMember!.name.trim() ||
        emailCtrl.text.trim() != originalMember!.email.trim() ||
        phoneCtrl.text.trim() != originalMember!.phone.trim() ||
        addressCtrl.text.trim() != (originalMember!.address ?? '').trim() ||
        dobCtrl.text.trim() != (originalMember!.dateOfBirth ?? '').trim() ||
        cnicCtrl.text.trim() != originalMember!.cnic.trim() ||
        emergencyCtrl.text.trim() != originalMember!.emergencyContact.trim() ||
        injuryCtrl.text.trim() != (originalMember!.injury ?? '').trim() ||
        membership.trim() != originalMember!.membership.trim() ||
        imageUrl != (originalMember!.profileImageUrl ?? '') ||
        imageFile != null;
  }

  // bool hasAnyChanges() {
  //   if (originalMember == null) return false;

  //   final old = originalMember!;

  //   final checks = <String, bool>{
  //     "name": nameCtrl.text.trim() != old.name.trim(),
  //     "email": emailCtrl.text.trim() != old.email.trim(),
  //     "phone": phoneCtrl.text.trim() != old.phone.trim(),
  //     "address": addressCtrl.text.trim() != (old.address ?? "").trim(),
  //     "dob": dobCtrl.text.trim() != (old.dateOfBirth ?? "").trim(),
  //     "cnic": cnicCtrl.text.trim() != old.cnic.trim(),
  //     "emergency": emergencyCtrl.text.trim() != old.emergencyContact.trim(),
  //     "injury": injuryCtrl.text.trim() != (old.injury ?? "").trim(),
  //     "membership": membership.trim() != old.membership.trim(),
  //     "imageFile": imageFile != null,
  //   };

  //   checks.forEach((key, value) {
  //     print("$key => $value");
  //   });

  //   return checks.values.any((e) => e);
  // }

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
    if (kIsWeb && source == ImageSource.camera) {
      final XFile? file = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WebCameraScreen()),
      );

      if (file != null) {
        imageFile = file;
        notifyListeners();
      }

      return;
    }

    // Mobile ka purana logic

    if (!kIsWeb && source == ImageSource.camera) {
      var status = await Permission.camera.request();

      if (!status.isGranted) {
        openAppSettings();
        return;
      }
    }

    final picked = await ImagePicker().pickImage(source: source);

    if (picked != null) {
      imageFile = picked;
      notifyListeners();
    }
  }

  // Future<void> pickImage(ImageSource source, BuildContext context) async {
  //   if (!kIsWeb && source == ImageSource.camera) {
  //     var status = await Permission.camera.status;
  //     if (status.isDenied) {
  //       status = await Permission.camera.request();
  //     }

  //     if (!status.isGranted) {
  //       if (context.mounted) {
  //         showDialog(
  //           context: context,
  //           builder: (ctx) => AlertDialog(
  //             title: const Text('Camera Permission Required'),
  //             content: const Text(
  //               'This app needs camera access to take a profile photo. '
  //               'Please enable camera permissions in settings.',
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.pop(ctx),
  //                 child: const Text('Cancel'),
  //               ),
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.pop(ctx);
  //                   openAppSettings();
  //                 },
  //                 child: const Text('Open Settings'),
  //               ),
  //             ],
  //           ),
  //         );
  //       }
  //       return;
  //     }
  //   }

  //   try {
  //     final picked = await ImagePicker().pickImage(source: source);
  //     if (picked != null) {
  //       imageFile = picked;
  //       notifyListeners();
  //     }
  //   } catch (e) {
  //     debugPrint("Error picking image: $e");
  //   }
  // }

  Future<void> submit(BuildContext context) async {
    // print("SUBMIT HASH => $hashCode");
    print(hasAnyChanges());
    // print(nameCtrl.text);
    // print(originalMember?.name);
    // Image Validation
    // if (imageFile == null && (imageUrl == null || imageUrl!.isEmpty)) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Image is mandatory!'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   // appTopToast(message: "Please select a profile image");
    //   return;
    // }

    // Form Validation
    if (!formKey.currentState!.validate()) {
      return;
    }

    final changed = hasAnyChanges();

    // print("changed = $changed");

    // if (!changed) {
    //   print("NO CHANGES");
    //   return;
    // }

    // print("BEFORE SAVE");

    if (!changed) {
      // print("NO CHANGES");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText(
            txt:
                "No changes detected. Please update at least one field before saving.",
          ),
          backgroundColor: Color(0xffFF3A2F),
        ),
      );
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      final duplicate = await _firestore
          .collection('members')
          .where('phone', isEqualTo: phoneCtrl.text.trim())
          .get();

      final isDuplicate = duplicate.docs.any(
        (doc) => doc.id != originalMember!.docId,
      );

      if (isDuplicate) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Member with phone ${phoneCtrl.text.trim()} already exists',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }

        isLoading = false;
        notifyListeners();
        return;
      }

      // ── Duplicate Phone Check ──────────────────────────
      // final duplicate = await _firestore
      //     .collection('members')
      //     .where('phone', isEqualTo: phoneCtrl.text.trim())
      //     .limit(1)
      //     .get();

      // if (duplicate.docs.isNotEmpty) {
      //   if (context.mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: Text(
      //           'Member with phone ${phoneCtrl.text.trim()} already exists',
      //         ),
      //         backgroundColor: Colors.red,
      //       ),
      //     );
      //   }

      // isLoading = false;
      // notifyListeners();
      // return;
      // }

      // ── Upload Image ───────────────────────────────────
      if (imageFile != null) {
        imageUrl = await _cloudinaryService.uploadImage(imageFile!);
      }

      // print("BEFORE SAVE");

      // ── Save Data ──────────────────────────────────────
      await saveData();

      // ── Success ────────────────────────────────────────
      if (message.startsWith('✅')) {
        reset();

        if (context.mounted) {
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // bool isLoading = false;
  String message = '';

  List gymTermsAndConditions = [
    {
      'id': 1,
      'title': 'Membership & Fees',
      'points': [
        'Admission and monthly fees are non-refundable.',
        'Members are required to pay their monthly fees within the first week of every month.',
        'Failure to pay fees on time may result in suspension of membership.',
        'No refunds will be given for unused membership periods.',
      ],
    },
    {
      'id': 2,
      'title': 'Workout Policy',
      'points': [
        'Members are allotted a total workout duration of 45 minutes per session.',
        'Keep noise levels reasonable and avoid disrupting others’ workouts.',
        'Wipe down equipment after use and return weights to their designated racks.',
      ],
    },
    {
      'id': 3,
      'title': 'Personal Belongings',
      'points': [
        'STHENOS BODY FITNESS AND GYM is not responsible for lost, stolen, or damaged personal items.',
        'The gym is not responsible for vehicles parked on the premises.',
        'Members park their vehicles at their own risk.',
      ],
    },
    {
      'id': 4,
      'title': 'Equipment & Property',
      'points': [
        'Members are liable for any damage caused to gym equipment or property.',
        'Any repair costs or applicable fines resulting from damage must be paid by the member.',
        'Report any damaged or malfunctioning equipment to staff immediately.',
      ],
    },
    {
      'id': 5,
      'title': 'Health & Safety',
      'points': [
        'Members must disclose any health conditions that may affect their ability to exercise safely.',
        'The gym is not responsible for injuries, accidents, or health issues arising from the use of equipment or facilities.',
        'Smoking, spitting, and littering within the gym premises are strictly prohibited.',
      ],
    },
    {
      'id': 6,
      'title': 'Membership Termination & Updates',
      'points': [
        'The gym reserves the right to terminate a membership for violation of these terms.',
        'STHENOS BODY FITNESS AND GYM reserves the right to modify these terms and conditions at any time.',
      ],
    },
  ];

  /// Saves member data to Firestore.
  /// Call after [imageUrl] has been set (done automatically by [submit]).
  Future<void> saveData() async {
    // print("🔥 saveData() called");

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
      // final newId = await _getNextMemberId();

      await _firestore.collection('members').doc(originalMember!.docId).update({
        'gymId': originalMember!.id.toString(),
        'name': nameCtrl.text,
        'email': emailCtrl.text,
        'phone': phoneCtrl.text.trim(),
        'membership': membership == "Manually"
            ? manuallyAmountCtrl.text
            : membership,
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
        // 'billingFrequency': billingFrequency,
        'preferredStartDate': startDateCtrl.text,
        // 'signature': signatureCtrl.text,
        // 'dateSigned': dateSignedCtrl.text,
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

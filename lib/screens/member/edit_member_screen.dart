// ignore_for_file: unused_element_parameter

import 'dart:io';

import 'package:app/models/models.dart';
import 'package:app/providers/members/edit_member_provider.dart';
import 'package:app/providers/members/members_provider.dart';
import 'package:app/ui/helpers/color_helper.dart';
import 'package:app/ui/utils/asset_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../../ui/utils/app_text.dart';
import '../../ui/helpers/font_size_helper.dart';
import '../../ui/helpers/app_layout_helper.dart';

// / All mutable state lives exclusively in [EditMemberProvider].
/// This widget contains zero setState / StatefulWidget usage.
/// It is split into targeted Consumer sections so only the widgets
/// that actually depend on changing state are rebuilt.
class EditMemberScreen extends StatefulWidget {
  const EditMemberScreen({super.key});

  @override
  State<EditMemberScreen> createState() => _EditMemberScreenState();
}

class _EditMemberScreenState extends State<EditMemberScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<EditMemberProvider>();

      final member =
          context.read<MembersProvider>().memberData["members"] as Member;

      p.loadMemberData(member);
    });
  }

  @override
  Widget build(BuildContext context) {
    // context.read — just reads the provider once, no rebuild triggered here.
    // Individual Consumer widgets below subscribe to only what they need.
    final p = context.read<EditMemberProvider>();

    return Scaffold(
      body: Form(
        key: p.formKey,
        child: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: pagePadding(context),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // InkWell(
                                //   onTap: () {
                                //     print("memberData ${member.name}");
                                //   },
                                //   child: Icon(Icons.abc),
                                // ),
                                // Image.network(
                                //   "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQF2UfXfypDgiIIEszOsrOtTTYJjHFuVVpjOw&s",
                                // ),
                                Image.asset(
                                  AssetUtils.titleLogo1,
                                  height: ch(200),
                                  width: cw(200),
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                            SizedBox(height: ch(20)),
                            // ── Profile picture ──────────────────────────────
                            // Only rebuilds when imageFile changes
                            Consumer<EditMemberProvider>(
                              builder: (ctx, p, __) => Center(
                                child: GestureDetector(
                                  onTap: () => _showImageSourcePicker(ctx, p),
                                  child: CircleAvatar(
                                    radius: cw(40).clamp(32.0, 56.0),
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: p.imageFile != null
                                        ? (kIsWeb
                                              ? NetworkImage(p.imageFile!.path)
                                                    as ImageProvider
                                              : FileImage(
                                                  File(p.imageFile!.path),
                                                ))
                                        : null,
                                    child: p.imageFile == null
                                        ? Icon(
                                            Icons.camera_alt,
                                            size: cw(24),
                                            color: AppColor.primary,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: ch(8)),
                            Center(
                              child: AppText(
                                txt: 'Tap to upload profile picture',
                                color: AppColor.primary,
                                fontSize: AppFontSize.f12,
                              ),
                            ),

                            // ── Personal Details ─────────────────────────────
                            // Text fields are pure input widgets; their internal
                            // state is managed by TextEditingController (no
                            // setState, no rebuilds needed for typing).
                            _sectionTitle('Edit Personal Details'),
                            Container(
                              padding: EdgeInsets.all(cw(16)),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ResponsiveRow(
                                    gap: cw(16),
                                    children: [
                                      _labeledField(
                                        label: 'Full Name',
                                        controller: p.nameCtrl,
                                        prefixIcon: const Icon(
                                          Icons.person_outline,
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return "Full Name is required";
                                          }
                                          return null;
                                        },
                                      ),
                                      _labeledField(
                                        prefixIcon: Icon(Icons.mail_outline),
                                        label: 'Email',
                                        controller: p.emailCtrl,
                                        type: TextInputType.emailAddress,

                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return "Email is required";
                                          }

                                          if (!RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                          ).hasMatch(value)) {
                                            return "Enter valid email";
                                          }

                                          return null;
                                        },
                                      ),
                                      _labeledField(
                                        label: 'Phone Number',
                                        controller: p.phoneCtrl,
                                        prefixIcon: Icon(Icons.phone_outlined),
                                        inputFormator: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        type: TextInputType.phone,
                                        maxLenth: 11,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return "Phone Number is required";
                                          }

                                          if (value.length < 11) {
                                            return "Enter valid phone number";
                                          }

                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: ch(16)),
                                  _ResponsiveRow(
                                    gap: cw(16),
                                    flexes: const [1, 2],
                                    children: [
                                      _dateField(
                                        context: context,
                                        label: 'Date of Birth',
                                        controller: p.dobCtrl,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return "DOB is required";
                                          }
                                          return null;
                                        },
                                      ),
                                      _labeledField(
                                        label: 'Emergency Contact Number',
                                        controller: p.emergencyCtrl,
                                        prefixIcon: Icon(CupertinoIcons.phone),
                                        maxLenth: 11,
                                        type: TextInputType.phone,
                                        inputFormator: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return "Emergency Contact is required";
                                          }

                                          if (value.length < 11) {
                                            return "Enter valid contact number";
                                          }

                                          return null;
                                        },
                                      ),
                                      _labeledField(
                                        label: 'Cnic Number',
                                        maxLenth: 13,
                                        controller: p.cnicCtrl,
                                        prefixIcon: Icon(Icons.badge_outlined),
                                        type: TextInputType.phone,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return "CNIC is required";
                                          }

                                          if (!RegExp(
                                            r'^\d{13}$',
                                          ).hasMatch(value)) {
                                            return "CNIC must be 13 digits";
                                          }

                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: ch(16)),

                                  _ResponsiveRow(
                                    gap: cw(16),
                                    flexes: const [1, 1],
                                    children: [
                                      _labeledField(
                                        label: 'Address',
                                        controller: p.addressCtrl,
                                        prefixIcon: Icon(Icons.badge_outlined),

                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return "Address is required";
                                          }
                                          return null;
                                        },
                                      ),
                                      _labeledField(
                                        label: 'Muscle Injury (Optional)',
                                        controller: p.injuryCtrl,
                                        prefixIcon: Icon(
                                          Icons.personal_injury_outlined,
                                        ),
                                        type: TextInputType.phone,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            _sectionTitle('Terms & Conditions'),

                            Container(
                              padding: EdgeInsets.all(cw(16)),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: p.gymTermsAndConditions.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: ch(12)),
                                itemBuilder: (context, index) {
                                  final item = p.gymTermsAndConditions[index];

                                  return Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title'],
                                          style: TextStyle(
                                            fontSize: AppFontSize.f14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        SizedBox(height: ch(12)),

                                        ...List.generate(
                                          (item['points'] as List).length,
                                          (pointIndex) => Padding(
                                            padding: EdgeInsets.only(
                                              bottom: ch(12),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "• ",
                                                  style: TextStyle(
                                                    fontSize: AppFontSize.f16,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1.1,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    item['points'][pointIndex],
                                                    style: TextStyle(
                                                      fontSize: AppFontSize.f14,
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
                              ),
                            ),

                            // TermsAndConditionsScreen(),

                            // Container(
                            //   padding: EdgeInsets.all(cw(16)),
                            //   decoration: BoxDecoration(
                            //     color: Colors.grey.shade100,
                            //     borderRadius: BorderRadius.circular(8),
                            //   ),
                            //   child: TermsAndConditionsScreen(),
                            // ),

                            // ── Membership Plan ──────────────────────────────
                            // Rebuilds when membership selection changes
                            _sectionTitle('Membership Plan'),
                            Consumer<EditMemberProvider>(
                              builder: (_, p, __) => Wrap(
                                spacing: cw(24),
                                runSpacing: ch(4),
                                children: EditMemberProvider.membershipPlans
                                    .map(
                                      (plan) => _radioOption<String>(
                                        title: plan,
                                        value: plan,
                                        groupValue: p.membership,
                                        onChanged: (v) => p.setMembership(v!),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),

                            // ── Fitness Goals & Add-Ons ──────────────────────
                            // Rebuilds when checkboxes change
                            // SizedBox(height: ch(8)),
                            // Consumer<EditMemberProvider>(
                            //   builder: (_, p, __) => _ResponsiveRow(
                            //     gap: cw(32),
                            //     crossAxisAlignmentStart: true,
                            //     children: [
                            //       Column(
                            //         crossAxisAlignment: CrossAxisAlignment.start,
                            //         children: [
                            //           AppText(
                            //             txt: 'Fitness Goals (optional)',
                            //             fontWeight: FontWeight.bold,
                            //             fontSize: AppFontSize.f15,
                            //           ),
                            //           SizedBox(height: ch(8)),
                            //           ...EditMemberProvider.fitnessGoalOptions.map(
                            //             (goal) => _circleCheckOption(
                            //               title: goal,
                            //               value: p.fitnessGoals.contains(goal),
                            //               onChanged: (v) =>
                            //                   p.toggleFitnessGoal(goal, v),
                            //             ),
                            //           ),
                            //           Row(
                            //             children: [
                            //               Checkbox(
                            //                 value: p.otherGoal != null,
                            //                 shape: const CircleBorder(),
                            //                 onChanged: (v) => p
                            //                     .setOtherGoalCheckbox(v ?? false),
                            //               ),
                            //               AppText(txt: 'Other: '),
                            //               Expanded(
                            //                 child: TextField(
                            //                   controller: p.otherGoalCtrl,
                            //                   enabled: p.otherGoal != null,
                            //                   onChanged: p.setOtherGoalText,
                            //                   decoration: const InputDecoration(
                            //                     isDense: true,
                            //                     border: UnderlineInputBorder(),
                            //                   ),
                            //                 ),
                            //               ),
                            //             ],
                            //           ),
                            //         ],
                            //       ),
                            //       Column(
                            //         crossAxisAlignment: CrossAxisAlignment.start,
                            //         children: [
                            //           AppText(
                            //             txt: 'Add-On Services',
                            //             fontWeight: FontWeight.bold,
                            //             fontSize: AppFontSize.f15,
                            //           ),
                            //           SizedBox(height: ch(8)),
                            //           ...EditMemberProvider.addOnOptions.map(
                            //             (service) => _circleCheckOption(
                            //               title: service,
                            //               value: p.addOns.contains(service),
                            //               onChanged: (v) =>
                            //                   p.toggleAddOn(service, v),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ],
                            //   ),
                            // ),

                            // ── Payment Details ──────────────────────────────
                            // Rebuilds when payment method / billing changes
                            SizedBox(height: ch(16)),
                            Consumer<EditMemberProvider>(
                              builder: (_, p, __) => _ResponsiveRow(
                                gap: cw(24),
                                crossAxisAlignmentStart: true,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppText(
                                        txt: 'Payment Method',
                                        fontWeight: FontWeight.bold,
                                        fontSize: AppFontSize.f15,
                                      ),
                                      SizedBox(height: ch(8)),
                                      ...EditMemberProvider.paymentMethods.map(
                                        (m) => _radioOption<String>(
                                          title: m,
                                          value: m,
                                          groupValue: p.paymentMethod,
                                          onChanged: (v) =>
                                              p.setPaymentMethod(v!),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Column(
                                  //   crossAxisAlignment: CrossAxisAlignment.start,
                                  //   children: [
                                  //     AppText(
                                  //       txt: 'Billing Frequency',
                                  //       fontWeight: FontWeight.bold,
                                  //       fontSize: AppFontSize.f15,
                                  //     ),
                                  //     SizedBox(height: ch(8)),
                                  //     ...EditMemberProvider.billingFrequencies.map(
                                  //       (m) => _radioOption<String>(
                                  //         title: m,
                                  //         value: m,
                                  //         groupValue: p.billingFrequency,
                                  //         onChanged: (v) =>
                                  //             p.setBillingFrequency(v!),
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  // Column(
                                  //   crossAxisAlignment: CrossAxisAlignment.start,
                                  //   children: [
                                  //     _dateField(
                                  //       context: context,
                                  //       label: 'Preferred Start Date',
                                  //       controller: p.startDateCtrl,
                                  //     ),
                                  //   ],
                                  // ),
                                ],
                              ),
                            ),
                            SizedBox(height: ch(100)),
                            // ── Terms & Signature ────────────────────────────
                            // Static text + static input fields — no Consumer needed
                            // SizedBox(height: ch(20)),
                            // AppText(
                            //   txt:
                            //       'By signing this form, I confirm that all information provided is accurate. I agree to the membership terms, including payment obligations, and consent to receive gym notifications, updates, and offers via email or SMS.',
                            //   fontSize: AppFontSize.f12,
                            //   color: Colors.grey,
                            // ),
                            // SizedBox(height: ch(16)),
                            // _ResponsiveRow(
                            //   gap: cw(16),
                            //   children: [
                            //     _labeledField(
                            //       label: 'Type Signature',
                            //       controller: p.signatureCtrl,
                            //     ),
                            //     _dateField(
                            //       context: context,
                            //       label: 'Date Signed',
                            //       controller: p.dateSignedCtrl,
                            //     ),
                            //   ],
                            // ),
                            // SizedBox(height: ch(24)),
                          ],
                        ),
                      ),
                    ),

                    // // ── Submit button ────────────────────────────────────────
                    // // Only rebuilds when isLoading changes
                    // SizedBox(height: ch(16)),
                    // Consumer<EditMemberProvider>(
                    //   builder: (ctx, p, __) => SizedBox(
                    //     width: double.infinity,
                    //     height: ch(45),
                    //     child: FilledButton(
                    //       onPressed: p.isLoading ? null : () => p.submit(ctx),
                    //       child: p.isLoading
                    //           ? SizedBox(
                    //               width: cw(20),
                    //               height: ch(20),
                    //               child: const CircularProgressIndicator(
                    //                 strokeWidth: 2,
                    //                 color: Colors.white,
                    //               ),
                    //             )
                    //           : AppText(txt: 'Add Member', color: Colors.white),
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(height: ch(8)),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Consumer<EditMemberProvider>(
                builder: (ctx, p, __) => InkWell(
                  onTap: p.isLoading ? null : () => p.submit(ctx),

                  child: Container(
                    height: ch(45),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(cw(16)),
                    ),
                    child: p.isLoading
                        ? Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Center(
                            child: AppText(
                              txt: 'Add Member',
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            // ── Loading overlay ──────────────────────────────────────────────
            // Only rebuilds when isLoading changes
            // Consumer<EditMemberProvider>(
            //   builder: (_, p, __) => p.isLoading
            //       ? Positioned.fill(
            //           child: Container(
            //             color: Colors.black12,
            //             child: const Center(child: CircularProgressIndicator()),
            //           ),
            //         )
            //       : const SizedBox.shrink(),
            // ),
          ],
        ),
      ),
    );
  }

  void _showImageSourcePicker(
    BuildContext context,
    EditMemberProvider provider,
  ) {
    if (kIsWeb) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  txt: 'Select Image Source',
                  fontSize: AppFontSize.f16,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: ch(16)),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: Colors.blue,
                  ),
                  title: AppText(
                    txt: 'Upload from Gallery',
                    fontSize: AppFontSize.f14,
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    provider.pickImage(ImageSource.gallery, context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.green,
                  ),
                  title: AppText(
                    txt: 'Take a Photo',
                    fontSize: AppFontSize.f14,
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showWebCameraDialog(context, provider);
                  },
                ),
                SizedBox(height: ch(12)),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: ch(20), horizontal: cw(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  txt: 'Select Image Source',
                  fontSize: AppFontSize.f16,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: ch(16)),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: Colors.blue,
                  ),
                  title: AppText(
                    txt: 'Upload from Gallery',
                    fontSize: AppFontSize.f14,
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    provider.pickImage(ImageSource.gallery, context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.green,
                  ),
                  title: AppText(
                    txt: 'Take a Photo',
                    fontSize: AppFontSize.f14,
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    provider.pickImage(ImageSource.camera, context);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _showWebCameraDialog(BuildContext context, EditMemberProvider provider) {
    provider.initCamera();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ChangeNotifierProvider.value(
        value: provider,
        child: Consumer<EditMemberProvider>(
          builder: (dialogCtx, p, _) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: cw(450).clamp(320.0, 500.0),
                padding: EdgeInsets.all(cw(16)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      txt: 'Camera Preview',
                      fontSize: AppFontSize.f16,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: ch(16)),
                    Container(
                      width: cw(400).clamp(280.0, 440.0),
                      height: ch(300).clamp(200.0, 330.0),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: p.isCameraInitialized && p.cameraController != null
                          ? CameraPreview(p.cameraController!)
                          : const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                    ),
                    SizedBox(height: ch(16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            p.disposeCamera();
                            Navigator.pop(dialogCtx);
                          },
                          child: const Text('Cancel'),
                        ),
                        SizedBox(width: cw(8)),
                        ElevatedButton(
                          onPressed: p.isCameraInitialized
                              ? () async {
                                  await p.capturePhoto(dialogCtx);
                                  if (dialogCtx.mounted) {
                                    Navigator.pop(dialogCtx);
                                  }
                                }
                              : null,
                          child: const Text('Capture'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ).then((_) {
      provider.disposeCamera();
    });
  }
}

// ── Section helpers (pure stateless functions, no Provider dependency) ─────────

Widget _sectionTitle(String title) {
  return Padding(
    padding: EdgeInsets.only(top: ch(24), bottom: ch(12)),
    child: AppText(
      txt: title,
      fontSize: AppFontSize.f16,
      fontWeight: FontWeight.bold,
    ),
  );
}

Widget _labeledField({
  required String label,
  required Widget prefixIcon,
  required TextEditingController controller,
  TextInputType type = TextInputType.text,
  String? Function(String?)? validator,
  List<TextInputFormatter>? inputFormator,
  int? maxLenth,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: type,
    maxLength: maxLenth,
    validator: validator,
    inputFormatters: inputFormator,
    decoration: InputDecoration(
      labelText: label,
      counterText: "", // 👈 hide counter
      prefixIcon: prefixIcon,

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),

        borderSide: BorderSide(color: const Color(0xFF2563EB), width: 2),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
    ),
  );
}

// Widget _labeledField({
//   required String label,
//   required TextEditingController controller,
//   TextInputType type = TextInputType.text,
// }) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       AppText(
//         txt: label,
//         fontWeight: FontWeight.bold,
//         fontSize: AppFontSize.f13,
//       ),
//       SizedBox(height: ch(6)),
//       TextField(
//         controller: controller,
//         keyboardType: type,
//         decoration: InputDecoration(
//           isDense: true,
//           contentPadding: EdgeInsets.symmetric(
//             horizontal: cw(12),
//             vertical: ch(12),
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(6),
//             borderSide: BorderSide(color: Colors.grey.shade400),
//           ),
//         ),
//       ),
//     ],
//   );
// }

Widget _dateField({
  required BuildContext context,
  required String label,
  required TextEditingController controller,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    readOnly: true,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Icons.calendar_month_outlined),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),

        borderSide: BorderSide(color: const Color(0xFF2563EB), width: 2),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
    ),
    onTap: () async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColor.primary, // selected date color
                onPrimary: Colors.white, // selected date text
                onSurface: Colors.black, // normal dates
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        controller.text =
            '${picked.month.toString().padLeft(2, '0')}/'
            '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.year}';
      }
    },
  );
}

// Widget _dateField({
//   required BuildContext context,
//   required String label,
//   required TextEditingController controller,
// }) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       AppText(
//         txt: label,
//         fontWeight: FontWeight.bold,
//         fontSize: AppFontSize.f13,
//       ),
//       SizedBox(height: ch(6)),
//       TextField(
//         controller: controller,
//         readOnly: true,
//         decoration: InputDecoration(
//           hintText: 'mm/dd/yyyy',
//           isDense: true,
//           suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
//           contentPadding: EdgeInsets.symmetric(
//             horizontal: cw(12),
//             vertical: ch(12),
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(6),
//             borderSide: BorderSide(color: Colors.grey.shade400),
//           ),
//         ),
//         onTap: () async {
//           final picked = await showDatePicker(
//             context: context,
//             initialDate: DateTime.now(),
//             firstDate: DateTime(1900),
//             lastDate: DateTime(2100),
//           );
//           if (picked != null) {
//             controller.text =
//                 '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
//           }
//         },
//       ),
//     ],
//   );
// }

Widget _radioOption<T>({
  required String title,
  required T value,
  required T groupValue,
  required ValueChanged<T?> onChanged,
}) {
  return InkWell(
    onTap: () => onChanged(value),
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: ch(2)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<T>(
            activeColor: AppColor.primary,
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          AppText(txt: title, fontSize: AppFontSize.f13),
        ],
      ),
    ),
  );
}

// Widget _circleCheckOption({
//   required String title,
//   required bool value,
//   required ValueChanged<bool> onChanged,
// }) {
//   return InkWell(
//     onTap: () => onChanged(!value),
//     child: Padding(
//       padding: EdgeInsets.symmetric(vertical: ch(2)),
//       child: Row(
//         children: [
//           Checkbox(
//             value: value,
//             shape: const CircleBorder(),
//             visualDensity: VisualDensity.compact,
//             materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//             onChanged: (v) => onChanged(v ?? false),
//           ),
//           AppText(txt: title, fontSize: AppFontSize.f13),
//         ],
//       ),
//     ),
//   );
// }

/// Lays [children] side-by-side on wide screens, stacks vertically on phones.
class _ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final List<int> flexes;
  final double gap;
  final double breakpoint;
  final bool crossAxisAlignmentStart;

  const _ResponsiveRow({
    required this.children,
    this.flexes = const [],
    this.gap = 16,
    this.breakpoint = 600,
    this.crossAxisAlignmentStart = false,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= breakpoint;

    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) SizedBox(height: gap),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: crossAxisAlignmentStart
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          Expanded(
            flex: flexes.length == children.length ? flexes[i] : 1,
            child: children[i],
          ),
          if (i != children.length - 1) SizedBox(width: gap),
        ],
      ],
    );
  }
}

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  // ── Updated Gym Data List ──────────────────────────────────────────────────
  final List<Map<String, dynamic>> gymTermsAndConditions = const [
    {
      'id': 1,
      'title': 'Fees & Payments',
      'points': [
        'Admission and Monthly fees are strictly non-refundable under any circumstances.',
        'Members are required to pay their monthly fees within the first week of every month.',
        'Failure to pay fees on time may result in a temporary suspension of membership.',
        'No refunds or extensions will be given for unused membership periods or absences.',
      ],
    },
    {
      'id': 2,
      'title': 'Workout & Timing Rules',
      'points': [
        'Members are allotted a total workout duration of maximum 45 minutes per session to avoid overcrowding.',
        'Please keep noise levels reasonable, avoid grunting excessively, and do not disrupt others\' workouts.',
        'Wipe down equipment after use for hygiene and return weights/dumbbells to their racks.',
      ],
    },
    {
      'id': 3,
      'title': 'Property Damage & Valuables',
      'points': [
        'STHENOS BODY FITNESS AND GYM is not responsible for lost, stolen, or damaged personal items.',
        'Vehicles parked outside or on the premises are at the owner\'s own risk.',
        'Members are fully liable for any damage they cause to gym equipment/property and must pay for the repairs or applicable fines.',
      ],
    },
    {
      'id': 4,
      'title': 'Health, Safety & Injuries',
      'points': [
        'Members must disclose any pre-existing health conditions or medical injuries that may affect their ability to exercise safely.',
        'The gym is not responsible for injuries, accidents, or medical issues arising from the use of equipment or facilities.',
        'Report any damaged, loose, or malfunctioning equipment to the gym staff immediately instead of using it.',
      ],
    },
    {
      'id': 5,
      'title': 'Prohibited Activities & Conduct',
      'points': [
        'Smoking, spitting, eating, and littering within the gym premises are strictly prohibited.',
        'Misbehavior with gym staff, trainers, or co-members will result in immediate termination of membership.',
        'STHENOS BODY FITNESS AND GYM reserves the right to terminate any membership or modify these terms at any time without prior notice.',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,

      primary: false,
      padding: const EdgeInsets.all(16.0),
      itemCount: gymTermsAndConditions.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: ch(24)), // Categories ke beech space
      itemBuilder: (context, index) {
        final term = gymTermsAndConditions[index];
        final List<String> points = term['points'] as List<String>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Heading / Category
            Text(
              '${term['id']}. ${term['title']}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: ch(12)),

            // Points View with Custom Node
            ListView.builder(
              shrinkWrap: true,
              primary: false,
              // physics:
              //     const NeverScrollableScrollPhysics(), // Main ListView ke andar smoothly scroll hone ke liye
              itemCount: points.length,
              itemBuilder: (ctx, i) {
                return IntrinsicHeight(
                  // 👈 Yeh line aur node line ki height auto-match karega
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Custom Node Line & Dot Design ─────────────────────
                      Column(
                        children: [
                          // Node Point Dot
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(
                              top: 6,
                            ), // Text ke mutabik centring
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB), // Primary Blue
                              shape: BoxShape.circle,
                            ),
                          ),
                          // Node Line (Tab tak dikhegi jab tak aakhri point nahi aata)
                          if (i != points.length - 1)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: const Color(
                                  0xFFE5E7EB,
                                ), // Light gray linking line
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                        width: cw(14),
                      ), // Node aur Text ke darmiyan space
                      // ── Text Content ──────────────────────────────────────
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: 14.0,
                          ), // Points ke darmiyan gap
                          child: Text(
                            points[i],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4B5563),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../providers/add_member_provider.dart';
import '../ui/utils/app_text.dart';
import '../ui/helpers/font_size_helper.dart';
import '../ui/helpers/app_layout_helper.dart';

/// All mutable state lives exclusively in [AddMemberProvider].
/// This widget contains zero setState / StatefulWidget usage.
/// It is split into targeted Consumer sections so only the widgets
/// that actually depend on changing state are rebuilt.
class AddMemberScreen extends StatelessWidget {
  const AddMemberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // context.read — just reads the provider once, no rebuild triggered here.
    // Individual Consumer widgets below subscribe to only what they need.
    final p = context.read<AddMemberProvider>();

    return Scaffold(
      body: Stack(
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
                          // ── Profile picture ──────────────────────────────
                          // Only rebuilds when imageFile changes
                          Consumer<AddMemberProvider>(
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
                                          color: Colors.grey,
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
                              color: Colors.grey,
                              fontSize: AppFontSize.f12,
                            ),
                          ),

                          // ── Personal Details ─────────────────────────────
                          // Text fields are pure input widgets; their internal
                          // state is managed by TextEditingController (no
                          // setState, no rebuilds needed for typing).
                          _sectionTitle('Personal Details'),
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
                                    ),
                                    _labeledField(
                                      label: 'Email Address',
                                      controller: p.emailCtrl,
                                      type: TextInputType.emailAddress,
                                    ),
                                    _labeledField(
                                      label: 'Phone Number',
                                      controller: p.phoneCtrl,
                                      type: TextInputType.phone,
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
                                    ),
                                    _labeledField(
                                      label: 'Address',
                                      controller: p.addressCtrl,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // ── Membership Plan ──────────────────────────────
                          // Rebuilds when membership selection changes
                          _sectionTitle('Membership Plan'),
                          Consumer<AddMemberProvider>(
                            builder: (_, p, __) => Wrap(
                              spacing: cw(24),
                              runSpacing: ch(4),
                              children: AddMemberProvider.membershipPlans
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
                          SizedBox(height: ch(8)),
                          Consumer<AddMemberProvider>(
                            builder: (_, p, __) => _ResponsiveRow(
                              gap: cw(32),
                              crossAxisAlignmentStart: true,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      txt: 'Fitness Goals (optional)',
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppFontSize.f15,
                                    ),
                                    SizedBox(height: ch(8)),
                                    ...AddMemberProvider.fitnessGoalOptions.map(
                                      (goal) => _circleCheckOption(
                                        title: goal,
                                        value: p.fitnessGoals.contains(goal),
                                        onChanged: (v) =>
                                            p.toggleFitnessGoal(goal, v),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: p.otherGoal != null,
                                          shape: const CircleBorder(),
                                          onChanged: (v) =>
                                              p.setOtherGoalCheckbox(v ?? false),
                                        ),
                                        AppText(txt: 'Other: '),
                                        Expanded(
                                          child: TextField(
                                            controller: p.otherGoalCtrl,
                                            enabled: p.otherGoal != null,
                                            onChanged: p.setOtherGoalText,
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              border: UnderlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      txt: 'Add-On Services',
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppFontSize.f15,
                                    ),
                                    SizedBox(height: ch(8)),
                                    ...AddMemberProvider.addOnOptions.map(
                                      (service) => _circleCheckOption(
                                        title: service,
                                        value: p.addOns.contains(service),
                                        onChanged: (v) =>
                                            p.toggleAddOn(service, v),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // ── Payment Details ──────────────────────────────
                          // Rebuilds when payment method / billing changes
                          SizedBox(height: ch(16)),
                          Consumer<AddMemberProvider>(
                            builder: (_, p, __) => _ResponsiveRow(
                              gap: cw(24),
                              crossAxisAlignmentStart: true,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      txt: 'Payment Method',
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppFontSize.f15,
                                    ),
                                    SizedBox(height: ch(8)),
                                    ...AddMemberProvider.paymentMethods.map(
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      txt: 'Billing Frequency',
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppFontSize.f15,
                                    ),
                                    SizedBox(height: ch(8)),
                                    ...AddMemberProvider.billingFrequencies.map(
                                      (m) => _radioOption<String>(
                                        title: m,
                                        value: m,
                                        groupValue: p.billingFrequency,
                                        onChanged: (v) =>
                                            p.setBillingFrequency(v!),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _dateField(
                                      context: context,
                                      label: 'Preferred Start Date',
                                      controller: p.startDateCtrl,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // ── Terms & Signature ────────────────────────────
                          // Static text + static input fields — no Consumer needed
                          SizedBox(height: ch(20)),
                          AppText(
                            txt:
                                'By signing this form, I confirm that all information provided is accurate. I agree to the membership terms, including payment obligations, and consent to receive gym notifications, updates, and offers via email or SMS.',
                            fontSize: AppFontSize.f12,
                            color: Colors.grey,
                          ),
                          SizedBox(height: ch(16)),
                          _ResponsiveRow(
                            gap: cw(16),
                            children: [
                              _labeledField(
                                label: 'Type Signature',
                                controller: p.signatureCtrl,
                              ),
                              _dateField(
                                context: context,
                                label: 'Date Signed',
                                controller: p.dateSignedCtrl,
                              ),
                            ],
                          ),
                          SizedBox(height: ch(24)),
                        ],
                      ),
                    ),
                  ),

                  // ── Submit button ────────────────────────────────────────
                  // Only rebuilds when isLoading changes
                  SizedBox(height: ch(16)),
                  Consumer<AddMemberProvider>(
                    builder: (ctx, p, __) => SizedBox(
                      width: double.infinity,
                      height: ch(45),
                      child: FilledButton(
                        onPressed:
                            p.isLoading ? null : () => p.submit(ctx),
                        child: p.isLoading
                            ? SizedBox(
                                width: cw(20),
                                height: ch(20),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : AppText(
                                txt: 'Add Member',
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: ch(8)),
                ],
              ),
            ),
          ),

          // ── Loading overlay ──────────────────────────────────────────────
          // Only rebuilds when isLoading changes
          Consumer<AddMemberProvider>(
            builder: (_, p, __) => p.isLoading
                ? Positioned.fill(
                    child: Container(
                      color: Colors.black12,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _showImageSourcePicker(BuildContext context, AddMemberProvider provider) {
    if (kIsWeb) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: Colors.blue),
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
                  leading: const Icon(Icons.camera_alt_outlined, color: Colors.green),
                  title: AppText(
                    txt: 'Take a Photo',
                    fontSize: AppFontSize.f14,
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showWebCameraDialog(context, provider);
                  },
                ),
                const SizedBox(height: 12),
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
            padding: EdgeInsets.symmetric(
              vertical: ch(20),
              horizontal: cw(16),
            ),
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
                  leading: const Icon(Icons.photo_library_outlined, color: Colors.blue),
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
                  leading: const Icon(Icons.camera_alt_outlined, color: Colors.green),
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

  void _showWebCameraDialog(BuildContext context, AddMemberProvider provider) {
    provider.initCamera();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ChangeNotifierProvider.value(
        value: provider,
        child: Consumer<AddMemberProvider>(
          builder: (dialogCtx, p, _) {
            return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                            child: CircularProgressIndicator(color: Colors.white),
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
  required TextEditingController controller,
  TextInputType type = TextInputType.text,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText(txt: label, fontWeight: FontWeight.bold, fontSize: AppFontSize.f13),
      SizedBox(height: ch(6)),
      TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: cw(12),
            vertical: ch(12),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
        ),
      ),
    ],
  );
}

Widget _dateField({
  required BuildContext context,
  required String label,
  required TextEditingController controller,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText(txt: label, fontWeight: FontWeight.bold, fontSize: AppFontSize.f13),
      SizedBox(height: ch(6)),
      TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          hintText: 'mm/dd/yyyy',
          isDense: true,
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
          contentPadding: EdgeInsets.symmetric(
            horizontal: cw(12),
            vertical: ch(12),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
        ),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            controller.text =
                '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
          }
        },
      ),
    ],
  );
}

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

Widget _circleCheckOption({
  required String title,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return InkWell(
    onTap: () => onChanged(!value),
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: ch(2)),
      child: Row(
        children: [
          Checkbox(
            value: value,
            shape: const CircleBorder(),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (v) => onChanged(v ?? false),
          ),
          AppText(txt: title, fontSize: AppFontSize.f13),
        ],
      ),
    ),
  );
}

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

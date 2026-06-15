import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/gym_provider.dart';
import '../service/cloudinary_service.dart';
import '../shared_widgets.dart';

class AddMemberModal extends StatefulWidget {
  const AddMemberModal({super.key});

  @override
  State<AddMemberModal> createState() => _AddMemberModalState();
}

class _AddMemberModalState extends State<AddMemberModal> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final signatureCtrl = TextEditingController();
  final dateSignedCtrl = TextEditingController();
  final startDateCtrl = TextEditingController();

  String _membership = 'Monthly - \$40 / month';
  final List<String> _fitnessGoals = [];
  String? _otherGoal;
  final otherGoalCtrl = TextEditingController();

  final List<String> _addOns = [];
  String _paymentMethod = 'Credit Card';
  String _billingFrequency = 'Monthly';

  XFile? _imageFile;
  bool _isLoading = false;

  final CloudinaryService _cloudinaryService = CloudinaryService();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Email are required.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? imageUrl;
    if (_imageFile != null) {
      imageUrl = await _cloudinaryService.uploadImage(_imageFile!);
    }

    if (!mounted) return;

    final provider = context.read<GymProvider>();
    final newId = provider.members.length + 1;

    if (_otherGoal != null && _otherGoal!.isNotEmpty) {
      _fitnessGoals.add(_otherGoal!);
    }

    final newMember = Member(
      id: newId,
      name: nameCtrl.text,
      email: emailCtrl.text,
      phone: phoneCtrl.text,
      membership: _membership,
      status: 'Active',
      joinDate: startDateCtrl.text.isNotEmpty ? startDateCtrl.text : 'Today',
      expiryDate: '1 Year from today', // Placeholder
      profileImageUrl: imageUrl,
      dateOfBirth: dobCtrl.text,
      address: addressCtrl.text,
      fitnessGoals: _fitnessGoals,
      addOnServices: _addOns,
      paymentMethod: _paymentMethod,
      billingFrequency: _billingFrequency,
      preferredStartDate: startDateCtrl.text,
      signature: signatureCtrl.text,
      dateSigned: dateSignedCtrl.text,
    );

    provider.addMember(newMember);

    setState(() {
      _isLoading = false;
    });

    Navigator.pop(context);
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Add New Member',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _imageFile != null
                                  ? (kIsWeb 
                                      ? NetworkImage(_imageFile!.path) as ImageProvider 
                                      : FileImage(File(_imageFile!.path)))
                                  : null,
                              child: _imageFile == null
                                  ? const Icon(Icons.camera_alt,
                                      size: 30, color: Colors.grey)
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                            child: Text('Tap to upload profile picture',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12))),

                        _sectionTitle('Personal Details'),
                        customTf('Full Name', nameCtrl),
                        const SizedBox(height: 12),
                        customTf('Email Address', emailCtrl,
                            type: TextInputType.emailAddress),
                        const SizedBox(height: 12),
                        customTf('Phone Number', phoneCtrl,
                            type: TextInputType.phone),
                        const SizedBox(height: 12),
                        customTf('Date of Birth (mm/dd/yyyy)', dobCtrl),
                        const SizedBox(height: 12),
                        customTf('Address', addressCtrl),

                        _sectionTitle('Membership Plan'),
                        ...[
                          'Monthly - \$40 / month',
                          '3-Month Plan - \$110',
                          '6-Month Plan - \$210',
                          'Annual Plan - \$390'
                        ].map((plan) => RadioListTile(
                              title: Text(plan),
                              value: plan,
                              groupValue: _membership,
                              onChanged: (val) =>
                                  setState(() => _membership = val.toString()),
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            )),

                        _sectionTitle('Fitness Goals (optional)'),
                        ...[
                          'General Fitness',
                          'Weight Loss',
                          'Cardio / Endurance',
                          'Flexibility / Mobility'
                        ].map((goal) => CheckboxListTile(
                              title: Text(goal),
                              value: _fitnessGoals.contains(goal),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _fitnessGoals.add(goal);
                                  } else {
                                    _fitnessGoals.remove(goal);
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            )),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _otherGoal != null,
                                onChanged: (val) {
                                  setState(() {
                                    _otherGoal = val == true ? '' : null;
                                  });
                                },
                              ),
                              const Text('Other: '),
                              Expanded(
                                child: TextField(
                                  controller: otherGoalCtrl,
                                  onChanged: (val) => _otherGoal = val,
                                  enabled: _otherGoal != null,
                                  decoration: const InputDecoration(
                                      isDense: true,
                                      border: UnderlineInputBorder()),
                                ),
                              ),
                            ],
                          ),
                        ),

                        _sectionTitle('Add-On Services'),
                        ...[
                          'Personal Training - \$25 / session',
                          'Group Classes - \$15 / month',
                          'Nutrition Coaching - \$30 / month',
                          'Locker Rental - \$10 / month',
                          'Towel Service - \$5 / month'
                        ].map((service) => CheckboxListTile(
                              title: Text(service),
                              value: _addOns.contains(service),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _addOns.add(service);
                                  } else {
                                    _addOns.remove(service);
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            )),

                        _sectionTitle('Payment Details'),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Payment Method',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  ...['Credit Card', 'Bank Transfer', 'Cash']
                                      .map((m) => RadioListTile(
                                            title: Text(m,
                                                style: const TextStyle(
                                                    fontSize: 13)),
                                            value: m,
                                            groupValue: _paymentMethod,
                                            onChanged: (val) => setState(() =>
                                                _paymentMethod =
                                                    val.toString()),
                                            contentPadding: EdgeInsets.zero,
                                            dense: true,
                                          )),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Billing Frequency',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  ...[
                                    'Monthly',
                                    'Quarterly',
                                    'One-time Full Payment'
                                  ].map((m) => RadioListTile(
                                        title: Text(m,
                                            style:
                                                const TextStyle(fontSize: 13)),
                                        value: m,
                                        groupValue: _billingFrequency,
                                        onChanged: (val) => setState(() =>
                                            _billingFrequency = val.toString()),
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        customTf('Preferred Start Date (mm/dd/yyyy)',
                            startDateCtrl),

                        _sectionTitle('Terms & Signature'),
                        const Text(
                          'By signing this form, I confirm that all information provided is accurate. I agree to the membership terms, including payment obligations, and consent to receive gym notifications, updates, and offers via email or SMS.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                                child: customTf('Type Signature', signatureCtrl)),
                            const SizedBox(width: 12),
                            Expanded(
                                child:
                                    customTf('Date Signed', dateSignedCtrl)),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Add Member'),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

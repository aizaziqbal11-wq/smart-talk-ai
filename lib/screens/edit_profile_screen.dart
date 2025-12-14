import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/responsive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  File? _pickedImage;
  bool _saving = false;
  final _profile = ProfileService();

  Future<void> _pickImage() async {
    final p = ImagePicker();
    final XFile? pic = await p.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pic != null) {
      setState(() => _pickedImage = File(pic.path));
    }
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _saving = true);

    String? photoUrl;
    if (_pickedImage != null) {
      photoUrl = await _profile.uploadProfileImage(
        uid: user.uid,
        file: _pickedImage!,
      );
    }

    await _profile.createOrUpdateProfile(
      uid: user.uid,
      name: _nameController.text.trim(),
      photoUrl: photoUrl,
    );

    // update auth profile for convenience
    await user.updateDisplayName(_nameController.text.trim());
    if (photoUrl != null) await user.updatePhotoURL(photoUrl);

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    final u = FirebaseAuth.instance.currentUser;
    _nameController.text = u?.displayName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: MaxWidth(
          maxWidth: 720,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 720) {
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 64,
                              backgroundImage: _pickedImage != null
                                  ? FileImage(_pickedImage!)
                                  : (user?.photoURL != null
                                        ? NetworkImage(user!.photoURL!)
                                              as ImageProvider
                                        : null),
                              child:
                                  _pickedImage == null && user?.photoURL == null
                                  ? const Icon(Icons.add_a_photo, size: 32)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _saving
                              ? const CircularProgressIndicator()
                              : SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _save,
                                    child: const Text('Save'),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Display name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // additional profile fields could go here
                        ],
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!)
                          : (user?.photoURL != null
                                ? NetworkImage(user!.photoURL!) as ImageProvider
                                : null),
                      child: _pickedImage == null && user?.photoURL == null
                          ? const Icon(Icons.add_a_photo, size: 32)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _saving
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _save,
                            child: const Text('Save'),
                          ),
                        ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

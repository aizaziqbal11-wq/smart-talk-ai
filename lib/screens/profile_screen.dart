import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/profile_service.dart';
import 'edit_profile_screen.dart';
import 'privacy_policy_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = ProfileService();
    final user = AuthService().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
        future: user == null
            ? Future.value(null)
            : profile.getProfile(user.uid),
        builder: (context, snapshot) {
          String name = user?.displayName ?? 'User Name';
          String? photoUrl = user?.photoURL;
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.data();
            if (data != null) {
              name = data['name'] ?? name;
              photoUrl = data['photoUrl'] ?? photoUrl;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: photoUrl != null
                    ? NetworkImage(photoUrl)
                    : const AssetImage('assets/profile.png') as ImageProvider,
              ),
              const SizedBox(height: 10),
              Center(child: Text(name, style: const TextStyle(fontSize: 18))),
              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Edit Profile"),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text("Privacy Policy"),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                ),
              ),
              const ListTile(
                leading: Icon(Icons.description),
                title: Text("Terms & Conditions"),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout"),
                onTap: () async {
                  await AuthService().logout();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

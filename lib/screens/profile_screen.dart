import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage("assets/profile.png"),
          ),
          SizedBox(height: 10),
          Center(
              child: Text("User Name",
                  style: TextStyle(fontSize: 18))),
          SizedBox(height: 20),

          ListTile(
            leading: Icon(Icons.edit),
            title: Text("Edit Profile"),
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text("Privacy Policy"),
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text("Terms & Conditions"),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Logout"),
          ),
        ],
      ),
    );
  }
}

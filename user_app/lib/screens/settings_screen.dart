import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String userId = "";
  String token = "";
  String name = "";
  String email = "";
  String location = "";

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final oldPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();

  bool editName = false;
  bool editEmail = false;
  bool editLocation = false;
  bool editPassword = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? "";
      token = prefs.getString('token') ?? "";
      name = prefs.getString('userName') ?? "";
      email = prefs.getString('userEmail') ?? "";
      location = prefs.getString('userLocation') ?? "";

      nameCtrl.text = name;
      emailCtrl.text = email;
      locationCtrl.text = location;
    });
  }

  Future<void> _updateSingleField(String field, String value) async {
    final success = await ProfileService.updateField(
      token: token,
      userId: userId,
      body: {field: value},
    );

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      if (field == "name") {
        prefs.setString('userName', value);
        setState(() => name = value);
      } else if (field == "email") {
        prefs.setString('userEmail', value);
        setState(() => email = value);
      } else if (field == "location") {
        prefs.setString('userLocation', value);
        setState(() => location = value);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$field updated successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update $field")),
      );
    }
  }

  Future<void> _updatePassword() async {
    if (oldPassCtrl.text.isEmpty || newPassCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill password fields")),
      );
      return;
    }

    final success = await ProfileService.changePassword(
      token: token,
      userId: userId,
      oldPassword: oldPassCtrl.text,
      newPassword: newPassCtrl.text,
    );

    if (success) {
      oldPassCtrl.clear();
      newPassCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Old password incorrect")),
      );
    }
  }

  Widget _editableField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onEdit,
    required VoidCallback onUpdate,
  }) {
    return ListTile(
      title: isEditing
          ? TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      )
          : Text("$label: ${controller.text}"),
      trailing: isEditing
          ? ElevatedButton(
        onPressed: onUpdate,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFe23744),
        ),
        child: const Text("Update"),
      )
          : IconButton(
        icon: const Icon(Icons.edit),
        onPressed: onEdit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color(0xFFe23744),
      ),
      body: ListView(
        children: [
          _editableField(
            label: "Name",
            controller: nameCtrl,
            isEditing: editName,
            onEdit: () => setState(() => editName = true),
            onUpdate: () {
              setState(() => editName = false);
              _updateSingleField("name", nameCtrl.text.trim());
            },
          ),
          _editableField(
            label: "Email",
            controller: emailCtrl,
            isEditing: editEmail,
            onEdit: () => setState(() => editEmail = true),
            onUpdate: () {
              setState(() => editEmail = false);
              _updateSingleField("email", emailCtrl.text.trim());
            },
          ),
          _editableField(
            label: "Location",
            controller: locationCtrl,
            isEditing: editLocation,
            onEdit: () => setState(() => editLocation = true),
            onUpdate: () {
              setState(() => editLocation = false);
              _updateSingleField("location", locationCtrl.text.trim());
            },
          ),
          ListTile(
            title: editPassword
                ? Column(
              children: [
                TextField(
                  controller: oldPassCtrl,
                  decoration:
                  const InputDecoration(labelText: "Old Password"),
                  obscureText: true,
                ),
                TextField(
                  controller: newPassCtrl,
                  decoration:
                  const InputDecoration(labelText: "New Password"),
                  obscureText: true,
                ),
              ],
            )
                : const Text("Password: ********"),
            trailing: editPassword
                ? ElevatedButton(
              onPressed: () {
                setState(() => editPassword = false);
                _updatePassword();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFe23744),
              ),
              child: const Text("Update"),
            )
                : IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => editPassword = true),
            ),
          ),
        ],
      ),
    );
  }
}

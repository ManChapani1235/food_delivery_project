import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthToggleScreen extends StatefulWidget {
  const AuthToggleScreen({super.key});

  @override
  State<AuthToggleScreen> createState() => _AuthToggleScreenState();
}

class _AuthToggleScreenState extends State<AuthToggleScreen> {
  bool showLogin = true;

  void toggleScreen() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6347), // Tomato Orange
      body: Row(
        children: [
          Expanded(
            child: Center(
              child: showLogin ? const LoginScreen() : const RegisterScreen(),
            ),
          ),
          Container(
            width: 200,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  showLogin ? 'New here?' : 'Already have an account?',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: toggleScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6347),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(showLogin ? 'Register' : 'Login'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

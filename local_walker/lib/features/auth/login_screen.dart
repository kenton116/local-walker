import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/auth/auth_service.dart';
import '../../services/user_service.dart';
import '../home/home_screen.dart';
import 'user_info_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _userService = UserService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final credential = await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      final user = credential.user;
      if (user == null) return;

      final userService = UserService();
      final userData = await userService.getUser(user.uid);

      if (userData == null) {
        throw Exception('ユーザー情報がFirestoreに存在しません');
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            email: userData['email'],
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

Future<void> _signUp() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    final credential = await _authService.signUpWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    final user = credential.user;
    if (!mounted) return;
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UserInfoScreen(
            uid: user.uid,
            email: user.email!,
          ),
        ),
      );
    }
  } on FirebaseAuthException catch (e) {
    setState(() => _error = e.message);
  } finally {
    setState(() => _isLoading = false);
  }
}

  // Future<void> _googleLogin() async {
  //   try {
  //     await _authService.signInWithGoogle();
  //   } catch (e) {
  //     setState(() => _error = e.toString());
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else ...[
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
              ElevatedButton(
                onPressed: _signUp,
                child: const Text('Sign Up'),
              ),
              // ElevatedButton(
              //   onPressed: _googleLogin,
              //   child: const Text('Sign in with Google'),
              // ),
            ]
          ],
        ),
      ),
    );
  }
}

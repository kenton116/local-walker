import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import '../../services/user_service.dart';

class AuthController {
  final AuthService _authService;
  final UserService _userService;

  AuthController(this._authService, this._userService);

  Future<void> signUp(String email, String password) async {
    final UserCredential credential =
        await _authService.signUpWithEmail(email, password);

    final user = credential.user;
    if (user == null) return;

    await _userService.createUserIfNotExists(
      uid: user.uid,
      email: user.email!,
    );
  }

  Future<void> signIn(String email, String password) {
    return _authService.signInWithEmail(email, password);
  }

  Stream<User?> get authStateChanges =>
      _authService.authStateChanges;

  Future<void> signOut() {
    return _authService.signOut();
  }
}

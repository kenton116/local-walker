import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUpWithEmail(
    String email,
    String password,
  ) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithEmail(
    String email,
    String password,
  ) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Future<UserCredential> signInWithGoogle() async {
  //   final GoogleSignInAccount googleUser =
  //       await GoogleSignIn.instance.authenticate();

  //   final googleAuth = googleUser.authentication;
  //   final authResponse = await googleUser.authorizationClient.authorizeScopes([
  //     'email',
  //     'profile',
  //     'openid',
  //   ]);
  //   final credential = GoogleAuthProvider.credential(
  //     accessToken: authResponse.accessToken,
  //     idToken: googleAuth.idToken,
  //   );

  //   return _auth.signInWithCredential(credential);
  // }

  Future<void> signOut() {
    return _auth.signOut();
  }
}

import 'package:firebase_auth/firebase_auth.dart';

/// Wrapper for [FirebaseAuthException] when signing in with email and
/// password.
class SignInWithEmailAndPasswordException implements Exception {
  final FirebaseAuthException originalException;
  late final String message;

  SignInWithEmailAndPasswordException(this.originalException) {
    switch(originalException.code) {
      case "invalid-email":
        message = "Please provide a valid email.";
        break;
      case "user-not-found":
      case "wrong-password":
        message = "The email and/or password you entered is incorrect. "
            "If you used Google to sign in, use that.";
        break;
      default:
        message = "An unknown error occurred. Please contact the developer and try again.";
        print(message);
    }
  }
}
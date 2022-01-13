import 'package:firebase_auth/firebase_auth.dart';

/// Wrapper for [FirebaseAuthException] when signing in with different providers
/// (e.g. Google).
class SignInWithCredentialException implements Exception {
  final FirebaseAuthException originalException;
  late final String message;

  SignInWithCredentialException(this.originalException) {
    switch(originalException.code) {
      case "account-exists-with-different-credential":
        message = "An account exists under different credientials. "
            "Please sign in regularly.";
        break;
      case "invalid-email":
        message = "Please provide a valid email.";
        break;
      case "user-not-found":
      case "wrong-password":
        message = "The email and/or password you entered is incorrect.";
        break;
      default:
        message = "An unknown error occurred. Please contact the developer and try again.";
        print(message);
    }
  }
}
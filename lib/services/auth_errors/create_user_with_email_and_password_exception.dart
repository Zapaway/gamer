import 'package:firebase_auth/firebase_auth.dart';

/// Wrapper for [FirebaseAuthException] when creating a user with email and
/// password.
class CreateUserWithEmailAndPasswordException implements Exception {
  final FirebaseAuthException originalException;
  late final String message;

  CreateUserWithEmailAndPasswordException(this.originalException) {
    switch(originalException.code) {
      case "email-already-in-use":
        message = "This email is already registered. Please use a new one.";
        break;
      case "invalid-email":
        message = "Please provide a valid email.";
        break;
      default:
        message = "An unknown error occurred. Please contact the developer and try again.";
        print(message);
    }
  }
}
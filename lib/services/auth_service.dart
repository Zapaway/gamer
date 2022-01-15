import 'package:firebase_auth/firebase_auth.dart';
import 'package:gamer/models/user_model.dart';
import 'package:gamer/services/auth_errors/create_user_with_email_and_password_exception.dart';
import 'package:gamer/services/auth_errors/sign_in_with_credential_exception.dart';
import 'package:gamer/services/auth_errors/sign_in_with_email_and_password_exception.dart';
import 'package:gamer/services/database_service.dart';
import 'package:gamer/shared/random_number_string.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final auth = FirebaseAuth.instance;
  static final googleSignIn = GoogleSignIn();

  Stream<UserModel?> get onAuthStateChanged =>
    auth.authStateChanges().map(_createUserModelFromFirebaseUser);

  UserModel? _createUserModelFromFirebaseUser(User? user) {
    return user != null ? UserModel(uid: user.uid) : null;
  }

  // Auth methods
  Future<UserModel?> registerWithEmailAndPwd(
    String email,
    String pwd,
    String username,
  ) async {
    try {
      final creds = await auth.createUserWithEmailAndPassword(
          email: email,
          password: pwd
      );

      final user = _createUserModelFromFirebaseUser(creds.user);
      if (user != null) {
        await DatabaseService(userModel: user).setUserData(
          UserDataModel(
            username: username,
            level: 0,
          )..user = UserModel(uid: user.uid)
        );
      }
      return user;
    }
    on FirebaseAuthException catch (e) {
      throw CreateUserWithEmailAndPasswordException(e);
    }
  }

  Future<UserModel?> signInWithEmailAndPwd(String email, String pwd) async {
    try {
      final creds = await auth.signInWithEmailAndPassword(
        email: email, password: pwd
      );

      return _createUserModelFromFirebaseUser(creds.user);
    }
    on FirebaseAuthException catch (e) {
      throw SignInWithEmailAndPasswordException(e);
    }
  }

  /* Disabled due to "NetworkRequest - No app check token requested"
  error that will crash the app. */
  // /// Uses Google provider to create/sign in. It will automatically
  // /// handles the user if they are new or existing.
  // Future<UserModel?> authUsingGoogle() async {
  //   try {
  //     final googleAccount = await googleSignIn.signIn();
  //     if (googleAccount == null) return null;
  //
  //     final googleAccountAuth = await googleAccount.authentication;
  //     final AuthCredential authCreds = GoogleAuthProvider.credential(
  //       accessToken: googleAccountAuth.accessToken,
  //       idToken: googleAccountAuth.idToken
  //     );
  //
  //     final userCreds = await auth.signInWithCredential(authCreds);
  //     final userModel = _createUserModelFromFirebaseUser(userCreds.user);
  //
  //     // if this is a new user
  //     if ((userCreds.additionalUserInfo?.isNewUser ?? false)
  //         && userModel != null) {
  //       // since userModel is not null, user is not null
  //       final user = userCreds.user!;
  //
  //       // get a username that is unique
  //       String username = user.email!.split("@")[0];
  //       if (username.length > 30) {
  //         username = username.substring(0, 29);
  //       }
  //       while ( // if the username is taken, generate a random one
  //         (await DatabaseService.userDataCollection
  //           .where("username", isEqualTo: username).get()).docs.isNotEmpty
  //       ) {
  //         username = "user" + generateRandomNumericalString(26);
  //       }
  //
  //       await DatabaseService(userModel: userModel).setUserData(
  //         UserDataModel(
  //           username: username,
  //           level: 0,
  //         )..user = UserModel(uid: user.uid),
  //         googlePfpUrl: user.photoURL
  //       );
  //     }
  //
  //     return userModel;
  //   }
  //   on FirebaseAuthException catch (e) {
  //     throw SignInWithCredentialException(e);
  //   }
  // }

  Future<void> signOut() async {
    await googleSignIn.signOut();
    await auth.signOut();
  }
}
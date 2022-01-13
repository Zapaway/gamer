import 'package:flutter/material.dart';
import 'package:gamer/components/forms/basic_auth_form.dart';
import 'package:gamer/components/forms/form_error_dialog.dart';
import 'package:gamer/services/auth_errors/sign_in_with_credential_exception.dart';
import 'package:gamer/services/auth_errors/sign_in_with_email_and_password_exception.dart';
import 'package:gamer/services/auth_service.dart';
import 'package:gamer/shared/auth_regex.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  String _email = "";
  String _pwd = "";

  @override
  Widget build(BuildContext context) {
    return AppBasicAuthForm(
      header: "Welcome back!",
      desc: "Sign into the experience",
      eapValidatorButtonText: "Sign in",
      googleValidatorButtonText: "Sign in with Google",

      formKey: _formKey,
      emailValidator: (x) {
        x ??= "";
        return validateEmailWithRegex(x) ?? (){
          _email = x!;
          return;
        }();
      },
      pwdValidator: (x) {
        if (x == null || x.isEmpty) {
          return "Enter a password";
        }
        _pwd = x;
      },
      submitWithEaPValidator: () async {
        if (_formKey.currentState?.validate() ?? false) {
          try {
            final user = await AuthService().signInWithEmailAndPwd(
              _email, _pwd
            );
            if (user == null) throw Error();

            Navigator.pop(context, true);
          }
          on SignInWithEmailAndPasswordException catch (e) {
            showDialog(context: context, builder: (_) {
              return FormErrorDialog(
                title: "Sign In Error",
                errorMessage: e.message
              );
            });
          }
        }
      },
    );
  }
}

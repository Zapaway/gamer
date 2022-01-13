import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamer/components/forms/basic_auth_form.dart';
import 'package:gamer/components/forms/form_error_dialog.dart';
import 'package:gamer/components/forms/text_form_field.dart';
import 'package:gamer/services/auth_errors/create_user_with_email_and_password_exception.dart';
import 'package:gamer/services/auth_service.dart';
import 'package:gamer/services/database_service.dart';
import 'package:gamer/shared/auth_regex.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, void> _takenUsernames = {};  // allows faster access time
  String _username = "";
  String _email = "";
  String _pwd = "";

  // checks if username is unique
  bool _isUsernameUnique = true;
  Future<bool> _checkUsernameUnique() async {
    if (_takenUsernames.containsKey(_username)) return false;

    final res = await DatabaseService.userDataCollection.where(
      "username", isEqualTo: _username
    ).get();

    return res.docs.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return AppBasicAuthForm(
      header: "Hello!",
      desc: "Create an account to get started",
      eapValidatorButtonText: "Create account",
      googleValidatorButtonText: "Create with Google account",
      passwordHelperTextEnabled: true,
      textFields: [
        AppTextFormField(
          hintText: "Username",
          onChanged: (x) => _username = x ?? "",
          useSpecialAutovalidationMode: true,
          validator: (text) {
            text ??= "";

            if (text.length <= 2) {
              return "Must be at least 3 characters long";
            }
            else if (_takenUsernames.containsKey(text)) {
              return "Username already taken";
            }
            else if (!_isUsernameUnique) {
              _takenUsernames[text] = null;
              _isUsernameUnique = true;
              return "Username already taken";
            }

            _username = text;  // ensure that username has the correct value
          },
          formatters: [
            FilteringTextInputFormatter.allow(RegExp(
              "[(0-9a-zA-Z_\\.)]"
            )),
            LengthLimitingTextInputFormatter(30),
          ],
        )
      ],

      formKey: _formKey,
      emailValidator: (x) {
        x ??= "";
        return validateEmailWithRegex(x) ?? (){
          _email = x!;
          return;
        }();
      },
      pwdValidator: (x) {
        final List<String> missingParts = [];
        x ??= "";

        if (!RegExp(
          "[~`!@#\$%^&*()_\\-\\+=\\{\\[\\}\\]\\|\\:;\"'<,\\>\\.\\?/]+"
        ).hasMatch(x)) {
          missingParts.add("At least one special char");
        }
        if (!RegExp(
          "[A-Z]+"
        ).hasMatch(x)) {
          missingParts.add("At least one uppercase");
        }
        if (!RegExp(
          "[0-9]+"
        ).hasMatch(x)) {
          missingParts.add("At least one number");
        }
        if (x.length < 6) {
          missingParts.add("At least 6 characters");
        }
        if (missingParts.isNotEmpty) {
          return "Must contain the following\n• ${missingParts.join("\n• ")}";
        }

        _pwd = x;
      },
      asyncValidateBeforeSaving: () async {
        _isUsernameUnique = await _checkUsernameUnique();
      },
      submitWithEaPValidator: () async {
        if (_formKey.currentState?.validate() ?? false) {
          try {
            final user = await AuthService().registerWithEmailAndPwd(
              _email, _pwd, _username
            );
            if (user == null) throw Error();

            Navigator.pop(context, true);
          }
          on CreateUserWithEmailAndPasswordException catch (e) {
            showDialog(context: context, builder: (_) {
              return FormErrorDialog(
                title: "Registration Error",
                errorMessage: e.message
              );
            });
          }
        }
      },
    );
  }
}

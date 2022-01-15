import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer/components/forms/submit_form_button.dart';
import 'package:gamer/components/wrappers/keyboard_dismissible.dart';
import 'package:gamer/components/forms/text_form_field.dart';
import 'package:gamer/services/auth_errors/sign_in_with_credential_exception.dart';
import 'package:gamer/services/auth_service.dart';
import 'package:gamer/shared/consts.dart';

import 'form_error_dialog.dart';

/// Contains basic options for auth (registration or login).
/// - Email field
/// - Password field
/// - Submit button with email/pwd auth method
/// - Submit button with Google account auth method
///
/// You will have to pass in a form key and validators for each component.
/// To add more text fields before the email field, use [textFields]. Use
/// validators to retrieve values.
///
/// **NOTE: [submitWithEaPValidator] will automatically save the form.**
class AppBasicAuthForm extends StatefulWidget {
  final GlobalKey<FormState> _formKey;
  final String? Function(String?) emailValidator;
  final String? Function(String?) pwdValidator;
  final Future<void> Function()?
      asyncValidateBeforeSaving; // any validation needed before saving
  final VoidCallback submitWithEaPValidator; // email and pwd validator

  final String header;
  final String desc;
  final String eapValidatorButtonText;
  final String googleValidatorButtonText;
  final bool passwordHelperTextEnabled;
  final List<Widget>? textFields;

  const AppBasicAuthForm({
    Key? key,
    required GlobalKey<FormState> formKey,
    required this.emailValidator,
    required this.pwdValidator,
    this.asyncValidateBeforeSaving,
    required this.submitWithEaPValidator,
    this.header = "",
    this.desc = "",
    this.eapValidatorButtonText = "",
    this.googleValidatorButtonText = "",
    this.passwordHelperTextEnabled = false,
    this.textFields,
  })  : _formKey = formKey,
        super(key: key);

  @override
  State<AppBasicAuthForm> createState() => _AppBasicAuthFormState();
}

class _AppBasicAuthFormState extends State<AppBasicAuthForm> {
  @override
  Widget build(BuildContext context) {
    return KeyboardDismissible(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            /// back button
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                iconSize: 50,
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 15,
                  top: 11,
                  right: 15,
                ),
                // padding: const EdgeInsets.fromLTRB(15, 11, 15, 0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// title and subtitle
                      Text(
                        widget.header,
                        style: const TextStyle(fontSize: 45),
                      ),
                      Text(
                        widget.desc,
                        style: const TextStyle(fontSize: 22),
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      /// GUI for signing up with email w/ pwd
                      Form(
                        key: widget._formKey,
                        child: Column(
                          children: [
                            ...?widget.textFields,
                            if (widget.textFields != null)
                              const SizedBox(
                                height: 15,
                              ),
                            AppTextFormField(
                              hintText: "Email",
                              validator: widget.emailValidator,
                              useSpecialAutovalidationMode: true,
                              formatters: [
                                FilteringTextInputFormatter.deny(RegExp(r"\s")),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            AppTextFormField(
                              hintText: "Password",
                              validator: widget.pwdValidator,
                              useSpecialAutovalidationMode: true,
                              obscureText: true,
                              helperText: widget.passwordHelperTextEnabled
                                  ? "Must contain the following\n"
                                      "• At least one special character\n"
                                      "• At least one uppercase character\n"
                                      "• At least one number\n"
                                      "• Contain 6 characters or more"
                                  : null,
                              counterLabel:
                                  widget.passwordHelperTextEnabled ? "" : null,
                              formatters: [
                                FilteringTextInputFormatter.allow(RegExp(
                                    "[0-9a-zA-Z~`!@#\$%^&*()_\\-\\+=\\{\\[\\}\\]\\|\\:;\"'<,\\>\\.\\?/]")),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      AppSubmitFormButton(
                        text: widget.eapValidatorButtonText,
                        onPressed: () {
                          () async {
                            await widget.asyncValidateBeforeSaving?.call();
                            widget._formKey.currentState?.save();
                            widget.submitWithEaPValidator();
                          }();
                        },
                      ),

                      // Container(
                      //   margin: const EdgeInsets.symmetric(vertical: 15),
                      //   child: const Center(
                      //     child: Text(
                      //       "OR",
                      //       style: TextStyle(
                      //         fontSize: 45,
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      // /// GUI for signing up with Google
                      // AppSubmitFormButton(
                      //   text: widget.googleValidatorButtonText,
                      //   color: AppColors.darkBlue,
                      //   icon: const FaIcon(
                      //     FontAwesomeIcons.google,
                      //     color: Colors.white,
                      //   ),
                      //   onPressed: () async {
                      //     try {
                      //       final user = await AuthService().authUsingGoogle();
                      //       if (user == null) return;
                      //
                      //       Navigator.pop(context, true);
                      //     } on SignInWithCredentialException catch (e) {
                      //       showDialog(
                      //           context: context,
                      //           builder: (_) {
                      //             return FormErrorDialog(
                      //                 title: "Sign In With Google Error",
                      //                 errorMessage: e.message);
                      //           });
                      //     }
                      //   },
                      // ),

                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

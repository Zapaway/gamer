/// If result is null, then it passed the email validator regex test.
String? validateEmailWithRegex(String text) {
  final emailRegex = RegExp(r".+@.+\..+");

  if (!emailRegex.hasMatch(text)) {
    return "Email not in correct format";
  }
}
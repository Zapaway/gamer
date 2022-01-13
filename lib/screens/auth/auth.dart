import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gamer/screens/auth/login.dart';
import 'package:gamer/screens/auth/sign_up.dart';
import 'package:gamer/shared/consts.dart';

import '../loading.dart';
/// TODO Put loading screen somewhere else.

/// Landing page for a user to sign up or login if they hadn't already
/// done so.
class Auth extends StatefulWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    /// If return type is [false] or [null], then it was cancelled.
    /// Otherwise, the user has authenticated.
    Future<bool?> showScrollableModalBottomSheet(Widget widget) async {
      return await showModalBottomSheet<bool>(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(18),
          ),
        ),
        barrierColor: const Color.fromARGB(50, 13, 43, 86),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: widget,
          );
        }
      );
    }

    // TODO fix Loading()
    return loading ? const Loading() : Scaffold(
      body: Container(
        decoration: AppColors.backgroundGradient,
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 21.5),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset("assets/title.svg",),
                  const Text(
                    "The place for any gamer to review games and find good ones",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w300,
                    ),
                  ),

                  const SizedBox(height: 135,),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: SizedBox(
                      width: 271,
                      height: 78,
                      child: TextButton(
                        child: const Text("Sign Up"),
                        style: TextButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w300,
                          ),
                          primary: AppColors.lightBlue,
                          backgroundColor: AppColors.darkBlue,
                        ),

                        onPressed: () async {
                          showScrollableModalBottomSheet(const SignUp())
                          .then((value) {
                            setState(() => loading = value ?? false);
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 25,),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: SizedBox(
                      width: 271,
                      height: 78,
                      child: TextButton(
                        child: const Text("Login"),
                        style: TextButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w300,
                          ),
                          primary: AppColors.darkBlue,
                          backgroundColor: AppColors.lightBlue,
                        ),

                        onPressed: () async {
                          showScrollableModalBottomSheet(const Login())
                          .then((value) {
                            setState(() => loading = value ?? false);
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

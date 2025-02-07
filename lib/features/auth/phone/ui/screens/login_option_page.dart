import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hookup4u2/common/providers/theme_provider.dart';
import 'package:hookup4u2/common/routes/route_name.dart';
import 'package:hookup4u2/features/auth/apple_bloc/apple_login_bloc.dart';
import 'package:hookup4u2/features/auth/google_login/google_login_bloc.dart';
import 'package:hookup4u2/features/auth/login/screens/login_screen.dart';
import 'package:hookup4u2/features/auth/phone/screens/phone_number_screen.dart';
import 'package:hookup4u2/features/auth/phone/ui/widgets/facebook_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:hookup4u2/features/home/ui/tab/tabbar.dart';
import 'package:hookup4u2/common/data/repo/phone_auth_repo.dart';

import '../../../../../common/constants/colors.dart';
import '../../../../../common/providers/user_provider.dart';
import '../../../../../common/utlis/app_exit.dart';
import '../../../../../common/widets/custom_snackbar.dart';
import '../../../auth_status/bloc/registration/bloc/registration_bloc.dart';
import '../../../facebook_login/facebook_login_bloc.dart';
import '../../../facebook_login/facebook_login_events.dart';
import '../../../facebook_login/facebook_login_states.dart';
import '../widgets/privacy_policy.dart';
import '../widgets/wave_clipper.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' as i;

class LoginOption extends StatefulWidget {
  const LoginOption({super.key});

  @override
  State<LoginOption> createState() => _LoginOptionState();
}

class _LoginOptionState extends State<LoginOption> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return PopScope(
      canPop: false,
onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) {
          return;
        }
        final bool shouldPop = await onWillPop(context);
        if (shouldPop) {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        body: MultiBlocListener(
          listeners: [
            BlocListener<AppleLoginBloc, AppleLoginState>(
              listener: (context, state) {
                if (state is AppleLoginLoading) {
                  CustomSnackbar.showSnackBarSimple(
                      'Please wait. Loading..'.tr().toString(), context);
                }
                if (state is AppleLoginSuccess) {
                  state.user?.getIdToken().then((value) async {
                    final userProvider = Provider.of<UserProvider>(context, listen: false);
                    await userProvider.listenCurrentUserdetails();
                    Navigator.pushReplacementNamed(context, RouteName.tabScreen);
                  });
                }
              },
            ),
            BlocListener<FacebookLoginBloc, FacebookLoginStates>(
              listener: (context, state) {
                if (state is FacebookLoginLoading) {
                  CustomSnackbar.showSnackBarSimple(
                      'Please wait. Loading..'.tr().toString(), context);
                }
                if (state is FacebookLoginFailed) {
                  CustomSnackbar.showSnackBarSimple(state.message, context);
                }
                if (state is FacebookLoginSuccess) {
                  state.user?.getIdToken().then((value) async {
                    final userProvider = Provider.of<UserProvider>(context, listen: false);
                    await userProvider.listenCurrentUserdetails();
                    Navigator.pushReplacementNamed(context, RouteName.tabScreen);
                  });
                }
              },
            ),
            BlocListener<GoogleLoginBloc, GoogleLoginState>(
              listener: (context, state) {
                if (state is GoogleLoginLoading) {
                  CustomSnackbar.showSnackBarSimple(
                      'Connexion en cours...'.tr().toString(), context);
                }
                if (state is GoogleLoginFailed) {
                  CustomSnackbar.showSnackBarSimple(state.message, context);
                }
                if (state is GoogleLoginSuccess) {
                  state.user?.getIdToken().then((value) async {
                    final userProvider = Provider.of<UserProvider>(context, listen: false);
                    await userProvider.listenCurrentUserdetails();
                    Navigator.pushReplacementNamed(context, RouteName.tabScreen);
                  });
                }
              },
            ),
          ],
          child: Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50)),
                color: Theme.of(context).primaryColor),
            child: ListView(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    ClipPath(
                      clipper: WaveClipper2(),
                      child: Container(
                        width: double.infinity,
                        height: 280,
                        decoration: BoxDecoration(
                            gradient: themeProvider.isDarkMode
                                ? LinearGradient(colors: [
                                    darkPrimaryColor,
                                    primaryColor.withOpacity(0.6)
                                  ])
                                : LinearGradient(colors: [
                                    darkPrimaryColor,
                                    primaryColor.withOpacity(0.15)
                                  ])),
                        child: const Column(),
                      ),
                    ),
                    ClipPath(
                      clipper: WaveClipper3(),
                      child: Container(
                        width: double.infinity,
                        height: 280,
                        decoration: BoxDecoration(
                            gradient: themeProvider.isDarkMode
                                ? LinearGradient(colors: [
                                    darkPrimaryColor,
                                    primaryColor.withOpacity(0.5)
                                  ])
                                : LinearGradient(colors: [
                                    darkPrimaryColor,
                                    primaryColor.withOpacity(0.2)
                                  ])),
                        child: const Column(),
                      ),
                    ),
                    ClipPath(
                      clipper: WaveClipper1(),
                      child: Container(
                        width: double.infinity,
                        height: 280,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [primaryColor, primaryColor])),
                        child: Column(
                          children: <Widget>[
                            const SizedBox(
                              height: 15,
                            ),
                            Image.asset(
                              "asset/soloparent.png",
                              height: 150,
                              width: 150,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Column(children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .02,
                  ),
                  Text(
                    "By tapping 'Log in', you agree with our \n Terms.Learn how we process your data in \n our Privacy Policy and Cookies Policy."
                        .tr()
                        .toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black54,
                        fontSize: 15),
                  ),
                  const SizedBox(height: 24),

                  // Bouton Email
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .85,
                    height: MediaQuery.of(context).size.height * .065,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.email, color: Colors.black54),
                          const SizedBox(width: 12),
                          Text(
                            'Continue with Email'.tr().toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bouton Téléphone
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .85,
                    height: MediaQuery.of(context).size.height * .065,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PhoneNumberScreen(isLogin: true),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.phone_android, color: Colors.black54),
                          const SizedBox(width: 12),
                          Text(
                            'Continue with Phone'.tr().toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Autres boutons existants (Apple, Facebook, Google)
                  !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * .065,
                          width: MediaQuery.of(context).size.width * .85,
                          child: i.SignInWithAppleButton(
                            onPressed: () {
                              context.read<AppleLoginBloc>().add(AppleLoginRequest());
                            },
                          ),
                        )
                      : const SizedBox.shrink(),
                  !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * .02,
                        )
                      : const SizedBox.shrink(),
                  FaceBookButton(onTap: () async {
                    context
                        .read<FacebookLoginBloc>()
                        .add(FacebookLoginRequest());
                  }),
                  // Bouton Google
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * .065,
                      width: MediaQuery.of(context).size.width * .75,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                         /* Image.asset(
                            'asset/google.png',
                            height: 24,
                          ),*/
                          const SizedBox(width: 10),
                          Text(
                            "Se connecter avec Google".tr().toString(),
                              style: TextStyle(
                                  color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {
                      context.read<GoogleLoginBloc>().add(GoogleLoginRequest());
                    },
                  ),
                  const SizedBox(height: 10),
                  // Bouton Inscription
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, RouteName.onboardingNameScreen);
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Vous n'avez pas de compte ? ".tr().toString(),
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                        children: [
                          TextSpan(
                            text: "S'inscrire".tr().toString(),
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Suppression du bouton visiteur
                  const PrivacyPolicy(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .03,
                  ),
                ]),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Trouble logging in?".tr().toString(),
                        style: TextStyle(
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> requestSmsPermission() async {
  final status = await Permission.sms.request();

  if (status.isGranted) {
    // Permission has been granted, you can now read SMS
    // Your code to read SMS goes here
  } else {
    // Permission denied

    await Permission.sms.request();
    // Handle permission denial gracefully
  }
}

// Future<void> launchURL(String url) async {
//   if (!await launchUrl(
//     Uri.parse(url),
//   )) {
//     throw Exception('Could not launch $url');
//   }
// }

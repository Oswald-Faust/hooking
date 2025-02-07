import 'package:flutter/material.dart';
import 'package:hookup4u2/common/providers/user_provider.dart';
import 'package:hookup4u2/common/routes/route_name.dart';
import 'package:hookup4u2/common/utlis/large_image.dart';
import 'package:hookup4u2/features/auth/phone/ui/screens/phone_number.dart';
import 'package:hookup4u2/features/auth/phone/ui/screens/update_phonenumber.dart';
import 'package:hookup4u2/features/auth/onboarding/screens/onboarding_name_screen.dart';

import 'package:hookup4u2/features/chat/ui/screens/chat_page.dart';
import 'package:hookup4u2/features/explore/explore_map.dart';
import 'package:hookup4u2/features/explore/premium_map.dart';
import 'package:hookup4u2/features/match/ui/screen/match_page.dart';
import 'package:hookup4u2/features/match/ui/screen/match_details_screen.dart';
import 'package:hookup4u2/features/home/ui/tab/tabbar.dart';
import 'package:hookup4u2/features/user/ui/screens/edit_user_profile.dart';
import 'package:hookup4u2/features/user/ui/screens/show_gender.dart';
import 'package:hookup4u2/features/user/ui/screens/update_user_location.dart';
import 'package:hookup4u2/features/user/ui/screens/user_location.dart';
import 'package:hookup4u2/features/user/ui/screens/user_profile.dart';
import 'package:hookup4u2/features/user/ui/screens/user_profile_pic_set.dart';
import 'package:hookup4u2/features/user/ui/screens/user_search_location.dart';
import 'package:hookup4u2/features/user/ui/screens/user_sexual_details.dart';
import 'package:hookup4u2/features/user/ui/screens/user_university.dart';
import 'package:hookup4u2/models/user_model.dart';
import 'package:provider/provider.dart';
import '../../features/home/ui/screens/user_filter/settings.dart';
import '../../features/home/ui/screens/welcome.dart';
import 'package:hookup4u2/features/user/ui/screens/user_dob.dart';
import 'package:hookup4u2/features/user/ui/screens/user_gender.dart';
import 'package:hookup4u2/features/user/ui/screens/user_name.dart';

import '../../features/auth/phone/ui/screens/login_option_page.dart';
import '../../features/auth/phone/ui/screens/otp_page.dart';
import '../../features/home/ui/screens/splash.dart';
import '../../features/auth/phone/ui/screens/register_screen.dart';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AppRouter {
  static bool _isAuthRoute(String routeName) {
    final isAuth = routeName == RouteName.splashScreen ||
           routeName == RouteName.loginScreen ||
           routeName == RouteName.registerScreen ||
           routeName == RouteName.onboardingNameScreen ||
           routeName == RouteName.otpScreen;
    log('🛣️ Checking if route $routeName is auth route: $isAuth');
    return isAuth;
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    log('🚦 Generating route for: ${settings.name}');
    
    // Permettre l'accès aux routes d'authentification sans vérification
    if (_isAuthRoute(settings.name ?? '')) {
      log('🔓 Allowing access to auth route: ${settings.name}');
      return MaterialPageRoute(
        builder: (context) => allRoutes[settings.name]!(context),
        settings: settings,
      );
    }
    
    // Vérifier si l'utilisateur est connecté
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null && !_isAuthRoute(settings.name ?? '')) {
      log('🚫 No authenticated user, redirecting to login');
      return MaterialPageRoute(
        builder: (context) => allRoutes[RouteName.loginScreen]!(context),
        settings: settings,
      );
    }

    // Si la route existe, la retourner avec ses arguments
    if (allRoutes.containsKey(settings.name)) {
      log('✅ Proceeding to route: ${settings.name}');
      return MaterialPageRoute(
        builder: (context) => allRoutes[settings.name]!(context),
        settings: settings,
      );
    }

    // Route par défaut si la route n'existe pas
    return MaterialPageRoute(
      builder: (context) => allRoutes[RouteName.splashScreen]!(context),
      settings: settings,
    );
  }

  // register here for routes
  static final Map<String, Widget Function(BuildContext)> allRoutes = {
    RouteName.splashScreen: (context) => const Splash(),
    RouteName.loginScreen: (context) => const LoginOption(),
    RouteName.registerScreen: (context) => const RegisterScreen(),
    RouteName.onboardingNameScreen: (context) => const OnboardingNameScreen(),
    RouteName.tabScreen: (context) => const Tabbar("active", false),
    RouteName.profileScreen: (context) => ProfilePage(
          isPuchased:
              (ModalRoute.of(context)!.settings.arguments as Map)['isPuchased'],
          items: (ModalRoute.of(context)!.settings.arguments as Map)['items'],
          purchases:
              (ModalRoute.of(context)!.settings.arguments as Map)['purchases'],
        ),
    RouteName.phoneNumberScreen: (context) => PhoneNumber(
          updatePhoneNumber: false,
        ),
    RouteName.searchLocationpage: (context) => const SearchLocation(),
    RouteName.updateLocationScreen: (context) => UpdateLocation(
        selectedLocation: ModalRoute.of(context)!.settings.arguments
            as Map<dynamic, dynamic>),
    RouteName.chatPageScreen: (context) => ChatPage(
        sender: (ModalRoute.of(context)!.settings.arguments as Map)['sender'],
        chatId: (ModalRoute.of(context)!.settings.arguments as Map)['chatID']
            .toString(),
        second: (ModalRoute.of(context)!.settings.arguments as Map)['second']),
    RouteName.editProfileScreen: (context) =>
        EditProfile(Provider.of<UserProvider>(context).currentUser!),
    RouteName.largeImageScreen: (context) => LargeImage(
        largeImage: ModalRoute.of(context)!.settings.arguments as String),
    RouteName.updatePhoneScreen: (context) =>
        UpdateNumber(ModalRoute.of(context)!.settings.arguments as UserModel),
    RouteName.genderScreen: (context) => const Gender(),
    RouteName.settingPage: (context) => SettingPage(
          currentUser: (ModalRoute.of(context)!.settings.arguments
              as Map)['currentUser'] as UserModel,
          isPurchased: (ModalRoute.of(context)!.settings.arguments
              as Map)['isPurchased'],
          items: (ModalRoute.of(context)!.settings.arguments as Map)['items'],
        ),
    RouteName.showGenderScreen: (context) => const ShowGender(),
    RouteName.matchPage: (context) => const MatchScreen(),
    RouteName.sexualorientationScreen: (context) => const SexualOrientation(),
    RouteName.universityScreen: (context) => const UniversityPage(),
    RouteName.profilePicSetScreen: (context) => const UserProfilePic(),
    RouteName.allowLocationScreen: (context) => const AllowLocation(),
    RouteName.otpScreen: (context) => OtpPage(
        codeController: (ModalRoute.of(context)!.settings.arguments
                as Map)['codeController']
            .toString(),
        smsVerificationCode: (ModalRoute.of(context)!.settings.arguments
                as Map)['smsVerificationCode']
            .toString(),
        phoneNumber:
            (ModalRoute.of(context)!.settings.arguments as Map)['phoneNumber']
                .toString(),
        updatePhoneNumber: (ModalRoute.of(context)!.settings.arguments
            as Map)['updatenumber']),
    RouteName.welcomeScreen: (context) => const Welcome(),
    RouteName.userDobScreen: (context) => UserDOB(
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>),
    RouteName.userNameScreen: (context) => const UserName(),
    RouteName.userGenderScreen: (context) => const Gender(),
    RouteName.userSexualDetailsScreen: (context) => const SexualOrientation(),
    RouteName.userProfilePicScreen: (context) => const UserProfilePic(),
    RouteName.userLocationScreen: (context) => const AllowLocation(),
    RouteName.exploreScreen: (context) => ExploreMapWidget(
      currentUser: Provider.of<UserProvider>(context).currentUser!,
      isPuchased: (ModalRoute.of(context)!.settings.arguments as Map)['isPurchased'] ?? false,
    ),
    RouteName.exploreMapScreen: (context) => ExploreMapWidget(
      currentUser: Provider.of<UserProvider>(context).currentUser!,
      isPuchased: (ModalRoute.of(context)!.settings.arguments as Map)['isPurchased'] ?? false,
    ),
   /* RouteName.explorePremiumScreen: (context) => PremiumMap(
      currentUser: Provider.of<UserProvider>(context).currentUser!,
    ),*/
    RouteName.matchScreen: (context) => const MatchScreen(),
    RouteName.matchDetailsScreen: (context) => MatchDetailsScreen(
      currentUser: Provider.of<UserProvider>(context).currentUser!,
      matchedUser: (ModalRoute.of(context)!.settings.arguments as Map)['matchedUser'],
    ),
    RouteName.matchChatScreen: (context) => ChatPage(
      sender: Provider.of<UserProvider>(context).currentUser!,
      second: (ModalRoute.of(context)!.settings.arguments as Map)['matchedUser'],
      chatId: (ModalRoute.of(context)!.settings.arguments as Map)['chatId'],
    ),
  };
}

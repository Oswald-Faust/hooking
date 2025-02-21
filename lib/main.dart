// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hookup4u2/common/providers/user_provider.dart';
import 'package:hookup4u2/common/routes/route_name.dart';
import 'package:hookup4u2/common/routes/router.dart';
import 'package:hookup4u2/features/auth/apple_bloc/apple_login_bloc.dart';
import 'package:hookup4u2/features/auth/facebook_login/facebook_login_bloc.dart';
import 'package:hookup4u2/features/auth/google_login/google_login_bloc.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_bloc.dart';
import 'package:hookup4u2/features/auth/services/auth_service.dart';
import 'package:hookup4u2/features/auth/services/onboarding_service.dart';
import 'package:hookup4u2/features/explore/bloc/explore_bloc.dart';
import 'package:hookup4u2/features/home/bloc/app_state_bloc.dart';
import 'package:hookup4u2/features/home/bloc/searchuser_bloc.dart';
import 'package:hookup4u2/features/home/bloc/swipebloc_bloc.dart';
import 'package:hookup4u2/features/auth/auth_status/bloc/registration/bloc/registration_bloc.dart';
import 'package:hookup4u2/common/data/repo/phone_auth_repo.dart';
import 'package:hookup4u2/services/initialization_service.dart';
import 'package:hookup4u2/services/notification_service.dart';
import 'package:hookup4u2/services/purchase_service.dart';
import 'package:provider/provider.dart';
import 'common/constants/theme.dart';
import 'common/providers/theme_provider.dart';
import 'firebase_options.dart';
import 'package:hookup4u2/features/auth/login/bloc/login_bloc.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final userProvider = UserProvider();

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();

    log('🌟 Starting app initialization');

    // Initialiser Firebase en premier
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    log('🔥 Firebase initialized');

    // Initialiser les services dans l'ordre
    if (!kIsWeb) {
      // await MobileAds.instance.initialize();
      // log('📱 Mobile Ads initialized');
    }

    await NotificationService().initialize();
    log('🔔 Notifications initialized');

    // Initialiser le service d'achat
    try {
      await PurchaseService().initialize();
      log('💰 Purchase service initialized');
    } catch (e) {
      log('⚠️ Error initializing purchase service: $e');
    }

    // Initialiser les services de manière séquentielle avec gestion d'erreur
    try {
      await InitializationService().initialize();
      log('🔧 Services initialized');
    } catch (e) {
      log('⚠️ Error initializing services: $e');
    }

    // Configurer l'orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    runApp(
      EasyLocalization(
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('es', 'ES'),
          Locale('fr', 'FR'),
          Locale('de', 'DE'),
          Locale('ru', 'RU'),
          Locale('hi', 'IN')
        ],
        fallbackLocale: const Locale('en', 'US'),
        saveLocale: true,
        path: 'asset/translation',
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => UserProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => AppStateBloc()),
              BlocProvider(create: (_) => SearchUserBloc()),
              BlocProvider(create: (_) => SwipeBloc()),
              BlocProvider(create: (_) => FacebookLoginBloc()),
              BlocProvider(create: (_) => AppleLoginBloc()),
              BlocProvider(create: (_) => GoogleLoginBloc()),
              BlocProvider(create: (_) => ExploreBloc()),
              BlocProvider(
                  create: (_) => LoginBloc(authService: AuthService())),
              BlocProvider(
                create: (context) => RegistrationBloc(
                  phoneAuthRepository: PhoneAuthRepository(),
                ),
              ),
              BlocProvider(
                create: (_) => OnboardingBloc(
                  onboardingService: OnboardingService(
                    authService: AuthService(),
                  ),
                ),
              ),
            ],
            child: const MyApp(),
          ),
        ),
      ),
    );
  } catch (e) {
    log('🔴 Error during app initialization: $e');
    // Gérer l'erreur de manière appropriée
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      onGenerateRoute: (settings) {
        log('📱 Generating route for: ${settings.name}');
        return AppRouter.onGenerateRoute(settings);
      },
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      initialRoute: RouteName.splashScreen,
    );
  }
}

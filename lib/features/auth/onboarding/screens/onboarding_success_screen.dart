import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hookup4u2/common/constants/colors.dart';
import 'package:hookup4u2/common/routes/route_name.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_bloc.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_state.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:hookup4u2/common/providers/user_provider.dart';

class OnboardingSuccessScreen extends StatefulWidget {
  const OnboardingSuccessScreen({super.key});

  @override
  State<OnboardingSuccessScreen> createState() => _OnboardingSuccessScreenState();
}

class _OnboardingSuccessScreenState extends State<OnboardingSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Démarrer l'animation
    _controller.forward();

    // Afficher le texte après 1 seconde
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showText = true;
        });
      }
    });

    // Rediriger vers la home page après 3 secondes
    Timer(const Duration(seconds: 3), () async {
      if (mounted) {
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            // Forcer la mise à jour du UserProvider
            await Provider.of<UserProvider>(context, listen: false).listenCurrentUserdetails();

            // Rediriger directement vers la tabbar
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteName.tabScreen,
                (route) => false,
                arguments: {
                  'isPurchased': false,
                  'items': const {},
                  'purchases': const {},
                },
              );
            }
          } else {
            debugPrint('No user found during redirection');
          }
        } catch (e) {
          debugPrint('Error during redirection: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: primaryColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
                child: Lottie.asset(
                  'asset/animations/success.json',
                  controller: _controller,
                  fit: BoxFit.contain,
                ),
              ),
              
              const SizedBox(height: 40),
              
              AnimatedOpacity(
                opacity: _showText ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Column(
                  children: [
                    Text(
                      'Profile Created!'.tr().toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Welcome to Hookup4u!'.tr().toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
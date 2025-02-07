import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hookup4u2/common/constants/colors.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_bloc.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_event.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_state.dart';
import 'package:hookup4u2/features/auth/onboarding/screens/onboarding_gender_screen.dart';
import 'package:hookup4u2/features/auth/onboarding/screens/onboarding_passions_screen.dart';

class OnboardingBirthdateScreen extends StatefulWidget {
  const OnboardingBirthdateScreen({super.key});

  @override
  State<OnboardingBirthdateScreen> createState() => _OnboardingBirthdateScreenState();
}

class _OnboardingBirthdateScreenState extends State<OnboardingBirthdateScreen> {
  DateTime? selectedDate;
  final DateTime minDate = DateTime(DateTime.now().year - 100);
  final DateTime maxDate = DateTime(DateTime.now().year - 18);

  bool get isValidAge => selectedDate != null && 
      selectedDate!.isBefore(DateTime.now().subtract(const Duration(days: 18 * 365)));

  void _handleContinue() {
    if (isValidAge && selectedDate != null) {
      // Sauvegarder la date dans le bloc
      context.read<OnboardingBloc>().add(UpdateBirthDate(selectedDate!));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid birth date (18+ years old)'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state.status == OnboardingStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'Une erreur est survenue'.tr()),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state.birthDate != null) {
          // Naviguer vers l'écran suivant uniquement après la sauvegarde réussie
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OnboardingPassionsScreen(),
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec bouton retour
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Titre et sous-titre
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My birthday is'.tr().toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You must be at least 18 years old to use this app'
                          .tr()
                          .toString(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Date Picker
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: DateTime(DateTime.now().year - 25),
                  minimumDate: minDate,
                  maximumDate: maxDate,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      selectedDate = newDate;
                    });
                  },
                ),
              ),

              // Bouton Continuer
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: BlocBuilder<OnboardingBloc, OnboardingState>(
                  builder: (context, state) {
                    return Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isValidAge
                              ? [primaryColor, primaryColor.withOpacity(0.8)]
                              : [Colors.grey[300]!, Colors.grey[400]!],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: ElevatedButton(
                        onPressed: state.status == OnboardingStatus.loading
                            ? null
                            : _handleContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: state.status == OnboardingStatus.loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Continue'.tr().toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hookup4u2/common/constants/colors.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_bloc.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_event.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_state.dart';
import 'package:hookup4u2/features/auth/onboarding/screens/onboarding_passions_screen.dart';
import 'package:hookup4u2/features/auth/onboarding/screens/onboarding_photos_screen.dart';

class OnboardingLookingForScreen extends StatefulWidget {
  const OnboardingLookingForScreen({super.key});

  @override
  State<OnboardingLookingForScreen> createState() => _OnboardingLookingForScreenState();
}

class _OnboardingLookingForScreenState extends State<OnboardingLookingForScreen> {
  final List<String> selectedPreferences = [];

  final List<Map<String, dynamic>> preferences = [
    {'id': 'woman', 'icon': Icons.female, 'label': 'Women'},
    {'id': 'man', 'icon': Icons.male, 'label': 'Men'},
    {'id': 'everyone', 'icon': Icons.people, 'label': 'Everyone'},
  ];

  void _togglePreference(String id) {
    setState(() {
      if (id == 'everyone') {
        if (!selectedPreferences.contains('everyone')) {
          selectedPreferences.clear();
          selectedPreferences.add('everyone');
        }
      } else {
        if (selectedPreferences.contains('everyone')) {
          selectedPreferences.remove('everyone');
        }
        if (selectedPreferences.contains(id)) {
          selectedPreferences.remove(id);
        } else {
          selectedPreferences.add(id);
        }
      }
    });
  }

  void _handleContinue() {
    if (selectedPreferences.isNotEmpty) {
      // Sauvegarder les préférences dans le bloc
      context.read<OnboardingBloc>().add(UpdateLookingFor(selectedPreferences));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select who you want to meet'.tr()),
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
        } else if (state.lookingFor != null && state.lookingFor!.isNotEmpty) {
          // Naviguer vers l'écran suivant uniquement après la sauvegarde réussie
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OnboardingPhotosScreen(),
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
                      'I am interested in'.tr().toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select who you want to meet'
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

              // Options de préférences
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: preferences.length,
                  itemBuilder: (context, index) {
                    final preference = preferences[index];
                    final isSelected = selectedPreferences.contains(preference['id']);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => _togglePreference(preference['id']),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? primaryColor : Colors.grey[300]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                preference['icon'] as IconData,
                                color: isSelected ? primaryColor : Colors.grey[600],
                                size: 28,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                preference['label'].toString().tr(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? primaryColor : Colors.black,
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: primaryColor,
                                  size: 28,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
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
                          colors: selectedPreferences.isNotEmpty
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
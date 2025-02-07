import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hookup4u2/common/constants/colors.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_bloc.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_event.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_state.dart';
import 'package:hookup4u2/features/auth/onboarding/screens/onboarding_photos_screen.dart';
import 'package:hookup4u2/features/auth/onboarding/screens/onboarding_gender_screen.dart';

class OnboardingPassionsScreen extends StatefulWidget {
  const OnboardingPassionsScreen({super.key});

  @override
  State<OnboardingPassionsScreen> createState() => _OnboardingPassionsScreenState();
}

class _OnboardingPassionsScreenState extends State<OnboardingPassionsScreen> {
  final List<String> selectedPassions = [];

  final List<Map<String, dynamic>> passions = [
    {'id': 'photography', 'icon': '📸', 'label': 'Photography'},
    {'id': 'music', 'icon': '🎵', 'label': 'Music'},
    {'id': 'sports', 'icon': '⚽', 'label': 'Sports'},
    {'id': 'cooking', 'icon': '🍳', 'label': 'Cooking'},
    {'id': 'travel', 'icon': '✈️', 'label': 'Travel'},
    {'id': 'art', 'icon': '🎨', 'label': 'Art'},
    {'id': 'reading', 'icon': '📚', 'label': 'Reading'},
    {'id': 'gaming', 'icon': '🎮', 'label': 'Gaming'},
    {'id': 'fitness', 'icon': '💪', 'label': 'Fitness'},
    {'id': 'dancing', 'icon': '💃', 'label': 'Dancing'},
    {'id': 'movies', 'icon': '🎬', 'label': 'Movies'},
    {'id': 'nature', 'icon': '🌿', 'label': 'Nature'},
  ];

  void _togglePassion(String id) {
    setState(() {
      if (selectedPassions.contains(id)) {
        selectedPassions.remove(id);
      } else if (selectedPassions.length < 5) {
        selectedPassions.add(id);
      }
    });
  }

  void _handleContinue() {
    if (selectedPassions.isNotEmpty) {
      // Sauvegarder les passions dans le bloc
      context.read<OnboardingBloc>().add(UpdatePassions(selectedPassions));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one passion'.tr()),
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
        } else if (state.passions != null && state.passions!.isNotEmpty) {
          // Naviguer vers l'écran suivant uniquement après la sauvegarde réussie
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OnboardingGenderScreen(),
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
                      'Your Passions'.tr().toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select up to 5 things you love'
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

              // Grille de passions
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: passions.length,
                  itemBuilder: (context, index) {
                    final passion = passions[index];
                    final isSelected = selectedPassions.contains(passion['id']);

                    return InkWell(
                      onTap: () => _togglePassion(passion['id']),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? primaryColor : Colors.grey[300]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              passion['icon'],
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              passion['label'].toString().tr(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? primaryColor : Colors.black,
                              ),
                            ),
                          ],
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
                          colors: selectedPassions.isNotEmpty
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
                                'Continue (${selectedPassions.length}/5)'.tr().toString(),
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
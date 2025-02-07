import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hookup4u2/common/constants/colors.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_bloc.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_event.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_state.dart';
import 'package:hookup4u2/features/auth/onboarding/screens/onboarding_success_screen.dart';

class OnboardingBioScreen extends StatefulWidget {
  const OnboardingBioScreen({super.key});

  @override
  State<OnboardingBioScreen> createState() => _OnboardingBioScreenState();
}

class _OnboardingBioScreenState extends State<OnboardingBioScreen> {
  final TextEditingController _bioController = TextEditingController();
  final int maxLength = 500;
  bool _isSaving = false;
  
  final List<String> suggestions = [
    "I love traveling and discovering new cultures 🌍",
    "Coffee addict ☕️ and book lover 📚",
    "Looking for someone to share adventures with 🌟",
    "Passionate about photography 📸 and art 🎨",
    "Foodie who loves trying new restaurants 🍜",
    "Music lover 🎵 and occasional singer 🎤",
  ];

  Future<void> _saveBioAndCompleteProfile() async {
    if (_bioController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please write something about yourself'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not found');

      // Sauvegarder la bio dans Firestore
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
        'bio': _bioController.text.trim(),
        'profileCompleted': true,  // Marquer le profil comme complété
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Mettre à jour le bloc avec la bio
      context.read<OnboardingBloc>().add(UpdateBio(_bioController.text.trim()));
      
      // Finaliser l'onboarding
      context.read<OnboardingBloc>().add(CompleteOnboarding());

      // Naviguer vers l'écran de succès
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const OnboardingSuccessScreen(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving bio: $e'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    'Write your bio'.tr().toString(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a bio to let people know more about you'
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

            // Champ de saisie de la bio
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _bioController,
                  maxLength: maxLength,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Write something about yourself...'.tr().toString(),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
            ),

            // Suggestions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need inspiration?'.tr().toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () {
                              _bioController.text = suggestions[index];
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Try this'.tr().toString(),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
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

            const Spacer(),

            // Bouton Continuer
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _bioController.text.trim().isNotEmpty
                        ? [primaryColor, primaryColor.withOpacity(0.8)]
                        : [Colors.grey[300]!, Colors.grey[400]!],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: ElevatedButton(
                  onPressed: _isSaving || _bioController.text.trim().isEmpty
                      ? null
                      : _saveBioAndCompleteProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Complete Profile'.tr().toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
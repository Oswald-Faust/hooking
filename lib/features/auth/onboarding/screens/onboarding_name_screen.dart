import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hookup4u2/common/constants/colors.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_bloc.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_event.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_state.dart';
import 'package:hookup4u2/common/widets/custom_snackbar.dart';
import 'package:hookup4u2/features/auth/onboarding/screens/onboarding_birthdate_screen.dart';
import 'package:hookup4u2/features/auth/onboarding/screens/onboarding_otp_screen.dart';

class OnboardingNameScreen extends StatefulWidget {
  const OnboardingNameScreen({super.key});

  @override
  State<OnboardingNameScreen> createState() => _OnboardingNameScreenState();
}

class _OnboardingNameScreenState extends State<OnboardingNameScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isEmailMethod = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    final firstName = _firstNameController.text.trim();
    if (firstName.isEmpty) {
      CustomSnackbar.showSnackBarSimple(
        'Please enter your first name'.tr().toString(),
        context,
      );
      return;
    }

    if (_isEmailMethod) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      if (email.isEmpty || !email.contains('@')) {
        CustomSnackbar.showSnackBarSimple(
          'Please enter a valid email'.tr().toString(),
          context,
        );
        return;
      }
      if (password.length < 6) {
        CustomSnackbar.showSnackBarSimple(
          'Password must be at least 6 characters'.tr().toString(),
          context,
        );
        return;
      }
      context.read<OnboardingBloc>().add(CreateAccountWithEmail(
        email: email,
        password: password,
      ));
    } else {
      final phone = _phoneController.text.trim();
      if (phone.isEmpty) {
        CustomSnackbar.showSnackBarSimple(
          'Please enter your phone number'.tr().toString(),
          context,
        );
        return;
      }
      context.read<OnboardingBloc>().add(StartPhoneVerification(
        phoneNumber: phone,
      ));
    }
    
    context.read<OnboardingBloc>().add(UpdateFirstName(firstName));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state.status == OnboardingStatus.accountCreated) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OnboardingBirthdateScreen(),
            ),
          );
        } else if (state.status == OnboardingStatus.awaitingOTP) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OnboardingOtpScreen(
                verificationId: state.verificationId!,
                phoneNumber: _phoneController.text,
              ),
            ),
          );
        } else if (state.status == OnboardingStatus.failure) {
          CustomSnackbar.showSnackBarSimple(
            state.error ?? 'An error occurred'.tr().toString(),
            context,
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create your profile'.tr().toString(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Prénom
                  TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name'.tr().toString(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Choix de la méthode
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() => _isEmailMethod = true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isEmailMethod ? primaryColor : Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Email'.tr().toString(),
                            style: TextStyle(
                              color: _isEmailMethod ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() => _isEmailMethod = false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !_isEmailMethod ? primaryColor : Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Phone'.tr().toString(),
                            style: TextStyle(
                              color: !_isEmailMethod ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Champs conditionnels selon la méthode
                  if (_isEmailMethod) ...[
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email'.tr().toString(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password'.tr().toString(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ] else ...[
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number'.tr().toString(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Bouton Continuer
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: BlocBuilder<OnboardingBloc, OnboardingState>(
                        builder: (context, state) {
                          if (state.status == OnboardingStatus.loading) {
                            return const CircularProgressIndicator(
                              color: Colors.white,
                            );
                          }
                          return Text(
                            'Continue'.tr().toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          );
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
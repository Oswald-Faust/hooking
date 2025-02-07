import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hookup4u2/common/constants/colors.dart';
import 'package:hookup4u2/common/widets/custom_snackbar.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_bloc.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_event.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_state.dart';
import 'package:hookup4u2/features/auth/onboarding/screens/onboarding_birthdate_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OnboardingOtpScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OnboardingOtpScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OnboardingOtpScreen> createState() => _OnboardingOtpScreenState();
}

class _OnboardingOtpScreenState extends State<OnboardingOtpScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOTP() {
    if (_otpController.text.length == 6) {
      context.read<OnboardingBloc>().add(
        VerifyPhoneNumber(smsCode: _otpController.text),
      );
    } else {
      CustomSnackbar.showSnackBarSimple(
        'Please enter a valid 6-digit code'.tr().toString(),
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state.status == OnboardingStatus.accountCreated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const OnboardingBirthdateScreen(),
            ),
          );
        } else if (state.status == OnboardingStatus.failure) {
          CustomSnackbar.showSnackBarSimple(
            state.error ?? 'Verification failed'.tr().toString(),
            context,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verify your number'.tr().toString(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the code sent to'.tr().toString(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  widget.phoneNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8),
                    fieldHeight: 50,
                    fieldWidth: 45,
                    activeFillColor: Colors.white,
                    selectedFillColor: Colors.grey[100],
                    inactiveFillColor: Colors.grey[100],
                    activeColor: primaryColor,
                    selectedColor: primaryColor,
                    inactiveColor: Colors.grey[300]!,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  enableActiveFill: true,
                  onCompleted: (value) => _verifyOTP(),
                  onChanged: (value) {},
                ),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _verifyOTP,
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
                          'Verify'.tr().toString(),
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
    );
  }
} 
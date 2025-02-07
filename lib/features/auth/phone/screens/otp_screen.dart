import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hookup4u2/common/constants/colors.dart';
import 'package:hookup4u2/features/auth/login/bloc/login_bloc.dart';
import 'package:hookup4u2/features/auth/login/bloc/login_event.dart';
import 'package:hookup4u2/features/auth/login/bloc/login_state.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final bool isLogin;

  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.isLogin,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _handleVerify() {
    final smsCode = _pinController.text.trim();
    if (smsCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid code'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<LoginBloc>().add(VerifyPhoneOTP(
      verificationId: widget.verificationId,
      smsCode: smsCode,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } else if (state.status == LoginStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'Une erreur est survenue'.tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 24),
                Text(
                  'Enter verification code'.tr().toString(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Code sent to ${widget.phoneNumber}'.tr().toString(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: PinCodeTextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    length: 6,
                    obscureText: false,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(10),
                      fieldHeight: 50,
                      fieldWidth: 35,
                      inactiveFillColor: Colors.white,
                      inactiveColor: primaryColor,
                      selectedColor: Colors.green,
                      selectedFillColor: Colors.white,
                      activeFillColor: Colors.white,
                      activeColor: Colors.green,
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    onChanged: (value) {},
                    appContext: context,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: BlocBuilder<LoginBloc, LoginState>(
                      builder: (context, state) {
                        if (state.status == LoginStatus.loading) {
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
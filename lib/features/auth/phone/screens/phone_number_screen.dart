import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:hookup4u2/common/constants/colors.dart';
import 'package:hookup4u2/features/auth/login/bloc/login_bloc.dart';
import 'package:hookup4u2/features/auth/login/bloc/login_event.dart';
import 'package:hookup4u2/features/auth/login/bloc/login_state.dart';
import 'package:hookup4u2/features/auth/phone/screens/otp_screen.dart';

class PhoneNumberScreen extends StatefulWidget {
  final bool isLogin;

  const PhoneNumberScreen({
    super.key,
    required this.isLogin,
  });

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _countryCode = '+33'; // Code par défaut pour la France
  String _selectedCountry = 'FR';
  int _maxLength = 9; // Longueur par défaut pour la France

  // Map des longueurs de numéros par pays
  final Map<String, int> _phoneNumberLengths = {
    'FR': 9, // France: 9 chiffres
    'US': 10, // États-Unis: 10 chiffres
    'GB': 10, // Royaume-Uni: 10 chiffres
    'DE': 11, // Allemagne: 11 chiffres
    'ES': 9, // Espagne: 9 chiffres
    // Ajoutez d'autres pays selon vos besoins
  };

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _updatePhoneNumberLength(String countryCode) {
    setState(() {
      _maxLength = _phoneNumberLengths[countryCode] ?? 10;
    });
  }

  void _handleContinue() {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your phone number'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (phoneNumber.length < _maxLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid phone number for $_selectedCountry'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Formater le numéro de téléphone avec le code pays
    final fullPhoneNumber = '$_countryCode$phoneNumber';
    
    if (widget.isLogin) {
      context.read<LoginBloc>().add(LoginWithPhone(phoneNumber: fullPhoneNumber));
    } else {
      // Logique pour l'inscription
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.verificationId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(
                verificationId: state.verificationId!,
                phoneNumber: '$_countryCode${_phoneController.text}',
                isLogin: widget.isLogin,
              ),
            ),
          );
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
                  'Enter your phone number'.tr().toString(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We will send you a verification code'.tr().toString(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Champ de numéro de téléphone avec sélecteur de pays
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                          textTheme: Theme.of(context).textTheme.apply(
                            bodyColor: Colors.black,
                            displayColor: Colors.black,
                          ),
                          dialogBackgroundColor: Colors.white,
                        ),
                        child: CountryCodePicker(
                          onChanged: (CountryCode countryCode) {
                            setState(() {
                              _countryCode = countryCode.dialCode ?? '+33';
                              _selectedCountry = countryCode.code ?? 'FR';
                              _updatePhoneNumberLength(_selectedCountry);
                            });
                          },
                          initialSelection: 'FR',
                          favorite: const ['FR', 'US', 'GB', 'DE', 'ES'],
                          showCountryOnly: false,
                          showOnlyCountryWhenClosed: false,
                          alignLeft: false,
                          dialogTextStyle: const TextStyle(color: Colors.black),
                          searchStyle: const TextStyle(color: Colors.black),
                          dialogBackgroundColor: Colors.white,
                          barrierColor: Colors.black54,
                          boxDecoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: _maxLength,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            hintText: 'Phone Number'.tr().toString(),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            counterText: '', // Cache le compteur de caractères
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Affichage du format attendu
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Format: $_countryCode + $_maxLength digits'.tr(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
                
                const Spacer(),
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
                    child: BlocBuilder<LoginBloc, LoginState>(
                      builder: (context, state) {
                        if (state.status == LoginStatus.loading) {
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
    );
  }
} 
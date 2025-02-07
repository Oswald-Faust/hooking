import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hookup4u2/common/constants/colors.dart';
import 'package:hookup4u2/common/routes/route_name.dart';
import 'package:hookup4u2/common/providers/user_provider.dart';
import 'package:hookup4u2/features/auth/login/bloc/login_bloc.dart';
import 'package:hookup4u2/features/auth/login/bloc/login_event.dart';
import 'package:hookup4u2/features/auth/login/bloc/login_state.dart';
import 'package:hookup4u2/features/auth/onboarding/screens/onboarding_name_screen.dart';
import 'package:hookup4u2/features/auth/phone/screens/phone_number_screen.dart';
import 'package:hookup4u2/features/auth/services/auth_service.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(
        authService: AuthService(),
      ),
      child: const LoginScreenContent(),
    );
  }
}

class LoginScreenContent extends StatefulWidget {
  const LoginScreenContent({Key? key}) : super(key: key);

  @override
  State<LoginScreenContent> createState() => _LoginScreenContentState();
}

class _LoginScreenContentState extends State<LoginScreenContent> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isEmailMethod = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_isEmailMethod) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill all fields'.tr()),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      context.read<LoginBloc>().add(LoginWithEmail(
        email: email,
        password: password,
      ));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: context.read<LoginBloc>(),
            child: const PhoneNumberScreen(isLogin: true),
          ),
        ),
      );
    }
  }

  void _handleForgotPassword() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your email'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<LoginBloc>().add(ResetPassword(email: email));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          if (state.user != null) {
            Provider.of<UserProvider>(context, listen: false).currentUser = state.user;
          }
          
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteName.tabScreen,
            (route) => false,
            arguments: {
              'isPurchased': state.user?.isPremium ?? false,
              'items': const {},
              'purchases': const [],
            },
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back'.tr().toString(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue'.tr().toString(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Choix de la méthode
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() => _isEmailMethod = true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isEmailMethod ? primaryColor : Colors.grey[200],
                            foregroundColor: _isEmailMethod ? Colors.white : Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Email'.tr().toString()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() => _isEmailMethod = false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !_isEmailMethod ? primaryColor : Colors.grey[200],
                            foregroundColor: !_isEmailMethod ? Colors.white : Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Phone'.tr().toString()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  if (_isEmailMethod) ...[
                    // Email
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
                    
                    // Mot de passe
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password'.tr().toString(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Mot de passe oublié
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _handleForgotPassword,
                        child: Text(
                          'Forgot Password?'.tr().toString(),
                          style: TextStyle(color: primaryColor),
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Bouton de connexion
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
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
                            'Sign In'.tr().toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Lien vers l'inscription
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? '.tr().toString(),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OnboardingNameScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign Up'.tr().toString(),
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
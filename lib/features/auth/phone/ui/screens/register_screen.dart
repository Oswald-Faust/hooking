import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hookup4u2/common/constants/colors.dart';
import 'package:hookup4u2/common/routes/route_name.dart';
import 'package:provider/provider.dart';
import '../../../../../common/providers/theme_provider.dart';
import '../../../../../common/widgets/custom_snackbar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.8),
              themeProvider.isDarkMode ? Colors.black : Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Logo ou Icône
                    Icon(
                      Icons.favorite,
                      size: 80,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                    ),
                    const SizedBox(height: 20),
                    // Titre
                    Text(
                      "Créez votre compte".tr().toString(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Sous-titre
                    Text(
                      "Rejoignez notre communauté".tr().toString(),
                      style: TextStyle(
                        fontSize: 16,
                        color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Champ Nom
                    Container(
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode ? Colors.black12 : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: "Votre nom".tr().toString(),
                          prefixIcon: Icon(Icons.person_outline,
                              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Le nom est requis".tr().toString();
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Champ Email
                    Container(
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode ? Colors.black12 : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: "Votre email".tr().toString(),
                          prefixIcon: Icon(Icons.email_outlined,
                              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "L'email est requis".tr().toString();
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return "Email invalide".tr().toString();
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Champ Mot de passe
                    Container(
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode ? Colors.black12 : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: "Mot de passe".tr().toString(),
                          prefixIcon: Icon(Icons.lock_outline,
                              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Le mot de passe est requis".tr().toString();
                          }
                          if (value.length < 6) {
                            return "Le mot de passe doit contenir au moins 6 caractères"
                                .tr()
                                .toString();
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Champ Confirmation mot de passe
                    Container(
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode ? Colors.black12 : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: "Confirmer le mot de passe".tr().toString(),
                          prefixIcon: Icon(Icons.lock_outline,
                              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "La confirmation du mot de passe est requise"
                                .tr()
                                .toString();
                          }
                          if (value != _passwordController.text) {
                            return "Les mots de passe ne correspondent pas"
                                .tr()
                                .toString();
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Bouton d'inscription
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [
                            primaryColor,
                            primaryColor.withOpacity(0.8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // TODO: Implémenter l'inscription
                            CustomSnackbar.showSnackBarSimple(
                                "Inscription en cours...".tr().toString(), context);
                          }
                        },
                        child: Text(
                          "S'inscrire".tr().toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Lien vers la connexion
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Déjà un compte ?".tr().toString(),
                          style: TextStyle(
                            color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, RouteName.loginScreen);
                          },
                          child: Text(
                            "Se connecter".tr().toString(),
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
} 
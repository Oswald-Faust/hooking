import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hookup4u2/common/constants/colors.dart';
import 'package:hookup4u2/common/routes/route_name.dart';
import 'package:hookup4u2/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:hookup4u2/common/providers/theme_provider.dart';

class MatchDetailsScreen extends StatelessWidget {
  final UserModel currentUser;
  final UserModel matchedUser;

  const MatchDetailsScreen({
    super.key,
    required this.currentUser,
    required this.matchedUser,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // En-tête avec bouton retour
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // Image de profil et informations
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Image de profil
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(matchedUser.imageUrl!.first),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nom et âge
                    Text(
                      "${matchedUser.name}, ${matchedUser.age}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Localisation
                    Text(
                      matchedUser.address ?? "",
                      style: TextStyle(
                        fontSize: 16,
                        color: secondryColor,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Boutons d'action
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Bouton Message
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                RouteName.matchChatScreen,
                                arguments: {
                                  'matchedUser': matchedUser,
                                  'chatId': "${currentUser.id}_${matchedUser.id}",
                                },
                              );
                            },
                            icon: const Icon(Icons.message),
                            label: Text('Message'.tr()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 12,
                              ),
                            ),
                          ),

                          // Bouton Voir profil
                          OutlinedButton.icon(
                            onPressed: () {
                              // Naviguer vers le profil détaillé
                            },
                            icon: const Icon(Icons.person),
                            label: Text('View Profile'.tr()),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryColor,
                              side: BorderSide(color: primaryColor),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Informations supplémentaires
                    if (matchedUser.editInfo != null) ...[
                      ListTile(
                        leading: Icon(Icons.work, color: primaryColor),
                        title: Text(
                          matchedUser.editInfo!['job_title'] ?? 'Not specified'.tr(),
                        ),
                        subtitle: Text(
                          matchedUser.editInfo!['company'] ?? '',
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.location_city, color: primaryColor),
                        title: Text(
                          matchedUser.editInfo!['living_in'] ?? 'Not specified'.tr(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
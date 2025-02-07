import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hookup4u2/common/constants/colors.dart';
import 'package:hookup4u2/features/explore/bloc/explore_bloc.dart';
import 'package:hookup4u2/features/explore/no_user.dart';
// import 'package:hookup4u2/features/explore/premium_map.dart';
import 'package:hookup4u2/features/street_view/street_view.dart';
import 'package:provider/provider.dart';

import '../../common/data/repo/user_location_repo.dart';
import '../../common/providers/theme_provider.dart';
import '../../models/user_model.dart';

class ExploreMapWidget extends StatefulWidget {
  final UserModel currentUser;
  final bool isPuchased;

  const ExploreMapWidget({
    super.key,
    required this.currentUser,
    required this.isPuchased,
  });

  @override
  State<ExploreMapWidget> createState() => _ExploreMapWidgetState();
}

class _ExploreMapWidgetState extends State<ExploreMapWidget> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Charger les utilisateurs à proximité
    context.read<ExploreBloc>().add(LoadNearbyUsers(
      currentUser: widget.currentUser,
      maxDistance: widget.isPuchased ? 100 : 50, // Distance réduite pour les utilisateurs gratuits
    ));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text('Explore'.tr()),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: BlocBuilder<ExploreBloc, ExploreState>(
        builder: (context, state) {
          if (state is ExploreLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            );
          }

          if (state is ExploreError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            );
          }

          if (state is ExploreLoaded) {
            if (state.nearbyUsers.isEmpty) {
              return NoUserFoundWidget(
                currentUser: widget.currentUser,
                currentAddressName: widget.currentUser.address ?? '',
              );
            }

            // Créer les marqueurs pour la carte
            _markers.clear();
            for (var user in state.nearbyUsers) {
              _markers.add(
                Marker(
                  markerId: MarkerId(user.id!),
                  position: LatLng(
                    user.coordinates!['latitude'],
                    user.coordinates!['longitude'],
                  ),
                  infoWindow: InfoWindow(
                    title: "${user.name}, ${user.age}",
                    snippet: "${state.distances[user.id]!.round()} km",
                  ),
                  onTap: () {
                    // Afficher le profil de l'utilisateur
                    _showUserProfile(user);
                  },
                ),
              );
            }

            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.currentUser.coordinates!['latitude'],
                  widget.currentUser.coordinates!['longitude'],
                ),
                zoom: 12,
              ),
              markers: _markers,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  void _showUserProfile(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Barre de glissement
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Contenu du profil
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Photo de profil
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(user.imageUrl!.first),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nom et âge
                          Text(
                            "${user.name}, ${user.age}",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Distance
                          Text(
                            "${(context.read<ExploreBloc>().state as ExploreLoaded).distances[user.id]!.round()} km away",
                            style: TextStyle(
                              color: secondryColor,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Informations supplémentaires
                          if (user.editInfo != null) ...[
                            ListTile(
                              leading: Icon(Icons.work, color: primaryColor),
                              title: Text(
                                user.editInfo!['job_title'] ?? 'Not specified'.tr(),
                              ),
                              subtitle: Text(
                                user.editInfo!['company'] ?? '',
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.location_city, color: primaryColor),
                              title: Text(
                                user.editInfo!['living_in'] ?? 'Not specified'.tr(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
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

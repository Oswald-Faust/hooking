import 'dart:io';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hookup4u2/common/constants/colors.dart';
import 'package:hookup4u2/common/utlis/upload_media.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_bloc.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_event.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_state.dart';
import 'package:hookup4u2/features/auth/onboarding/screens/onboarding_bio_screen.dart';
import 'package:hookup4u2/features/auth/services/photo_upload_service.dart';
import 'package:image_picker/image_picker.dart';

class OnboardingPhotosScreen extends StatefulWidget {
  const OnboardingPhotosScreen({super.key});

  @override
  State<OnboardingPhotosScreen> createState() => _OnboardingPhotosScreenState();
}

class _OnboardingPhotosScreenState extends State<OnboardingPhotosScreen> {
  final List<dynamic> photos = List.generate(6, (index) => null);
  final PhotoUploadService _photoUploadService = PhotoUploadService();
  bool _isUploading = false;

  Widget _buildImageWidget(dynamic photo) {
    if (photo == null) return const SizedBox();
    
    if (photo is String) {
      if (photo.startsWith('data:image')) {
        // Pour les images en base64
        return Image.memory(
          base64Decode(photo.split(',')[1]),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading image: $error');
            return Icon(Icons.error, color: Colors.red[300]);
          },
        );
      } else if (photo.startsWith('http')) {
        // Pour les URLs normales
        return Image.network(
          photo,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading image: $error');
            return Icon(Icons.error, color: Colors.red[300]);
          },
        );
      }
    } else if (photo is File) {
      // Pour les fichiers locaux sur mobile
      return Image.file(
        photo,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading image: $error');
          return Icon(Icons.error, color: Colors.red[300]);
        },
      );
    }
    
    return Icon(Icons.error, color: Colors.red[300]);
  }

  Future<void> _pickImage(int index) async {
    try {
      final file = await UploadMedia.getImage(context: context, checktype: 'profile');
      if (file != null && mounted) {
        setState(() {
          photos[index] = file;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de sélectionner l\'image'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleContinue() async {
    final selectedPhotos = photos.where((p) => p != null).toList();
    
    if (selectedPhotos.length >= 2) {
      setState(() => _isUploading = true);
      
      try {
        // Afficher un indicateur de progression
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(width: 16),
                Text('Téléchargement des photos...'.tr()),
              ],
            ),
            duration: const Duration(seconds: 30),
          ),
        );

        // Upload photos to Firebase Storage
        final urls = await _photoUploadService.uploadPhotos(selectedPhotos);
        
        // Fermer le SnackBar de progression
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        // Save URLs in the bloc
        if (!mounted) return;
        context.read<OnboardingBloc>().add(UpdatePhotos(urls));
      } catch (e) {
        debugPrint('Error uploading photos: $e');
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du téléchargement des photos'.tr()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Réessayer'.tr(),
              onPressed: _handleContinue,
              textColor: Colors.white,
            ),
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isUploading = false);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner au moins 2 photos'.tr()),
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
        } else if (state.photos != null && state.photos!.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OnboardingBioScreen(),
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ajoutez vos meilleures photos'.tr(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ajoutez au moins 2 photos pour continuer'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    final hasPhoto = photos[index] != null;
                    
                    return InkWell(
                      onTap: _isUploading ? null : () => _pickImage(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: hasPhoto
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: _buildImageWidget(photos[index]),
                                  ),
                                  if (!_isUploading)
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.close, size: 20),
                                          onPressed: () {
                                            setState(() {
                                              photos[index] = null;
                                            });
                                          },
                                          constraints: const BoxConstraints(
                                            minWidth: 30,
                                            minHeight: 30,
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 32,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ajouter une photo'.tr(),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: photos.where((p) => p != null).length >= 2
                          ? [primaryColor, primaryColor.withOpacity(0.8)]
                          : [Colors.grey[300]!, Colors.grey[400]!],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: ElevatedButton(
                    onPressed: _isUploading || photos.where((p) => p != null).length < 2
                        ? null
                        : _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isUploading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Continuer (${photos.where((p) => p != null).length}/2)'.tr(),
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
      ),
    );
  }
} 
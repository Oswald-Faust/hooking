import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  Future<List<String>> uploadPhotos(List<dynamic> photos) async {
    final List<String> urls = [];
    
    for (var photo in photos) {
      try {
        final url = await uploadPhoto(photo);
        if (url != null) urls.add(url);
      } catch (e) {
        // Si une photo échoue, on supprime toutes les photos déjà uploadées
        for (var url in urls) {
          try {
            await _storage.refFromURL(url).delete();
          } catch (e) {
            // Ignore les erreurs de suppression
          }
        }
        throw Exception('Failed to upload photo: $e');
      }
    }
    
    return urls;
  }

  Future<String?> uploadPhoto(dynamic photo) async {
    if (photo == null) return null;

    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    try {
      if (kIsWeb) {
        if (photo is XFile) {
          // Convertir l'image en base64 pour le web
          final bytes = await photo.readAsBytes();
          final base64String = base64Encode(bytes);
          final imageUrl = 'data:image/jpeg;base64,$base64String';
          
          // Stocker directement l'URL base64 dans Firestore
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .update({
            'Pictures': FieldValue.arrayUnion([imageUrl])
          });
          
          return imageUrl;
        } else if (photo is String && (photo.startsWith('data:image') || photo.startsWith('http'))) {
          return photo;
        }
      } else {
        // Pour mobile, on continue avec Firebase Storage
        final String fileName = '${_uuid.v4()}.jpg';
        final ref = _storage.ref().child('user_photos/$fileName');
        
        final file = photo is String ? File(photo) : photo as File;
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'userId': user.uid},
        );
        
        final uploadTask = ref.putFile(file, metadata);
        final snapshot = await uploadTask;
        return await snapshot.ref.getDownloadURL();
      }
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
    return null;
  }
} 
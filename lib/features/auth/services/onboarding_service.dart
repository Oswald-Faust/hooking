import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hookup4u2/features/auth/services/auth_service.dart';
import 'package:hookup4u2/models/user_model.dart';

class OnboardingService {
  final AuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  OnboardingService({required AuthService authService}) : _authService = authService;

  // Étape 1: Création du compte avec email
  Future<UserCredential> createAccountWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _authService.createAccountWithEmail(
        email: email,
        password: password,
      );

      // Créer un document utilisateur initial
      await _initializeUserDocument(
        userId: userCredential.user!.uid,
        email: email,
      );

      return userCredential;
    } catch (e) {
      throw Exception('Erreur lors de la création du compte: $e');
    }
  }

  // Étape 1 (alternative): Création du compte avec téléphone
  Future<void> startPhoneVerification({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      await _authService.createAccountWithPhone(
        phoneNumber: phoneNumber,
        onCodeSent: onCodeSent,
        onError: onError,
      );
    } catch (e) {
      throw Exception('Erreur lors de la vérification du téléphone: $e');
    }
  }

  // Étape 1.1: Vérification du code OTP (si inscription par téléphone)
  Future<void> verifyPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final userCredential = await _authService.verifyOTP(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Créer un document utilisateur initial
      await _initializeUserDocument(
        userId: userCredential.user!.uid,
        phoneNumber: userCredential.user!.phoneNumber,
      );
    } catch (e) {
      throw Exception('Erreur lors de la vérification OTP: $e');
    }
  }

  // Initialisation du document utilisateur
  Future<void> _initializeUserDocument({
    required String userId,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      final docRef = _firestore.collection('Users').doc(userId);
      final doc = await docRef.get();

      final initialData = {
        'userId': userId,
        'email': email,
        'phoneNumber': phoneNumber,
        'isProfileComplete': false,
        'createdAt': doc.exists ? null : FieldValue.serverTimestamp(),
        'lastVisited': FieldValue.serverTimestamp(),
        'onboardingStep': 'initial', // Pour suivre la progression
        'settings': {
          'distance': 100,
          'ageRange': {
            'min': 18,
            'max': 50,
          },
        },
        'isBlocked': false,
        'isPremium': false,
      };

      await docRef.set(initialData, SetOptions(merge: true));
    } catch (e) {
      print('Erreur lors de l\'initialisation du document: $e');
    }
  }

  // Mise à jour des informations de profil étape par étape
  Future<void> updateUserProfile({
    required String field,
    required dynamic value,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Aucun utilisateur connecté');

      // Déterminer l'étape d'onboarding en fonction du champ mis à jour
      String onboardingStep;
      switch (field) {
        case 'name':
          onboardingStep = 'name_completed';
          break;
        case 'birthDate':
          onboardingStep = 'birthdate_completed';
          break;
        case 'gender':
          onboardingStep = 'gender_completed';
          break;
        case 'lookingFor':
          onboardingStep = 'preferences_completed';
          break;
        case 'passions':
          onboardingStep = 'passions_completed';
          break;
        case 'photos':
          onboardingStep = 'photos_completed';
          break;
        case 'bio':
          onboardingStep = 'bio_completed';
          break;
        default:
          onboardingStep = 'in_progress';
      }

      await _firestore
          .collection('Users')
          .doc(userId)
          .set({
            field: value,
            'onboardingStep': onboardingStep,
            'lastVisited': FieldValue.serverTimestamp(),
            'lastUpdated': FieldValue.serverTimestamp(),
          }, 
          SetOptions(merge: true));
    } catch (e) {
      print('Erreur lors de la mise à jour du profil: $e');
    }
  }

  // Étape finale: Finalisation du profil
  Future<UserModel> completeOnboarding({
    required String firstName,
    required DateTime birthDate,
    required String gender,
    required List<String> lookingFor,
    required List<String> passions,
    required List<String> photos,
    required String bio,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Aucun utilisateur connecté');

    try {
      final userData = {
        'name': firstName,
        'birthDate': Timestamp.fromDate(birthDate),
        'gender': gender,
        'lookingFor': lookingFor,
        'passions': passions,
        'photos': photos,
        'bio': bio,
        'isProfileComplete': true,
        'onboardingStep': 'completed',
        'lastVisited': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'profileCompletedAt': FieldValue.serverTimestamp(),
        'settings': {
          'distance': 100,
          'ageRange': {
            'min': 18,
            'max': 50,
          },
          'showMe': true,
          'pushNotifications': true,
        },
      };

      await _firestore
          .collection('Users')
          .doc(userId)
          .set(userData, SetOptions(merge: true));

      // Récupérer le document complet
      final userDoc = await _firestore.collection('Users').doc(userId).get();
      
      if (!userDoc.exists) {
        throw Exception('Le document utilisateur n\'existe pas');
      }

      return UserModel.fromDocument(userDoc);
    } catch (e) {
      throw Exception('Erreur lors de la finalisation du profil: $e');
    }
  }

  // Vérifier l'état de l'onboarding
  Future<Map<String, dynamic>> checkOnboardingStatus() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Aucun utilisateur connecté');

    try {
      final doc = await _firestore.collection('Users').doc(userId).get();
      
      if (!doc.exists) {
        return {
          'isComplete': false,
          'step': 'not_started',
          'missingFields': ['all'],
        };
      }

      final data = doc.data() as Map<String, dynamic>;
      final List<String> missingFields = [];

      // Vérifier les champs requis
      if (data['name'] == null) missingFields.add('name');
      if (data['birthDate'] == null) missingFields.add('birthDate');
      if (data['gender'] == null) missingFields.add('gender');
      if (data['lookingFor'] == null) missingFields.add('lookingFor');
      if (data['passions'] == null) missingFields.add('passions');
      if (data['photos'] == null || (data['photos'] as List).isEmpty) {
        missingFields.add('photos');
      }
      if (data['bio'] == null) missingFields.add('bio');

      return {
        'isComplete': missingFields.isEmpty,
        'step': data['onboardingStep'] ?? 'in_progress',
        'missingFields': missingFields,
      };
    } catch (e) {
      throw Exception('Erreur lors de la vérification du statut: $e');
    }
  }
} 
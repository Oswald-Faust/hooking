import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hookup4u2/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtenir l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Connexion avec email et mot de passe
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Mettre à jour la dernière visite
      await _firestore
          .collection('Users')
          .doc(userCredential.user!.uid)
          .update({'lastVisited': FieldValue.serverTimestamp()});
      
      return userCredential;
    } catch (e) {
      throw Exception('Erreur lors de la connexion: $e');
    }
  }

  // Connexion avec numéro de téléphone
  Future<void> signInWithPhone({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          if (currentUser != null) {
            await _firestore
                .collection('Users')
                .doc(currentUser!.uid)
                .update({'lastVisited': FieldValue.serverTimestamp()});
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Erreur de vérification');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du code: $e');
    }
  }

  // Vérifier si l'utilisateur existe déjà
  Future<bool> checkUserExists(String identifier) async {
    try {
      // Vérifier par email
      if (identifier.contains('@')) {
        final methods = await _auth.fetchSignInMethodsForEmail(identifier);
        return methods.isNotEmpty;
      }
      
      // Vérifier par numéro de téléphone
      final querySnapshot = await _firestore
          .collection('Users')
          .where('phoneNumber', isEqualTo: identifier)
          .get();
      
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Erreur lors de la vérification de l\'utilisateur: $e');
    }
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Erreur lors de la réinitialisation du mot de passe: $e');
    }
  }

  // Créer un compte avec email et mot de passe
  Future<UserCredential> createAccountWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      throw Exception('Erreur lors de la création du compte: $e');
    }
  }

  // Créer un compte avec numéro de téléphone
  Future<void> createAccountWithPhone({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Erreur de vérification');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du code: $e');
    }
  }

  // Vérifier le code OTP
  Future<UserCredential> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Erreur lors de la vérification du code: $e');
    }
  }

  // Créer un nouvel utilisateur dans Firestore
  Future<UserModel> createUserInFirestore({
    required String firstName,
    required DateTime birthDate,
    required String gender,
    required List<String> lookingFor,
    required List<String> passions,
    required List<String> photos,
    required String bio,
  }) async {
    if (currentUser == null) {
      throw Exception('Aucun utilisateur connecté');
    }

    final userData = {
      'userId': currentUser!.uid,
      'name': firstName,
      'birthDate': birthDate,
      'gender': gender,
      'lookingFor': lookingFor,
      'passions': passions,
      'photos': photos,
      'bio': bio,
      'isBlocked': false,
      'isPremium': false,
      'phoneNumber': currentUser!.phoneNumber,
      'email': currentUser!.email,
      'createdAt': FieldValue.serverTimestamp(),
      'lastVisited': FieldValue.serverTimestamp(),
      'settings': {
        'distance': 100,
        'ageRange': {
          'min': 18,
          'max': 50,
        },
      },
    };

    try {
      // Créer/mettre à jour le document utilisateur
      await _firestore
          .collection('Users')
          .doc(currentUser!.uid)
          .set(userData, SetOptions(merge: true));

      // Récupérer les données mises à jour
      final userDoc = await _firestore.collection('Users').doc(currentUser!.uid).get();
      return UserModel.fromDocument(userDoc);
    } catch (e) {
      throw Exception('Erreur lors de la création du profil: $e');
    }
  }

  // Mettre à jour les informations de l'utilisateur
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('Users')
          .doc(userId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil: $e');
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }
} 
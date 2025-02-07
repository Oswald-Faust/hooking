// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hookup4u2/models/user_model.dart';

import '../../constants/constants.dart';

class UserSearchRepo {
  static CollectionReference docRef =
      firebaseFireStoreInstance.collection('Users');

  static FirebaseAuth firebaseAuth = firebaseAuthInstance;
  static Map items = {};
  static List<UserModel> matches = [];
  static List<UserModel> newmatches = [];
  static List<dynamic> likedByList = [];
  static List userRemoved = [];
  static int swipecount = 0;
  static List<UserModel> users = [];
  static Map likedMap = {};
  static Map disLikedMap = {};
  static getAccessItems() async {
    firebaseFireStoreInstance
        .collection("Item_access")
        .snapshots()
        .listen((doc) {
      if (doc.docs.isNotEmpty) {
        items = doc.docs[0].data();
        // log(doc.docs[0].data().toString());
      }
    });
  }

  static Future<int> getSwipedCount(UserModel currentUser) async {
    final querySnapshot = await firebaseFireStoreInstance
        .collection('/Users/${currentUser.id}/CheckedUser')
        .where(
          'timestamp',
          isGreaterThan:
              Timestamp.now().toDate().subtract(const Duration(days: 1)),
        )
        .get();

    final swipedCount = querySnapshot.docs.length;
    // log("from frpo count ${swipedCount.toString()}");

    return swipedCount;
  }

  static leftSwipe(UserModel currentUser, UserModel selectedUser) async {
    await docRef
        .doc(currentUser.id)
        .collection("CheckedUser")
        .doc(selectedUser.id)
        .set({
      'DislikedUser': selectedUser.id,
      'timestamp': DateTime.now(),
    }, SetOptions(merge: true));
  }

  static rightSwipe(UserModel currentUser, UserModel selectedUser) async {
    likedByList = getLikedByList(currentUser);
    if ((likedByList.contains(selectedUser.id) ||
        (selectedUser.isBot ?? false))) {
      debugPrint("coming umder searchrepo in if rightswipe");
      await docRef
          .doc(currentUser.id)
          .collection("Matches")
          .doc(selectedUser.id)
          .set({
        'Matches': selectedUser.id,
        'isRead': false,
        'userName': selectedUser.name,
        'pictureUrl': selectedUser.imageUrl![0],
        'timestamp': FieldValue.serverTimestamp()
      }, SetOptions(merge: true));
      await docRef
          .doc(selectedUser.id)
          .collection("Matches")
          .doc(currentUser.id)
          .set({
        'Matches': currentUser.id,
        'userName': currentUser.name,
        'pictureUrl': currentUser.imageUrl![0],
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp()
      }, SetOptions(merge: true));
    }

    await docRef
        .doc(currentUser.id)
        .collection("CheckedUser")
        .doc(selectedUser.id)
        .set({
      'LikedUser': selectedUser.id,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await docRef
        .doc(selectedUser.id)
        .collection("LikedBy")
        .doc(currentUser.id)
        .set({
      'LikedBy': currentUser.id,
      'timestamp': FieldValue.serverTimestamp()
    }, SetOptions(merge: true));
  }

  static Query query(UserModel currentUser) {
    debugPrint("🔍 Récupération des utilisateurs");
    debugPrint("👤 Genre de l'utilisateur connecté: ${currentUser.gender}");
    debugPrint("🎯 Recherche: ${currentUser.lookingFor}");

    Query query = docRef;

    // Filtrer par genre si l'utilisateur a des préférences
    if (currentUser.lookingFor != null && currentUser.lookingFor!.isNotEmpty) {
      query = query.where('gender', whereIn: currentUser.lookingFor);
    }

    return query;
  }

  static Future<List<UserModel>> getUserList(
    UserModel currentUser,
  ) async {
    try {
      debugPrint("🔍 Début de la recherche d'utilisateurs");

      // Récupérer les utilisateurs
      final querySnapshot = await query(currentUser).get();
      debugPrint("✓ ${querySnapshot.docs.length} utilisateurs trouvés dans la base de données");
      
      List<UserModel> userList = [];

      for (var doc in querySnapshot.docs) {
        try {
          // Ne pas traiter l'utilisateur actuel
          if (doc.id == currentUser.id) {
            continue;
          }

          debugPrint("📄 Traitement du document: ${doc.id}");
          UserModel temp = UserModel.fromDocument(doc);
          
          // Vérifier si l'utilisateur correspond aux critères
          if (temp.gender != null && currentUser.lookingFor != null) {
            if (currentUser.lookingFor!.contains(temp.gender)) {
              userList.add(temp);
              debugPrint("✅ Utilisateur ajouté: ${temp.name} (${temp.gender})");
            } else {
              debugPrint("❌ Genre non correspondant: ${temp.gender}");
            }
          } else {
            debugPrint("⚠️ Données de genre manquantes");
          }
          
        } catch (e) {
          debugPrint("⚠️ Erreur lors du traitement de l'utilisateur ${doc.id}: $e");
          continue;
        }
      }

      debugPrint("✨ Recherche terminée. ${userList.length} utilisateurs correspondants trouvés");
      return userList;
    } catch (e) {
      debugPrint("🔴 Erreur lors de la récupération des utilisateurs: $e");
      rethrow;
    }
  }

  static List<dynamic> getLikedByList(UserModel currentUser) {
    docRef
        .doc(currentUser.id)
        .collection("LikedBy")
        .snapshots()
        .listen((data) async {
      likedByList.addAll(data.docs.map((f) => f['LikedBy']));
    });
    return likedByList;
  }

  static double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}

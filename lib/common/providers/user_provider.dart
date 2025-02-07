import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../constants/constants.dart';

class UserProvider extends ChangeNotifier {
  UserProvider() {
    log('🚀 Initializing UserProvider');
    listenAuthChanges();
  }
  
  final FirebaseAuth _auth = firebaseAuthInstance;
  final CollectionReference _userCollection =
      firebaseFireStoreInstance.collection("Users");

  UserModel? _currentUser;
  StreamSubscription<QuerySnapshot>? _userSubscription;
  StreamSubscription<User?>? authStateSubscription;

  UserModel? get currentUser => _currentUser;
  set currentUser(UserModel? val) {
    log('📱 Setting currentUser: ${val?.toString() ?? 'null'}');
    _currentUser = val;
    notifyListeners();
  }

  // for listening all details of user
  Future<void> listenCurrentUserdetails() async {
    try {
      final user = _auth.currentUser;
      log('👤 Current Firebase user: ${user?.uid ?? 'null'}');
      
      if (user == null) {
        log('❌ No authenticated user found');
        return;
      }

      await _userSubscription?.cancel();
      log('🔍 Starting to listen for user details for ID: ${user.uid}');

      _userSubscription = _userCollection
          .where("userId", isEqualTo: user.uid)
          .snapshots()
          .listen((event) {
        try {
          if (event.docs.isNotEmpty) {
            log('📄 Found user document: ${event.docs.first.data()}');
            final userData = UserModel.fromDocument(event.docs.first);
            currentUser = userData;
            log('✅ Successfully updated currentUser with data');
          } else {
            log('⚠️ No user document found for ID: ${user.uid}');
          }
        } catch (e) {
          log('🔴 Error parsing user data: $e');
        }
      }, onError: (error) {
        log('🔴 Error listening to user details: $error');
      });
    } catch (e) {
      log('🔴 Error in listenCurrentUserdetails: $e');
    }
  }

  // Listen for authentication state changes
  void listenAuthChanges() {
    log('👂 Starting to listen for auth changes');
    authStateSubscription?.cancel();
    
    authStateSubscription = _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        log('🔑 Auth state changed - User logged in: ${user.uid}');
        listenCurrentUserdetails();
      } else {
        log('🚪 Auth state changed - User logged out');
        currentUser = null;
        _userSubscription?.cancel();
      }
    }, onError: (error) {
      log('🔴 Error in auth state changes: $error');
    });
  }

  void cancelCurrentUserSubscription() {
    log('🛑 Cancelling all subscriptions');
    _userSubscription?.cancel();
    authStateSubscription?.cancel();
  }

  @override
  void dispose() {
    log('♻️ Disposing UserProvider');
    cancelCurrentUserSubscription();
    super.dispose();
  }
}

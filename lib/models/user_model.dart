// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String? name;
  final bool? isBlocked;
  final bool? isPremium;
  String? address;
  final double? latitude;
  final double? longitude;
  final Map? coordinates;
  final Map? currentCoordinates;
  final Map? sexualOrientation;
  final String? userGender;
  final String? living_in;
  final String? job_title;
  final String? company;
  final bool? showMyAge;
  String? showGender;
  final int? age;
  final String? phoneNumber;
  int? maxDistance;
  Timestamp? lastmsg;
  Map? ageRange;
  final String voipToken;
  final Map? editInfo;
  final Map? streetView;
  final bool? isBot;
  List? imageUrl = [];
  var distanceBW;

  // Nouveaux champs correspondant à Firestore
  final String? email;
  final bool? isProfileComplete;
  final Timestamp? createdAt;
  final Timestamp? lastVisited;
  final Timestamp? birthDate;
  final String? gender;
  final List<String>? lookingFor;
  final String? onboardingStep;
  final Map<String, dynamic>? settings;

  UserModel({
    this.living_in,
    this.job_title,
    this.company,
    this.showMyAge,
    this.id,
    this.age,
    this.address,
    this.isBot,
    this.latitude,
    this.longitude,
    required this.voipToken,
    this.isBlocked,
    this.isPremium,
    this.coordinates,
    this.currentCoordinates,
    this.name,
    this.imageUrl,
    this.phoneNumber,
    this.lastmsg,
    this.userGender,
    this.showGender,
    this.ageRange,
    this.maxDistance,
    this.editInfo,
    this.streetView,
    this.distanceBW,
    this.sexualOrientation,
    // Nouveaux champs
    this.email,
    this.isProfileComplete,
    this.createdAt,
    this.lastVisited,
    this.birthDate,
    this.gender,
    this.lookingFor,
    this.onboardingStep,
    this.settings,
  });

  @override
  String toString() {
    return 'User: {id: $id, name: $name, email: $email, gender: $gender, lookingFor: $lookingFor, isProfileComplete: $isProfileComplete, onboardingStep: $onboardingStep, settings: $settings, ...}';
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }

    return UserModel(
      id: data['userId'] ?? '',
      voipToken: data['voipToken'] ?? '',
      name: data['UserName'] ?? '',
      isBlocked: data['isBlocked'] ?? false,
      isPremium: data['isPremium'] ?? false,
      address: data['location'] != null ? data['location']['address'] ?? '' : '',
      latitude: data['location'] != null ? data['location']['latitude'] ?? 0.0 : 0.0,
      longitude: data['location'] != null ? data['location']['longitude'] ?? 0.0 : 0.0,
      coordinates: data['location'] ?? {},
      currentCoordinates: data['currentLocation'] ?? data['location'] ?? {},
      sexualOrientation: data['sexualOrientation'] ?? {},
      userGender: data['editInfo'] != null ? data['editInfo']['userGender'] ?? '' : '',
      company: data['editInfo'] != null ? data['editInfo']['company'] ?? '' : '',
      job_title: data['editInfo'] != null ? data['editInfo']['job_title'] ?? '' : '',
      living_in: data['editInfo'] != null ? data['editInfo']['living_in'] ?? '' : '',
      showMyAge: data['editInfo'] != null ? data['editInfo']['showMyAge'] ?? false : false,
      showGender: data['showGender'] ?? '',
      age: data['age'] ?? 18,
      phoneNumber: data['phoneNumber'],
      maxDistance: data['maximum_distance'] ?? 10,
      ageRange: data['age_range'] ?? {},
      editInfo: data['editInfo'] ?? {},
      streetView: data['streetView'] ?? {},
      isBot: data['isBot'] ?? false,
      imageUrl: (data['Pictures'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      // Nouveaux champs
      email: data['email'],
      isProfileComplete: data['isProfileComplete'] ?? false,
      createdAt: data['createdAt'] as Timestamp?,
      lastVisited: data['lastVisited'] as Timestamp?,
      birthDate: data['birthDate'] as Timestamp?,
      gender: data['gender'],
      lookingFor: (data['lookingFor'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      onboardingStep: data['onboardingStep'],
      settings: data['settings'] as Map<String, dynamic>?,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: json['userId'] ?? "",
        voipToken: json['voipToken'] ?? '',
        name: json['UserName'] ?? "",
        isBlocked: json['isBlocked'] ?? false,
        isPremium: json['isPremium'] ?? false,
        address: json['location']['address'] ?? "",
        latitude: json['location']['latitude'] ?? 0,
        longitude: json['location']['longitude'] ?? 0,
        coordinates: json['coordinates'] ?? {},
        currentCoordinates: json['currentCoordinates'],
        sexualOrientation: json['sexualOrientation'],
        userGender: json['editInfo']['userGender'],
        living_in: json['living_in'],
        job_title: json['job_title'],
        company: json['company'],
        showMyAge: json['showMyAge'],
        showGender: json['showGender'],
        age: json['age'],
        phoneNumber: json['phoneNumber'],
        maxDistance: json['maximum_distance'] ?? 10,
        ageRange: json['age_range'],
        editInfo: json['editInfo'],
        streetView: json['streetView'],
        imageUrl: json['Pictures'],
        distanceBW: json['distanceBW'] ?? 0,
        isBot: json['isBot'] ?? false);
  }

  static UserModel convertStringToUserModel(String userString) {
    final userMap = jsonDecode(userString);
    return UserModel.fromJson(userMap);
  }
}

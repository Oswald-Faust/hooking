import 'package:equatable/equatable.dart';
import 'package:hookup4u2/models/user_model.dart';

enum OnboardingStatus {
  initial,
  loading,
  accountCreated,
  awaitingOTP,
  success,
  failure
}

class OnboardingState extends Equatable {
  final String? firstName;
  final DateTime? birthDate;
  final String? gender;
  final List<String>? lookingFor;
  final List<String>? passions;
  final List<String>? photos;
  final String? bio;
  final OnboardingStatus status;
  final UserModel? user;
  final String? error;
  final String? email;
  final String? password;
  final String? phoneNumber;
  final String? verificationId;

  const OnboardingState({
    this.firstName,
    this.birthDate,
    this.gender,
    this.lookingFor,
    this.passions,
    this.photos,
    this.bio,
    this.status = OnboardingStatus.initial,
    this.user,
    this.error,
    this.email,
    this.password,
    this.phoneNumber,
    this.verificationId,
  });

  factory OnboardingState.initial() {
    return const OnboardingState();
  }

  OnboardingState copyWith({
    String? firstName,
    DateTime? birthDate,
    String? gender,
    List<String>? lookingFor,
    List<String>? passions,
    List<String>? photos,
    String? bio,
    OnboardingStatus? status,
    UserModel? user,
    String? error,
    String? email,
    String? password,
    String? phoneNumber,
    String? verificationId,
  }) {
    return OnboardingState(
      firstName: firstName ?? this.firstName,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      lookingFor: lookingFor ?? this.lookingFor,
      passions: passions ?? this.passions,
      photos: photos ?? this.photos,
      bio: bio ?? this.bio,
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
      email: email ?? this.email,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      verificationId: verificationId ?? this.verificationId,
    );
  }

  @override
  List<Object?> get props => [
        firstName,
        birthDate,
        gender,
        lookingFor,
        passions,
        photos,
        bio,
        status,
        user,
        error,
        email,
        password,
        phoneNumber,
        verificationId,
      ];
} 
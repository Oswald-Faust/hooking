import 'package:equatable/equatable.dart';
import 'package:hookup4u2/models/user_model.dart';

enum LoginStatus {
  initial,
  loading,
  success,
  failure
}

class LoginState extends Equatable {
  final LoginStatus status;
  final UserModel? user;
  final String? error;
  final String? email;
  final String? phoneNumber;
  final String? verificationId;

  const LoginState({
    this.status = LoginStatus.initial,
    this.user,
    this.error,
    this.email,
    this.phoneNumber,
    this.verificationId,
  });

  factory LoginState.initial() {
    return const LoginState();
  }

  LoginState copyWith({
    LoginStatus? status,
    UserModel? user,
    String? error,
    String? email,
    String? phoneNumber,
    String? verificationId,
  }) {
    return LoginState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      verificationId: verificationId ?? this.verificationId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        error,
        email,
        phoneNumber,
        verificationId,
      ];
} 
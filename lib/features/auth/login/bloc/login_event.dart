import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginWithEmail extends LoginEvent {
  final String email;
  final String password;

  const LoginWithEmail({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class LoginWithPhone extends LoginEvent {
  final String phoneNumber;

  const LoginWithPhone({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

class VerifyPhoneOTP extends LoginEvent {
  final String verificationId;
  final String smsCode;

  const VerifyPhoneOTP({
    required this.verificationId,
    required this.smsCode,
  });

  @override
  List<Object> get props => [verificationId, smsCode];
}

class PhoneVerificationCodeSent extends LoginEvent {
  final String verificationId;

  const PhoneVerificationCodeSent(this.verificationId);

  @override
  List<Object> get props => [verificationId];
}

class ResetPassword extends LoginEvent {
  final String email;

  const ResetPassword({required this.email});

  @override
  List<Object> get props => [email];
}

class LoginError extends LoginEvent {
  final String error;

  const LoginError(this.error);

  @override
  List<Object> get props => [error];
} 
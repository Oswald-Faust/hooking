part of 'apple_login_bloc.dart';

sealed class AppleLoginState extends Equatable {
  const AppleLoginState();

  @override
  List<Object> get props => [];
}

final class AppleLoginInitial extends AppleLoginState {}

class AppleLoginLoading extends AppleLoginState {}

class AppleLoginSuccess extends AppleLoginState {
  final User? user;
  const AppleLoginSuccess({required this.user});

  @override
  List<Object> get props => [user!];
}

class AppleLoginFailed extends AppleLoginState {
  final String message;
  const AppleLoginFailed({required this.message});

  @override
  List<Object> get props => [message];
}

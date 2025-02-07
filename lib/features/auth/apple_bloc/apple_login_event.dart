part of 'apple_login_bloc.dart';

sealed class AppleLoginEvent extends Equatable {
  const AppleLoginEvent();

  @override
  List<Object> get props => [];
}
class AppleLoginRequest extends AppleLoginEvent {}

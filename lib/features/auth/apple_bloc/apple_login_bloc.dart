import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hookup4u2/common/data/repo/applelogin_repo.dart';

part 'apple_login_event.dart';
part 'apple_login_state.dart';

class AppleLoginBloc extends Bloc<AppleLoginEvent, AppleLoginState> {
  AppleLoginBloc() : super(AppleLoginInitial()) {
    on<AppleLoginEvent>((event, emit) async {
       try {
        final result = await AppleLoginRepositoryImpl().signInWithApple();

        emit(AppleLoginSuccess(user: result));
      } on SocketException {
        emit(const AppleLoginFailed(message: 'No Internet Connection'));
      } catch (e) {
        emit(AppleLoginFailed(message: e.toString()));
      }
    });
  }
}

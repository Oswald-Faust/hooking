import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hookup4u2/features/auth/login/bloc/login_event.dart';
import 'package:hookup4u2/features/auth/login/bloc/login_state.dart';
import 'package:hookup4u2/features/auth/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hookup4u2/models/user_model.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthService _authService;
  
  LoginBloc({required AuthService authService})
      : _authService = authService,
        super(LoginState.initial()) {
    
    on<LoginWithEmail>((event, emit) async {
      try {
        emit(state.copyWith(status: LoginStatus.loading));
        
        final userCredential = await _authService.signInWithEmail(
          email: event.email,
          password: event.password,
        );

        // Récupérer les données de l'utilisateur depuis Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          throw Exception('User data not found');
        }

        final userData = UserModel.fromDocument(userDoc);

        emit(state.copyWith(
          status: LoginStatus.success,
          user: userData,
          email: event.email,
        ));
      } catch (error) {
        emit(state.copyWith(
          status: LoginStatus.failure,
          error: error.toString(),
        ));
      }
    });

    on<LoginWithPhone>((event, emit) async {
      try {
        emit(state.copyWith(status: LoginStatus.loading));
        
        await _authService.signInWithPhone(
          phoneNumber: event.phoneNumber,
          onCodeSent: (verificationId) {
            add(PhoneVerificationCodeSent(verificationId));
          },
          onError: (error) {
            add(LoginError(error));
          },
        );

        emit(state.copyWith(phoneNumber: event.phoneNumber));
      } catch (error) {
        emit(state.copyWith(
          status: LoginStatus.failure,
          error: error.toString(),
        ));
      }
    });

    on<PhoneVerificationCodeSent>((event, emit) {
      emit(state.copyWith(
        verificationId: event.verificationId,
      ));
    });

    on<VerifyPhoneOTP>((event, emit) async {
      try {
        emit(state.copyWith(status: LoginStatus.loading));
        
        await _authService.verifyOTP(
          verificationId: event.verificationId,
          smsCode: event.smsCode,
        );

        emit(state.copyWith(status: LoginStatus.success));
      } catch (error) {
        emit(state.copyWith(
          status: LoginStatus.failure,
          error: error.toString(),
        ));
      }
    });

    on<ResetPassword>((event, emit) async {
      try {
        emit(state.copyWith(status: LoginStatus.loading));
        
        await _authService.resetPassword(event.email);

        emit(state.copyWith(
          status: LoginStatus.success,
          email: event.email,
        ));
      } catch (error) {
        emit(state.copyWith(
          status: LoginStatus.failure,
          error: error.toString(),
        ));
      }
    });

    on<LoginError>((event, emit) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        error: event.error,
      ));
    });
  }
} 
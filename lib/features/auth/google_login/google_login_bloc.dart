import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Events
abstract class GoogleLoginEvent {}

class GoogleLoginRequest extends GoogleLoginEvent {}

// States
abstract class GoogleLoginState {}

class GoogleLoginInitial extends GoogleLoginState {}

class GoogleLoginLoading extends GoogleLoginState {}

class GoogleLoginSuccess extends GoogleLoginState {
  final User? user;
  GoogleLoginSuccess({this.user});
}

class GoogleLoginFailed extends GoogleLoginState {
  final String message;
  GoogleLoginFailed({required this.message});
}

// Bloc
class GoogleLoginBloc extends Bloc<GoogleLoginEvent, GoogleLoginState> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  GoogleLoginBloc() : super(GoogleLoginInitial()) {
    on<GoogleLoginRequest>((event, emit) async {
      emit(GoogleLoginLoading());
      try {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          emit(GoogleLoginFailed(message: "Connexion Google annulée"));
          return;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        emit(GoogleLoginSuccess(user: userCredential.user));
      } catch (e) {
        emit(GoogleLoginFailed(message: e.toString()));
      }
    });
  }
} 
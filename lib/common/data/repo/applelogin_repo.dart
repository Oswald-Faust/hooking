
import 'package:firebase_auth/firebase_auth.dart';


import 'package:sign_in_with_apple/sign_in_with_apple.dart' as i;


abstract class AppleLoginRepository {
  Future<User?> signInWithApple();
}

class AppleLoginRepositoryImpl implements AppleLoginRepository {
  @override
  Future<User?> signInWithApple() async {
    final credential = await handleAppleLogin();

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: credential.identityToken,
    );
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    return userCredential.user;

    // final result = await FacebookAuth.instance.login();
    // final status = result.status;
    // if (status == LoginStatus.success) {
    //   final accessToken = result.accessToken;

    //   final user = await _provideFirebaseUser(accessToken: accessToken!.token);
    //   return user;
    // } else if (status == LoginStatus.cancelled ||
    //     status == LoginStatus.failed) {
    //   throw result.message.toString();
    // } else {
    //   throw 'Network Error';
    // }
  }

  //utility functions

  Future<i.AuthorizationCredentialAppleID> handleAppleLogin(
      ) async {
    i.AuthorizationCredentialAppleID? result;
    if (await i.SignInWithApple.isAvailable()) {
      try {
        result = await i.SignInWithApple.getAppleIDCredential(
          scopes: [
            i.AppleIDAuthorizationScopes.email,
            i.AppleIDAuthorizationScopes.fullName,
          ],
        );
        return result;
        //print('--------------------$result}');
      } catch (error) {
        rethrow ;
      }
    } 
    return result!;
  }
}

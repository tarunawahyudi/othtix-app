import 'dart:io';

import 'package:othtix_app/src/config/constant.dart';
import 'package:othtix_app/src/data/models/auth/new_auth_model.dart';
import 'package:othtix_app/src/data/models/user/user_model.dart';
import 'package:othtix_app/src/data/services/remote/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final AuthService _authService;

  GoogleAuthService(this._authService)
      : _googleSignIn = GoogleSignIn(
          clientId: Constant.googleClientId,
          serverClientId: Constant.googleServerClientId,
          scopes: [
            'https://www.googleapis.com/auth/userinfo.email',
            'https://www.googleapis.com/auth/userinfo.profile',
          ],
        );

  final GoogleSignIn _googleSignIn;

  static final bool supported =
      Platform.isAndroid || Platform.isIOS || Platform.isMacOS || kIsWeb;

  Future<Either<Exception, Either<NewAuthModel, UserModel>>>
      signInOrSignUp() async {
    return await TaskEither.tryCatch(
      () async {
        GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
        GoogleSignInAuthentication? googleAuth =
            await googleSignInAccount?.authentication;

        final serverAuthCode = googleSignInAccount?.serverAuthCode;
        final idToken = googleAuth?.idToken;

        if (kDebugMode) {
          debugPrint('idToken: ${googleAuth?.idToken}');
          debugPrint('$googleSignInAccount');
        }

        if (serverAuthCode == null ||
            serverAuthCode.isEmpty ||
            idToken == null) {
          await _googleSignIn.signOut();
          throw Exception('Google authentication failed, id token is null');
        }

        final response = await _authService.googleSignInOrSignUp(idToken);

        return response.data.getAuthOrNewUser();
      },
      (error, _) {
        if (error.runtimeType is Exception) return error as Exception;
        return Exception(error.toString());
      },
    ).run();
  }

  Future<void> signOut() async {
    if (supported && await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signOut();
    }
  }
}

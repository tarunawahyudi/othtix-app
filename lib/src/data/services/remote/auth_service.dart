import 'package:othtix_app/src/data/models/auth/google_auth_result.dart';
import 'package:othtix_app/src/data/models/auth/new_auth_model.dart';
import 'package:othtix_app/src/data/models/auth/register_user_model.dart';
import 'package:othtix_app/src/data/models/user/user_model.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_service.g.dart';

@RestApi()
abstract class AuthService {
  factory AuthService(Dio dio, {String? baseUrl}) = _AuthService;

  @POST('auth/register')
  Future<HttpResponse<UserModel>> registerUser(
    @Body() RegisterUserModel registerUserModel,
  );

  @POST('auth')
  Future<HttpResponse<NewAuthModel>> usernameLogin(
    @Field('username') String username,
    @Field('password') String password,
  );

  @POST('auth/google')
  Future<HttpResponse<GoogleAuthResult>> googleSignInOrSignUp(
    @Field('idToken') String idToken,
  );

  @NoBody()
  @POST('auth/activate')
  Future<HttpResponse<Map<String, String>>> requestActivationOtp();

  @PATCH('auth/activate')
  Future<HttpResponse<UserModel>> activateUser(
    @Field('otp') String otp,
  );

  @PUT('auth')
  Future<HttpResponse<NewAuthModel>> refreshAccessToken(
    @Field('refreshToken') String refreshToken,
  );

  @DELETE('auth')
  Future<HttpResponse> logoutUser(
    @Field('refreshToken') String refreshToken,
  );
}

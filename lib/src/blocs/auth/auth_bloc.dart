import 'package:othtix_app/src/core/network/dio_client.dart';
import 'package:othtix_app/src/data/models/auth/new_auth_model.dart';
import 'package:othtix_app/src/data/models/user/user_model.dart';
import 'package:othtix_app/src/data/repositories/user_repository.dart';
import 'package:othtix_app/src/data/services/remote/auth_service.dart';
import 'package:othtix_app/src/data/services/remote/google_auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'auth_bloc.freezed.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final UserRepository _userRepository;
  final DioClient _dioClient;
  final GoogleAuthService? _googleAuthService;

  final bool disableToJson;

  AuthBloc(
    this._authService,
    this._userRepository,
    this._dioClient, [
    this._googleAuthService,
    this.disableToJson = false,
  ]) : super(const _Initial()) {
    on<_AddAuthentication>(_addAuthentication);
    on<_RemoveAuthentication>(_removeAuthentication);
    on<_UpdateUserDetails>(_updateUserDetails);
  }

  UserModel? get user => _currentUser;

  UserModel? _currentUser;

  /// Refresh user detail after [_refreshAt] times [_addAuthentication] called
  int _counter = 0;
  final int _refreshAt = 3;

  Future<void> _addAuthentication(
    _AddAuthentication event,
    Emitter<AuthState> emit,
  ) async {
    _dioClient.setAccessTokenHeader(accessToken: event.newAuth.accessToken);

    final currentUser = state.mapOrNull(authenticated: (s) => s.user);

    if ((_counter < _refreshAt && currentUser != null) || event.user != null) {
      _counter++;
      _currentUser = currentUser;
      return emit(AuthState.authenticated(
        user: currentUser ?? event.user!,
        auth: event.newAuth,
      ));
    }
    _counter = 0;

    final result = await _userRepository.getMyDetails();

    return result.fold(
      (e) {
        if (e.response?.statusCode == 401) {
          _currentUser = null;
          return emit(const AuthState.unauthenticated());
        }
        return emit(AuthState.unauthenticated(exception: e));
      },
      (user) {
        _currentUser = user;
        return emit(AuthState.authenticated(
          user: user,
          auth: event.newAuth,
        ));
      },
    );
  }

  Future<void> _removeAuthentication(
    _RemoveAuthentication event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final currentState = state.mapOrNull(authenticated: (s) => s);

      if (currentState?.auth.refreshToken == null) {
        return emit(const AuthState.unauthenticated());
      }

      await _authService.logoutUser(currentState!.auth.refreshToken!);
    } finally {
      _currentUser = null;
      _dioClient.deleteAccessTokenHeader();
      await _googleAuthService?.signOut();
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _updateUserDetails(
    _UpdateUserDetails event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = (state as _Authenticated);

    if (event.user != null) {
      _currentUser = event.user;
      return emit(
        AuthState.authenticated(user: event.user!, auth: currentState.auth),
      );
    }

    final result = await _userRepository.getMyDetails();

    return result.fold(
      (_) => null,
      (user) {
        _currentUser = user;
        return emit(AuthState.authenticated(
          user: user,
          auth: currentState.auth,
        ));
      },
    );
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    if (json['authenticated']) {
      final user = UserModel.fromJson(json['user']);
      _currentUser = user;
      return AuthState.authenticated(
        user: user,
        auth: NewAuthModel.fromJson(json['auth']),
      );
    }
    return const AuthState.unauthenticated();
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    if (disableToJson) return null;
    return state.maybeMap(
      authenticated: (state) => {
        'authenticated': true,
        'user': state.user.toJson(),
        'auth': state.auth.toJson(),
      },
      orElse: () => {'authenticated': false, 'user': null},
    );
  }
}

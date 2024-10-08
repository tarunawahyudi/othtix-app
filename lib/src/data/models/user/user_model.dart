import 'package:othtix_app/src/data/models/user/user_balance_model.dart';
import 'package:othtix_app/src/data/models/user/user_group_enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    @Default([UserGroup.user]) List<UserGroup> groups,
    String? provider,
    required String id,
    required String username,
    required String fullname,
    required String email,
    String? image,
    required bool activated,
    String? location,
    double? latitude,
    double? longitude,
    required DateTime createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    @Default(UserBalanceModel(balance: 0, revenue: 0)) UserBalanceModel balance,
  }) = _UserModel;

  bool get isUserLocationSet => latitude != null && longitude != null;

  static UserModel get dummyUser => UserModel(
        id: '0',
        username: 'unknown',
        fullname: 'unknown',
        email: 'unknown',
        activated: true,
        createdAt: DateTime(2024),
      );

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

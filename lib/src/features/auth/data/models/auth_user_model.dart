import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    super.id,
    required super.email,
    super.token,
    super.createdAt,
  });

  factory AuthUserModel.fromEntity(AuthUser user) {
    return AuthUserModel(
      id: user.id,
      email: user.email,
      token: user.token,
      createdAt: user.createdAt,
    );
  }

  factory AuthUserModel.fromJson(
    Map<String, dynamic> json, {
    String? token,
  }) {
    return AuthUserModel(
      id: json['id'] as String?,
      email: json['email'] as String? ?? '',
      token: token ?? json['token'] as String?,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'token': token,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  AuthUser toEntity() {
    return AuthUser(
      id: id,
      email: email,
      token: token,
      createdAt: createdAt,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// API-facing user representation.
///
/// This model matches the locked API doc response shape exactly - it is
/// NOT a 1:1 mirror of the Firestore document. Firestore additionally
/// tracks is_deleted, last_login_at, and updated_at, none of which are
/// ever returned in an API response, so they don't belong here.
///
/// All JSON keys are snake_case (fieldRename: FieldRename.snake):
///   uid, email, name, contact, role, created_at
///
/// Fields:
/// - `uid`: Firebase UID
/// - `email`: user's email address
/// - `name`: full name, "firstName lastName" combined into one string
/// - `contact`: 11-digit 09-format contact number
/// - `role`: student | guest | organizer | faculty | super_admin
/// - `createdAt`: ISO 8601 string, set once at registration.
///   Null on sign-in responses — only present right after registration.
@JsonSerializable(fieldRename: FieldRename.snake)
class User {
  User({
    required this.uid,
    required this.email,
    required this.name,
    required this.contact,
    required this.role,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  final String uid;
  final String email;
  final String name;
  final String contact;
  final String role;

  /// ISO 8601 timestamp — only included in registration responses.
  /// Serialized as "created_at" to match the snake_case API contract.
  final String? createdAt;

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  String toString() => 'User(uid: $uid, email: $email, name: $name, role: $role)';
}

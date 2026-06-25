import 'package:json_annotation/json_annotation.dart';

part 'auth_request.g.dart';

/// Request model for user registration
///
/// Represents the data sent by client during signup
///
/// Fields (all snake_case in JSON):
/// - `email`: User's email address
/// - `password`: User's chosen password
/// - `firstName`: User's first name (JSON key: "first_name")
/// - `lastName`: User's last name (JSON key: "last_name")
/// - `contact`: User's contact phone number (JSON key: "contact")
///
/// Example:
/// ```dart
/// final request = RegisterRequest(
///   email: 'john@example.com',
///   password: 'SecurePass123',
///   firstName: 'John',
///   lastName: 'Doe',
///   contact: '09123456789',
/// );
/// ```
@JsonSerializable(fieldRename: FieldRename.snake)
class RegisterRequest {
  RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.contact,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  /// User's email address
  final String email;

  /// User's password (will be hashed by Firebase Auth)
  final String password;

  /// User's first name — JSON key: "first_name"
  final String firstName;

  /// User's last name — JSON key: "last_name"
  final String lastName;

  /// User's contact phone number — JSON key: "contact"
  final String contact;

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);

  @override
  String toString() =>
    'RegisterRequest(email: $email, firstName: $firstName,  '
    'lastName: $lastName, contact: $contact)';
}

/// Request model for user sign-in/login
///
/// Represents the credentials sent by client during login
///
/// Fields (all snake_case in JSON):
/// - `email`: User's email address
/// - `password`: User's password
///
/// Example:
/// ```dart
/// final request = SignInRequest(
///   email: 'john@example.com',
///   password: 'SecurePass123',
/// );
/// ```
@JsonSerializable(fieldRename: FieldRename.snake)
class SignInRequest {
  SignInRequest({
    required this.email,
    required this.password,
  });

  factory SignInRequest.fromJson(Map<String, dynamic> json) =>
      _$SignInRequestFromJson(json);

  /// User's email address
  final String email;

  /// User's password
  final String password;

  Map<String, dynamic> toJson() => _$SignInRequestToJson(this);

  @override
  String toString() => 'SignInRequest(email: $email)';
}

/// Request model for token refresh
///
/// Sent when client needs to refresh an expired token
///
/// Fields (all snake_case in JSON):
/// - `token`: Current/expired ID token or refresh token
///
/// Example:
/// ```dart
/// final request = RefreshTokenRequest(token: 'eyJhbGciOiJIUzI1NiIs...');
/// ```
@JsonSerializable(fieldRename: FieldRename.snake)
class RefreshTokenRequest {
  RefreshTokenRequest({
    required this.token,
  });

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestFromJson(json);

  /// Current or expired token to refresh
  final String token;

  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);

  @override
  String toString() => 'RefreshTokenRequest(hasToken: ${token.isNotEmpty})';
}

/// Validation logic for authentication request fields.
class AuthValidationService {
  static const String _emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  /// Validate email format.
  /// Returns null if valid, error message if invalid.
  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email is required';
    }

    final trimmed = email.trim().toLowerCase();

    if (!RegExp(_emailPattern).hasMatch(trimmed)) {
      return 'Invalid email format';
    }

    if (trimmed.contains(' ')) {
      return 'Email cannot contain spaces';
    }

    return null;
  }

  /// Validate password.
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  /// Validate name fields (first name / last name).
  static String? validateName(String name, String fieldName) {
    if (name.isEmpty) {
      return '$fieldName is required';
    }

    if (name.trim().isEmpty) {
      return '$fieldName cannot be empty or whitespace only';
    }

    return null;
  }

  /// Validate contact number.
  static String? validateContactNumber(String contactNumber) {
    if (contactNumber.isEmpty) {
      return 'Contact number is required';
    }

    final trimmed = contactNumber.trim();
    if (trimmed.isEmpty) {
      return 'Contact number cannot be empty or whitespace only';
    }

    if (!RegExp(r'^09\d{9}$').hasMatch(trimmed)) {
      return 'Contact number must be 11 digits starting with 09';
    }

    return null;
  }
}

class AppValidators {
  static String? required(
    String? value, [
    String message = 'This field is required',
  ]) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Strong password: ≥8 chars, at least one uppercase, lowercase, digit,
  /// and special character. Firebase Auth still manages actual password storage.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Include at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Include at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Include at least one number';
    }
    if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'))) {
      return 'Include at least one special character';
    }
    return null;
  }

  /// Light validation for login — only checks non-empty (Firebase handles the rest).
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!phoneRegex.hasMatch(value.trim().replaceAll(' ', ''))) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? positiveNumber(String? value, [String label = 'Value']) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    final n = double.tryParse(value.trim());
    if (n == null || n <= 0) {
      return 'Enter a valid positive number';
    }
    return null;
  }

  static String? maxLength(String? value, int max, [String? label]) {
    if (value != null && value.length > max) {
      return '${label ?? "Input"} must be $max characters or fewer';
    }
    return null;
  }
}

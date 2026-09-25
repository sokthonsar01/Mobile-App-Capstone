/// Checks for what the user types in a form.
///
/// How Flutter forms work:
/// every check function gets the text and must return
///   - `null`   -> the value is OK
///   - a String -> the red error message to show under the field
///
/// We keep the checks here, not inside the screens, so the login screen
/// and the sign up screen show exactly the same wording.

/// Any field that must not be left empty.
///
/// `fieldName` goes inside the message, for example "your full name".
String? validateRequired(String? value, String fieldName) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter $fieldName.';
  }
  return null;
}

/// Email must not be empty and must look like an email address.
String? validateEmail(String? value) {
  final String text = value?.trim() ?? '';

  if (text.isEmpty) {
    return 'Please enter your email address.';
  }

  // A simple pattern: something, then @, then something, then a dot,
  // then something. It is not perfect, but it catches normal typing
  // mistakes like "dsafasg" or "max@gmail".
  final RegExp emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  if (!emailPattern.hasMatch(text)) {
    return 'Please enter a valid email address, for example name@gmail.com';
  }

  return null;
}

/// Password must not be empty and must be long enough.
String? validatePassword(String? value) {
  final String text = value ?? '';

  if (text.isEmpty) {
    return 'Please enter your password.';
  }

  if (text.length < 8) {
    return 'Password must be at least 8 characters.';
  }

  return null;
}

/// Used on the sign up and update password screens.
/// A new password also needs one letter and one number.
String? validateNewPassword(String? value) {
  // First run the normal checks so we do not repeat them.
  final String? basicError = validatePassword(value);
  if (basicError != null) return basicError;

  final String text = value ?? '';

  if (!text.contains(RegExp(r'[A-Za-z]'))) {
    return 'Password must contain at least one letter.';
  }

  if (!text.contains(RegExp(r'[0-9]'))) {
    return 'Password must contain at least one number.';
  }

  return null;
}

/// The "Confirm password" field must match the new password.
String? validateConfirmPassword(String? value, String newPassword) {
  if (value == null || value.isEmpty) {
    return 'Please confirm your new password.';
  }

  if (value != newPassword) {
    return 'The passwords do not match.';
  }

  return null;
}

/// Full name: not empty and at least 2 letters.
String? validateFullName(String? value) {
  final String text = value?.trim() ?? '';

  if (text.isEmpty) {
    return 'Please enter your full name.';
  }

  if (text.length < 2) {
    return 'Please enter your full name.';
  }

  return null;
}

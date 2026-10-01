import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthSignUpStatus {
  authenticated,
  needsEmailConfirmation,
  alreadyExists,
  failed,
}

/// ViewModel responsible for authentication state and operations.
class AuthViewModel extends ChangeNotifier {
  static final AuthViewModel instance = AuthViewModel._internal();

  AuthViewModel._internal();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  bool get isAuthenticated => currentSession != null;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetToDefaults() {
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Sign in using email and password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return response.session != null;
    } on AuthException catch (e) {
      _isLoading = false;
      final msg = e.message.toLowerCase();

      if (msg.contains('invalid login credentials') ||
          e.code == 'invalid_credentials') {
        _errorMessage =
            'Incorrect email or password. If you originally signed up with Google, please tap "SIGN IN WITH GOOGLE" below.';
      } else if (msg.contains('email not confirmed') ||
          e.code == 'email_not_confirmed') {
        _errorMessage =
            'Email not confirmed. Please check your inbox or confirm in your Supabase dashboard.';
      } else if (msg.contains('user not found')) {
        _errorMessage = 'No account found with this email. Please sign up first.';
      } else {
        _errorMessage = e.message;
      }
      notifyListeners();
      return false;
    } catch (_) {
      _isLoading = false;
      _errorMessage =
          'Unable to sign in. Please check your network connection.';
      notifyListeners();
      return false;
    }
  }

  /// Sign up with first name, last name, email, and password
  Future<AuthSignUpStatus> signUpWithEmail({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    if (_isLoading) return AuthSignUpStatus.failed;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'first_name': firstName.trim(),
          'last_name': lastName.trim(),
          'name': '${firstName.trim()} ${lastName.trim()}',
        },
      );

      _isLoading = false;

      // When Supabase email enumeration protection is on, duplicate signups return empty identities.
      final identities = response.user?.identities;
      final bool alreadyExists =
          response.user != null && identities != null && identities.isEmpty;

      if (alreadyExists) {
        _errorMessage =
            'An account with this email already exists. Please log in instead.';
        notifyListeners();
        return AuthSignUpStatus.alreadyExists;
      }

      notifyListeners();

      if (response.session != null) {
        return AuthSignUpStatus.authenticated;
      } else if (response.user != null) {
        return AuthSignUpStatus.needsEmailConfirmation;
      }

      return AuthSignUpStatus.failed;
    } on AuthException catch (e) {
      _isLoading = false;
      final msg = e.message.toLowerCase();
      if (msg.contains('already registered') ||
          msg.contains('already exists') ||
          e.code == 'user_already_exists') {
        _errorMessage =
            'An account with this email already exists. Please log in instead.';
        notifyListeners();
        return AuthSignUpStatus.alreadyExists;
      }

      _errorMessage = e.message;
      notifyListeners();
      return AuthSignUpStatus.failed;
    } catch (_) {
      _isLoading = false;
      _errorMessage =
          'Sign up failed. Please check your network connection.';
      notifyListeners();
      return AuthSignUpStatus.failed;
    }
  }

  /// Sign in with Google OAuth
  Future<bool> signInWithGoogle() async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo:
            kIsWeb ? Uri.base.origin : 'io.supabase.interna://login-callback',
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _isLoading = false;
      _errorMessage = 'Google Sign-In failed. Please check your connection.';
      notifyListeners();
      return false;
    }
  }

  /// Request a password reset email
  Future<bool> resetPassword(String email) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _client.auth.resetPasswordForEmail(email.trim());
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _isLoading = false;
      _errorMessage =
          'Failed to send reset email. Please check your connection.';
      notifyListeners();
      return false;
    }
  }

  /// Sign out current session
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _client.auth.signOut();
    } finally {
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }
  }
}

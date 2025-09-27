import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // For web, you need to configure this in pubspec.yaml and index.html
    // For now, we'll handle this gracefully
  );

  final _client = Supabase.instance.client;

  Future<AuthResponse?> signInWithGoogle() async {
    try {
      // Check if Google Sign-In is available
      if (kIsWeb && !await _isGoogleSignInConfigured()) {
        throw Exception('Google Sign-In no está configurado correctamente para web. Por favor, configura las credenciales de Google.');
      }

      // Start the Google sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Get the Google authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('No se pudo obtener el token de autenticación de Google');
      }

      // Sign in to Supabase with the Google ID token
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      debugPrint('Google sign-in successful: ${response.user?.email}');
      return response;

    } catch (e) {
      debugPrint('Google sign-in error: $e');
      // Don't rethrow - handle gracefully
      throw Exception('Error al iniciar sesión con Google: ${e.toString()}');
    }
  }

  Future<bool> _isGoogleSignInConfigured() async {
    try {
      // Try to initialize Google Sign-In to check if it's configured
      await _googleSignIn.isSignedIn();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      // Sign out from both Google and Supabase
      await Future.wait([
        _googleSignIn.signOut(),
        _client.auth.signOut(),
      ]);
      debugPrint('Google sign-out successful');
    } catch (e) {
      debugPrint('Google sign-out error: $e');
      rethrow;
    }
  }

  bool get isSignedIn => _client.auth.currentUser != null;

  User? get currentUser => _client.auth.currentUser;

  GoogleSignInAccount? get currentGoogleUser => _googleSignIn.currentUser;

  // Get user info
  Map<String, String?> getUserInfo() {
    final user = _client.auth.currentUser;
    final googleUser = _googleSignIn.currentUser;
    
    return {
      'email': user?.email ?? googleUser?.email,
      'displayName': user?.userMetadata?['full_name'] ?? googleUser?.displayName,
      'photoUrl': user?.userMetadata?['avatar_url'] ?? googleUser?.photoUrl,
      'id': user?.id,
    };
  }

  // Check if user signed in with Google
  bool get isGoogleUser {
    final user = _client.auth.currentUser;
    return user?.appMetadata['provider'] == 'google';
  }
}
// lib/services/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:currensee/core/constants/app_constants.dart';
import 'package:currensee/models/user.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  // ─── Auth State Stream ───────────────────────────────────────────────────
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  // ─── Register with Email & Password ─────────────────────────────────────
  Future<AppUser> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;

      // Update display name in Firebase Auth
      await user.updateDisplayName(fullName.trim());

      // Create AppUser
      final appUser = AppUser(
        uid: user.uid,
        email: email.trim(),
        fullName: fullName.trim(),
        defaultCurrency: 'USD',
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _saveUserToFirestore(appUser);

      return appUser;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // ─── Login with Email & Password ─────────────────────────────────────────
  Future<AppUser> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;
      final appUser = await _getUserFromFirestore(user.uid);

      return appUser ??
          AppUser(
            uid: user.uid,
            email: user.email ?? email,
            fullName: user.displayName ?? 'User',
            createdAt: DateTime.now(),
          );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // ─── Google Sign In ───────────────────────────────────────────────────────
  Future<AppUser> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign-in was cancelled');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Check if user already exists in Firestore
      AppUser? existingUser = await _getUserFromFirestore(user.uid);

      if (existingUser != null) return existingUser;

      // New Google user — create Firestore document
      final appUser = AppUser(
        uid: user.uid,
        email: user.email ?? '',
        fullName: user.displayName ?? 'User',
        photoUrl: user.photoURL,
        defaultCurrency: 'USD',
        createdAt: DateTime.now(),
      );

      await _saveUserToFirestore(appUser);
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ─── Password Reset ───────────────────────────────────────────────────────
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // ─── Private Helpers ──────────────────────────────────────────────────────
  Future<void> _saveUserToFirestore(AppUser user) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(user.toMap());
  }

  Future<AppUser?> _getUserFromFirestore(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();

    if (!doc.exists || doc.data() == null) return null;
    return AppUser.fromMap(doc.data()!);
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
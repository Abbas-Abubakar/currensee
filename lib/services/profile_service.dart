// lib/features/profile/service/profile_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:currensee/core/constants/app_constants.dart';
import 'package:currensee/models/user.dart';

class ProfileService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  ProfileService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // ─── Get default currency from prefs ─────────────────────────────────────
  Future<String> getDefaultCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefDefaultCurrency) ?? 'USD';
  }

  // ─── Save default currency to prefs + Firestore ───────────────────────────
  Future<void> saveDefaultCurrency(String currencyCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefDefaultCurrency, currencyCode);

    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({'defaultCurrency': currencyCode});
    }
  }

  // ─── Get theme mode from prefs ────────────────────────────────────────────
  Future<bool> getIsDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.prefThemeMode) ?? false;
  }

  // ─── Save theme mode to prefs ─────────────────────────────────────────────
  Future<void> saveThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefThemeMode, isDark);
  }

  // ─── Update display name ──────────────────────────────────────────────────
  Future<void> updateDisplayName({
    required String uid,
    required String newName,
  }) async {
    await Future.wait([
      _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({'fullName': newName.trim()}),
      _auth.currentUser?.updateDisplayName(newName.trim()) ?? Future.value(),
    ]);
  }

  // ─── Fetch latest user from Firestore ─────────────────────────────────────
  Future<AppUser?> fetchUser(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return AppUser.fromMap(doc.data()!);
  }
}
// lib/shared/models/app_user.dart

class AppUser {
  final String uid;
  final String email;
  final String fullName;
  final String? photoUrl;
  final String defaultCurrency;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
    this.photoUrl,
    this.defaultCurrency = 'USD',
    required this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String,
      email: map['email'] as String,
      fullName: map['fullName'] as String,
      photoUrl: map['photoUrl'] as String?,
      defaultCurrency: map['defaultCurrency'] as String? ?? 'USD',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] as int,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'defaultCurrency': defaultCurrency,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? photoUrl,
    String? defaultCurrency,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      photoUrl: photoUrl ?? this.photoUrl,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
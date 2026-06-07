class FeedbackModel {
  final String uid;
  final String email;
  final int rating;
  final String category;
  final String message;
  final DateTime submittedAt;

  const FeedbackModel({
    required this.uid,
    required this.email,
    required this.rating,
    required this.category,
    required this.message,
    required this.submittedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'rating': rating,
      'category': category,
      'message': message,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }
}
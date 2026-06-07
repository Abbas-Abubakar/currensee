// lib/features/feedback/service/feedback_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currensee/models/feedback.dart';

class FeedbackService {
  final FirebaseFirestore _firestore;

  FeedbackService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> submitFeedback(FeedbackModel feedback) async {
    await _firestore
        .collection('feedback')
        .add(feedback.toMap());
  }
}
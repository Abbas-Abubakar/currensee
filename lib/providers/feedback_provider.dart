// lib/features/feedback/provider/feedback_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currensee/services/feedback_service.dart';
import 'package:currensee/providers/auth_provider.dart';
import 'package:currensee/models/feedback.dart';

// ─── Service Provider ─────────────────────────────────────────────────────
final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  return FeedbackService();
});

// ─── Feedback Notifier ────────────────────────────────────────────────────
class FeedbackNotifier extends StateNotifier<AsyncValue<void>> {
  final FeedbackService _service;
  final Ref _ref;

  FeedbackNotifier(this._service, this._ref)
      : super(const AsyncValue.data(null));

  Future<bool> submitFeedback({
    required int rating,
    required String category,
    required String message,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) throw Exception('User not logged in');

      final feedback = FeedbackModel(
        uid: user.uid,
        email: user.email,
        rating: rating,
        category: category,
        message: message,
        submittedAt: DateTime.now(),
      );

      await _service.submitFeedback(feedback);
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  String? getErrorMessage() {
    return state.maybeWhen(
      error: (e, _) => e.toString().replaceAll('Exception: ', ''),
      orElse: () => null,
    );
  }
}

final feedbackNotifierProvider =
StateNotifierProvider<FeedbackNotifier, AsyncValue<void>>((ref) {
  return FeedbackNotifier(ref.watch(feedbackServiceProvider), ref);
});
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currensee/providers/feedback_provider.dart';
import 'package:currensee/widgets/feedback_category_chip.dart';
import 'package:currensee/widgets/star_rating.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  int _rating = 0;
  String _selectedCategory = '';
  bool _isSubmitted = false;

  static const List<Map<String, String>> _categories = [
    {'label': 'General', 'emoji': '💬'},
    {'label': 'Bug Report', 'emoji': '🐛'},
    {'label': 'Feature Request', 'emoji': '✨'},
    {'label': 'UI/UX', 'emoji': '🎨'},
    {'label': 'Performance', 'emoji': '⚡'},
    {'label': 'Rates Accuracy', 'emoji': '📊'},
  ];

  String get _ratingLabel {
    switch (_rating) {
      case 1:
        return 'Poor 😞';
      case 2:
        return 'Fair 😐';
      case 3:
        return 'Good 🙂';
      case 4:
        return 'Very Good 😊';
      case 5:
        return 'Excellent 🤩';
      default:
        return 'Tap a star to rate';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a star rating'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a feedback category'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final success =
    await ref.read(feedbackNotifierProvider.notifier).submitFeedback(
      rating: _rating,
      category: _selectedCategory,
      message: _messageController.text.trim(),
    );

    if (success && mounted) {
      setState(() => _isSubmitted = true);
    } else if (mounted) {
      final error =
      ref.read(feedbackNotifierProvider.notifier).getErrorMessage();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to submit feedback'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedbackState = ref.watch(feedbackNotifierProvider);
    final isLoading = feedbackState is AsyncLoading;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Send Feedback')),
      body: _isSubmitted
          ? _SuccessView(onDone: () => Navigator.pop(context))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header Card ─────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1A73E8),
                      Color(0xFF0D47A1)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.rate_review_outlined,
                        color: Colors.white, size: 36),
                    const SizedBox(height: 10),
                    const Text(
                      'Your feedback matters!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Help us improve CurrenSee by sharing your experience.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ─── Star Rating ─────────────────────────────────
              Text(
                'Overall Rating',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: StarRating(
                  rating: _rating,
                  onRatingChanged: (r) =>
                      setState(() => _rating = r),
                  size: 44,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _ratingLabel,
                    key: ValueKey(_rating),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _rating > 0
                          ? const Color(0xFFFFA000)
                          : Colors.grey,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ─── Category ────────────────────────────────────
              Text(
                'Feedback Category',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  return FeedbackCategoryChip(
                    label: cat['label']!,
                    emoji: cat['emoji']!,
                    selected: _selectedCategory == cat['label'],
                    onTap: () => setState(
                            () => _selectedCategory = cat['label']!),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // ─── Message ─────────────────────────────────────
              Text(
                'Your Comments',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _messageController,
                maxLines: 5,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText:
                  'Tell us what you love, what could be better, or report an issue...',
                  alignLabelWithHint: true,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your feedback';
                  }
                  if (val.trim().length < 10) {
                    return 'Feedback must be at least 10 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 8),

              // ─── Privacy Note ────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your feedback is submitted securely and linked to your account for follow-up purposes only.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ─── Submit Button ───────────────────────────────
              ElevatedButton.icon(
                onPressed: isLoading ? null : _submit,
                icon: isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.send_outlined),
                label: Text(
                    isLoading ? 'Submitting...' : 'Submit Feedback'),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Success View ─────────────────────────────────────────────────────────
class _SuccessView extends StatelessWidget {
  final VoidCallback onDone;
  const _SuccessView({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF34A853).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 56,
                color: Color(0xFF34A853),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Thank You! 🎉',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your feedback has been submitted successfully. We truly appreciate you taking the time to help us improve CurrenSee.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(160, 48)),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
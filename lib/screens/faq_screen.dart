import 'package:flutter/material.dart';
import 'package:currensee/widgets/faq_tile.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  static const List<Map<String, String>> _faqs = [
    {
      'question': 'How do I convert currencies?',
      'answer':
      'Go to the Convert tab, select your base currency (From) and target currency (To), enter the amount you want to convert, then tap the Convert button. The result will appear instantly using live exchange rates.',
    },
    {
      'question': 'How often are exchange rates updated?',
      'answer':
      'Exchange rates are fetched in real-time from our data provider every time you perform a conversion or visit the Rates screen. Rates reflect the latest available market data.',
    },
    {
      'question': 'How do I set a rate alert?',
      'answer':
      'Go to the Alerts tab and tap the New Alert button. Select your currency pair, choose whether you want to be notified when the rate goes above or below your target, enter your target rate, and tap Create Alert.',
    },
    {
      'question': 'Why did my alert stop working?',
      'answer':
      'Alerts are automatically deactivated after they trigger once to avoid repeated notifications. You can re-enable an alert by toggling it back on in the Alerts tab.',
    },
    {
      'question': 'How do I change my default currency?',
      'answer':
      'Go to the Profile tab and tap Default Currency under the Preferences section. Select your preferred currency from the list. This will be used as your base currency across the app.',
    },
    {
      'question': 'Is my conversion history saved?',
      'answer':
      'Yes, every conversion you perform is automatically saved to your local history. You can view it in the Rates tab under the History section. You can also filter by currency pair or delete individual entries.',
    },
    {
      'question': 'Can I use CurrenSee offline?',
      'answer':
      'CurrenSee requires an internet connection to fetch live exchange rates and news. However, your conversion history and saved alerts are stored locally and can be viewed offline.',
    },
    {
      'question': 'How do I delete my conversion history?',
      'answer':
      'Go to the Rates tab, tap History, then tap the delete icon in the top right to clear all history. You can also swipe left on individual entries to delete them one at a time.',
    },
    {
      'question': 'How do I enable dark mode?',
      'answer':
      'Go to the Profile tab and toggle the Dark Mode switch under the Preferences section. The change takes effect immediately across the entire app.',
    },
    {
      'question': 'Is my data secure?',
      'answer':
      'Yes. CurrenSee uses Firebase Authentication for secure login and Firestore for cloud data storage. Your account is protected by industry-standard encryption. We never sell or share your personal data.',
    },
    {
      'question': 'How do I reset my password?',
      'answer':
      'On the login screen, tap Forgot Password and enter your email address. We will send you a password reset link. Check your inbox and follow the instructions.',
    },
    {
      'question': 'Which currencies are supported?',
      'answer':
      'CurrenSee supports over 30 major world currencies including USD, EUR, GBP, NGN, JPY, CAD, AUD, CHF, CNY, INR and many more. You can see the full list in the Rates tab.',
    },
  ];

  List<Map<String, String>> get _filtered => _query.isEmpty
      ? _faqs
      : _faqs
      .where((faq) =>
  faq['question']!.toLowerCase().contains(_query.toLowerCase()) ||
      faq['answer']!.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('FAQs'),
      ),
      body: Column(
        children: [
          // ─── Search ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _query = val),
              decoration: InputDecoration(
                hintText: 'Search FAQs...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                )
                    : null,
              ),
            ),
          ),

          // ─── FAQ List ────────────────────────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
              child: Text(
                'No results found.',
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: _filtered.length,
              itemBuilder: (context, index) => FaqTile(
                question: _filtered[index]['question']!,
                answer: _filtered[index]['answer']!,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
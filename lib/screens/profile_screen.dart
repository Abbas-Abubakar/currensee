import 'package:currensee/screens/feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currensee/providers/auth_provider.dart';
import 'package:currensee/providers/profile_provider.dart';
import 'package:currensee/widgets/currency_preference_sheet.dart';
import 'package:currensee/widgets/profile_header.dart';
import 'package:currensee/widgets/settings_tile.dart';
import 'package:currensee/screens/support_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showEditNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Display Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final success = await ref
                  .read(profileNotifierProvider.notifier)
                  .updateDisplayName(controller.text.trim());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Name updated successfully!'
                        : 'Failed to update name.'),
                    backgroundColor: success
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(80, 40)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content:
        const Text('Are you sure you want to sign out of CurrenSee?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authNotifierProvider.notifier).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(80, 40),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDefaultCurrencySheet(
      BuildContext context, String currentDefault) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CurrencyPreferenceSheet(
        currentDefault: currentDefault,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserNotifierProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    final profileState = ref.watch(profileNotifierProvider);
    final isLoading = profileState is AsyncLoading;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Page Title ──────────────────────────────────────────
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your account & preferences',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),

              const SizedBox(height: 20),

              // ─── Profile Header ──────────────────────────────────────
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ProfileHeader(
                  user: user,
                  onEditName: () =>
                      _showEditNameDialog(context, ref, user.fullName),
                ),

              const SizedBox(height: 28),

              // ─── Preferences Section ─────────────────────────────────
              const _SectionLabel(label: 'Preferences'),
              const SizedBox(height: 10),

              SettingsTile(
                icon: Icons.currency_exchange,
                iconColor: const Color(0xFF1A73E8),
                title: 'Default Currency',
                subtitle: 'Currently set to ${user.defaultCurrency}',
                onTap: () => _showDefaultCurrencySheet(
                    context, user.defaultCurrency),
              ),

              const SizedBox(height: 10),

              SettingsTile(
                icon: isDarkMode
                    ? Icons.dark_mode
                    : Icons.light_mode,
                iconColor: isDarkMode
                    ? const Color(0xFF9C27B0)
                    : const Color(0xFFFFA000),
                title: 'Dark Mode',
                subtitle: isDarkMode ? 'Currently on' : 'Currently off',
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (val) => ref
                      .read(profileNotifierProvider.notifier)
                      .toggleDarkMode(val),
                  activeColor: const Color(0xFF1A73E8),
                ),
              ),

              const SizedBox(height: 28),

              // ─── Account Section ─────────────────────────────────────
              const _SectionLabel(label: 'Account'),
              const SizedBox(height: 10),

              SettingsTile(
                icon: Icons.person_outline,
                iconColor: const Color(0xFF34A853),
                title: 'Edit Display Name',
                subtitle: user.fullName,
                onTap: () =>
                    _showEditNameDialog(context, ref, user.fullName),
              ),

              const SizedBox(height: 10),

              SettingsTile(
                icon: Icons.email_outlined,
                iconColor: const Color(0xFF1A73E8),
                title: 'Email Address',
                subtitle: user.email,
              ),

              const SizedBox(height: 10),

              SettingsTile(
                icon: Icons.calendar_today_outlined,
                iconColor: const Color(0xFF5F6368),
                title: 'Member Since',
                subtitle:
                '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
              ),

              const SizedBox(height: 28),

              // ─── App Section ─────────────────────────────────────────
              const _SectionLabel(label: 'App'),
              const SizedBox(height: 10),

              SettingsTile(
                icon: Icons.info_outline,
                iconColor: const Color(0xFF1A73E8),
                title: 'App Version',
                subtitle: 'CurrenSee v1.0.0',
              ),

              const SizedBox(height: 10),

              SettingsTile(
                icon: Icons.shield_outlined,
                iconColor: const Color(0xFF34A853),
                title: 'Privacy Policy',
                onTap: () {},
              ),

              const SizedBox(height: 10),

              SettingsTile(
                icon: Icons.description_outlined,
                iconColor: const Color(0xFF5F6368),
                title: 'Terms of Service',
                onTap: () {},
              ),

              const SizedBox(height: 10),
              SettingsTile(
                icon: Icons.help_outline,
                iconColor: const Color(0xFF1A73E8),
                title: 'Help & Support',
                subtitle: 'FAQs, user guide, contact us',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SupportScreen()),
                ),
              ),

              const SizedBox(height: 28),
              const _SectionLabel(label: 'Feedback'),
              const SizedBox(height: 10),
              SettingsTile(
                icon: Icons.rate_review_outlined,
                iconColor: const Color(0xFF34A853),
                title: 'Send Feedback',
                subtitle: 'Rate the app and share your thoughts',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                ),
              ),

              const SizedBox(height: 28),

              // ─── Sign Out ────────────────────────────────────────────
              const _SectionLabel(label: 'Session'),
              const SizedBox(height: 10),

              SettingsTile(
                icon: Icons.logout,
                iconColor: Colors.red,
                title: 'Sign Out',
                subtitle: 'You will be returned to the login screen',
                isDestructive: true,
                onTap: () => _showSignOutDialog(context, ref),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF5F6368),
        letterSpacing: 1.2,
      ),
    );
  }
}
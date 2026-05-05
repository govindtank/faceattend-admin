import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Account section
          const _SettingsHeader(title: 'Account'),
          _SettingsTile(
            icon: Icons.person_outline,
            iconColor: const Color(0xFF1565C0),
            title: 'Profile',
            subtitle: 'Manage your account details',
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => _showSnackBar(context, 'Profile settings coming soon'),
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            iconColor: const Color(0xFF1565C0),
            title: 'Change Password',
            subtitle: 'Update your security credentials',
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => _showSnackBar(context, 'Change password coming soon'),
          ),

          // Notifications section
          const _SettingsHeader(title: 'Notifications'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            iconColor: const Color(0xFFE65100),
            title: 'Push Notifications',
            subtitle: 'Receive attendance alerts',
            trailing: Switch(
              value: true,
              onChanged: (_) => _showSnackBar(context, 'Notifications toggled'),
              activeColor: const Color(0xFF1565C0),
            ),
            onTap: null,
          ),
          _SettingsTile(
            icon: Icons.email_outlined,
            iconColor: const Color(0xFF2E7D32),
            title: 'Email Alerts',
            subtitle: 'Daily attendance summary',
            trailing: Switch(
              value: false,
              onChanged: (_) => _showSnackBar(context, 'Email alerts toggled'),
              activeColor: const Color(0xFF1565C0),
            ),
            onTap: null,
          ),

          // System section
          const _SettingsHeader(title: 'System'),
          _SettingsTile(
            icon: Icons.cloud_sync_outlined,
            iconColor: const Color(0xFF7B1FA2),
            title: 'Sync Settings',
            subtitle: 'Configure cloud synchronization',
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => _showSnackBar(context, 'Sync settings coming soon'),
          ),
          _SettingsTile(
            icon: Icons.calendar_today_outlined,
            iconColor: const Color(0xFF00838F),
            title: 'Working Hours',
            subtitle: 'Set office hours & schedules',
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => _showSnackBar(context, 'Working hours coming soon'),
          ),
          _SettingsTile(
            icon: Icons.security_outlined,
            iconColor: const Color(0xFFC62828),
            title: 'Security',
            subtitle: 'Two-factor authentication',
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => _showSnackBar(context, 'Security settings coming soon'),
          ),

          // About section
          const _SettingsHeader(title: 'About'),
          _SettingsTile(
            icon: Icons.info_outline,
            iconColor: Colors.grey.shade700,
            title: 'Version',
            subtitle: '1.0.0 (Build 1)',
            trailing: const SizedBox.shrink(),
            onTap: null,
          ),
          _SettingsTile(
            icon: Icons.code_outlined,
            iconColor: Colors.grey.shade700,
            title: 'Open Source Licenses',
            subtitle: 'Third-party libraries',
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'FaceAttend Admin',
              applicationVersion: '1.0.0',
            ),
          ),
          _SettingsTile(
            icon: Icons.help_outline,
            iconColor: Colors.grey.shade700,
            title: 'Help & Support',
            subtitle: 'Documentation & FAQs',
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => _showSnackBar(context, 'Help & support coming soon'),
          ),

          // Logout
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<AuthService>().logout();
                Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Sign Out', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '© 2026 FaceAttend. AI-powered face recognition attendance.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final String title;
  const _SettingsHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

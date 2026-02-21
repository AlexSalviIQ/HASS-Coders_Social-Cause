import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _name;
  late String _email;
  String _phone = '+91 98765 43210';
  String _bio = 'Digital truth seeker • Fighting misinformation';
  String? _profileImagePath;
  bool _notificationsEnabled = true;

  // Activity history
  final List<Map<String, dynamic>> _activityHistory = [
    {
      'action': 'Verified an image',
      'result': 'Detected as Manipulated',
      'icon': Icons.image_rounded,
      'color': Color(0xFFEF5350),
      'time': '2 hours ago',
    },
    {
      'action': 'Analyzed a document',
      'result': 'Authentic',
      'icon': Icons.description_rounded,
      'color': Color(0xFF66BB6A),
      'time': '5 hours ago',
    },
    {
      'action': 'Verified a video',
      'result': 'Deepfake Detected',
      'icon': Icons.videocam_rounded,
      'color': Color(0xFFEF5350),
      'time': 'Yesterday',
    },
    {
      'action': 'Checked Gov ID',
      'result': 'Verified Authentic',
      'icon': Icons.badge_rounded,
      'color': Color(0xFF66BB6A),
      'time': 'Yesterday',
    },
    {
      'action': 'Reported fake content',
      'result': 'Report Submitted',
      'icon': Icons.flag_rounded,
      'color': Color(0xFFFFA726),
      'time': '2 days ago',
    },
    {
      'action': 'Analyzed voice message',
      'result': 'AI-Generated Voice',
      'icon': Icons.mic_rounded,
      'color': Color(0xFFEF5350),
      'time': '3 days ago',
    },
  ];

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _name = auth.username.isNotEmpty ? auth.username : mockProfile.name;
    _email = auth.email.isNotEmpty ? auth.email : mockProfile.email;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final p = mockProfile;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Avatar + Photo Picker
          Stack(
            children: [
              Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: _profileImagePath == null
                          ? const LinearGradient(
                              colors: [
                                AppColors.deepBlue,
                                AppColors.deepBlueLight,
                              ],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deepBlue.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: _profileImagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.file(
                              File(_profileImagePath!),
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Text(
                              _name.isNotEmpty ? _name[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showPhotoOptions(context, isDark),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.emeraldGreen,
                          AppColors.emeraldGreenLight,
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBackground
                            : AppColors.white,
                        width: 2.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.white : AppColors.charcoal,
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
          const SizedBox(height: 4),
          Text(
            _email,
            style: const TextStyle(fontSize: 14, color: AppColors.mediumGrey),
          ).animate().fadeIn(delay: 150.ms, duration: 300.ms),
          if (_bio.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _bio,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.mediumGrey : AppColors.darkGrey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ).animate().fadeIn(delay: 180.ms, duration: 300.ms),
          ],
          const SizedBox(height: 18),
          // Account Info (moved up)
          _SectionTitle(title: 'Account', isDark: isDark),
          _InfoTile(
            icon: Icons.person_rounded,
            label: 'Username',
            value: _name,
            isDark: isDark,
          ),
          _InfoTile(
            icon: Icons.email_rounded,
            label: 'Email',
            value: _email,
            isDark: isDark,
          ),
          _InfoTile(
            icon: Icons.phone_rounded,
            label: 'Phone',
            value: _phone,
            isDark: isDark,
          ),
          _InfoTile(
            icon: Icons.calendar_today_rounded,
            label: 'Member Since',
            value: 'February 2026',
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          // Edit Profile Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                onPressed: () => _showEditProfileSheet(context, isDark),
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.deepBlue,
                  side: BorderSide(
                    color: AppColors.deepBlue.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
          const SizedBox(height: 24),
          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _StatCard(
                  label: 'Verified',
                  value: '${p.totalVerified}',
                  icon: Icons.verified_rounded,
                  color: AppColors.emeraldGreen,
                  delay: 0,
                ),
                const SizedBox(width: 10),
                _StatCard(
                  label: 'Rank',
                  value: p.communityRank.split(' ').first,
                  icon: Icons.emoji_events_rounded,
                  color: const Color(0xFFF39C12),
                  delay: 100,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Rank Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF39C12).withValues(alpha: 0.1),
                    const Color(0xFFF39C12).withValues(alpha: 0.03),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFF39C12).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.communityRank,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.white
                                : AppColors.charcoal,
                          ),
                        ),
                        Text(
                          'Top 5% of community verifiers',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.mediumGrey
                                : AppColors.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          const SizedBox(height: 28),

          // Recent Activity
          _SectionTitle(title: 'Recent Activity', isDark: isDark),
          ..._activityHistory.asMap().entries.map((entry) {
            final i = entry.key;
            final a = entry.value;
            return _ActivityTile(
              action: a['action'] as String,
              result: a['result'] as String,
              icon: a['icon'] as IconData,
              color: a['color'] as Color,
              time: a['time'] as String,
              isDark: isDark,
              delay: i * 60,
            );
          }),
          const SizedBox(height: 20),

          // Settings
          _SectionTitle(title: 'Settings', isDark: isDark),
          _SettingsTile(
            icon: Icons.dark_mode_rounded,
            label: 'Dark Mode',
            isDark: isDark,
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (v) => themeProvider.toggleTheme(),
              activeThumbColor: AppColors.emeraldGreen,
            ),
          ),
          _SettingsTile(
            icon: Icons.notifications_rounded,
            label: 'Notifications',
            isDark: isDark,
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (v) {
                setState(() => _notificationsEnabled = v);
                _snack(v ? 'Notifications enabled' : 'Notifications disabled');
              },
              activeThumbColor: AppColors.emeraldGreen,
            ),
          ),
          _SettingsTile(
            icon: Icons.language_rounded,
            label: 'Language',
            isDark: isDark,
            value: 'English',
            onTap: () => _showLanguageDialog(context, isDark),
          ),
          _SettingsTile(
            icon: Icons.security_rounded,
            label: 'Privacy & Security',
            isDark: isDark,
            onTap: () => _showPrivacySheet(context, isDark),
          ),
          const SizedBox(height: 8),
          _SectionTitle(title: 'Support', isDark: isDark),
          _SettingsTile(
            icon: Icons.feedback_rounded,
            label: 'App Feedback',
            isDark: isDark,
            onTap: () => _showFeedbackDialog(context, isDark),
          ),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            label: 'Help & FAQ',
            isDark: isDark,
            onTap: () => _showHelpSheet(context, isDark),
          ),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            label: 'About KavachVerify',
            isDark: isDark,
            onTap: () => _showAboutDialog(context, isDark),
          ),
          const SizedBox(height: 12),
          // Logout button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _confirmLogout(context, isDark),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: BorderSide(
                    color: AppColors.danger.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text(
                  'Log Out',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Photo Options Sheet ───
  void _showPhotoOptions(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mediumGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Profile Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.white : AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 20),
            _photoOption(
              Icons.camera_alt_rounded,
              'Take Photo',
              AppColors.deepBlue,
              isDark,
              () async {
                Navigator.pop(ctx);
                final picker = ImagePicker();
                final photo = await picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 85,
                );
                if (photo != null) {
                  setState(() => _profileImagePath = photo.path);
                  _snack('Profile photo updated! 📸');
                }
              },
            ),
            const SizedBox(height: 8),
            _photoOption(
              Icons.photo_library_rounded,
              'Choose from Gallery',
              AppColors.emeraldGreen,
              isDark,
              () async {
                Navigator.pop(ctx);
                final picker = ImagePicker();
                final photo = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 85,
                );
                if (photo != null) {
                  setState(() => _profileImagePath = photo.path);
                  _snack('Profile photo updated! 🖼️');
                }
              },
            ),
            if (_profileImagePath != null) ...[
              const SizedBox(height: 8),
              _photoOption(
                Icons.delete_rounded,
                'Remove Photo',
                AppColors.danger,
                isDark,
                () {
                  Navigator.pop(ctx);
                  setState(() => _profileImagePath = null);
                  _snack('Profile photo removed');
                },
              ),
            ],
          ],
        ),
      ).animate().fadeIn(duration: 200.ms),
    );
  }

  Widget _photoOption(
    IconData icon,
    String label,
    Color color,
    bool isDark,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.white : AppColors.charcoal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Edit Profile Sheet ───
  void _showEditProfileSheet(BuildContext context, bool isDark) {
    // Strip +91 prefix for editing
    final rawPhone = _phone.replaceAll(RegExp(r'[^\d]'), '');
    final phoneDigits = rawPhone.length > 10
        ? rawPhone.substring(rawPhone.length - 10)
        : rawPhone;

    final nameC = TextEditingController(text: _name);
    final emailC = TextEditingController(text: _email);
    final phoneC = TextEditingController(text: phoneDigits);
    final bioC = TextEditingController(text: _bio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.75,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                const SizedBox(height: 10),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.mediumGrey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.white : AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 16),
                // Scrollable form
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full Name
                        _fieldLabel('Full Name', isDark),
                        const SizedBox(height: 6),
                        TextField(
                          controller: nameC,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.white
                                : AppColors.charcoal,
                          ),
                          decoration: _fieldDecoration(
                            Icons.person_rounded,
                            'Enter full name',
                            isDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Email
                        _fieldLabel('Email Address', isDark),
                        const SizedBox(height: 6),
                        TextField(
                          controller: emailC,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.white
                                : AppColors.charcoal,
                          ),
                          decoration: _fieldDecoration(
                            Icons.email_rounded,
                            'Enter email',
                            isDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Phone
                        _fieldLabel('Phone Number', isDark),
                        const SizedBox(height: 6),
                        TextField(
                          controller: phoneC,
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.white
                                : AppColors.charcoal,
                          ),
                          decoration: _fieldDecoration(
                            Icons.phone_rounded,
                            '10-digit number',
                            isDark,
                            prefixText: '+91 ',
                            counterText: '',
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Bio
                        _fieldLabel('Bio', isDark),
                        const SizedBox(height: 6),
                        TextField(
                          controller: bioC,
                          keyboardType: TextInputType.text,
                          maxLines: 2,
                          maxLength: 100,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.white
                                : AppColors.charcoal,
                          ),
                          decoration: _fieldDecoration(
                            Icons.short_text_rounded,
                            'Write a short bio',
                            isDark,
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(ctx),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.mediumGrey,
                                  side: BorderSide(
                                    color: AppColors.mediumGrey.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  final phone = phoneC.text.trim();
                                  if (phone.isNotEmpty && phone.length != 10) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Phone number must be 10 digits',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() {
                                    _name = nameC.text.trim().isEmpty
                                        ? _name
                                        : nameC.text.trim();
                                    _email = emailC.text.trim().isEmpty
                                        ? _email
                                        : emailC.text.trim();
                                    _phone = phone.isEmpty
                                        ? _phone
                                        : '+91 ${phone.substring(0, 5)} ${phone.substring(5)}';
                                    _bio = bioC.text.trim();
                                  });
                                  Navigator.pop(ctx);
                                  _snack('Profile updated successfully! ✨');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.deepBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text(
                                  'Save Changes',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _fieldLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.mediumGrey : AppColors.darkGrey,
      ),
    );
  }

  InputDecoration _fieldDecoration(
    IconData icon,
    String hint,
    bool isDark, {
    String? prefixText,
    String? counterText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 13,
        color: AppColors.mediumGrey.withValues(alpha: 0.7),
      ),
      prefixIcon: Icon(icon, size: 20, color: AppColors.deepBlue),
      prefixText: prefixText,
      prefixStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: isDark ? AppColors.white : AppColors.charcoal,
      ),
      counterText: counterText,
      filled: true,
      fillColor: isDark
          ? AppColors.darkSurface
          : AppColors.lightGrey.withValues(alpha: 0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.deepBlue.withValues(alpha: 0.5),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  // ─── Feedback Dialog ───
  void _showFeedbackDialog(BuildContext context, bool isDark) {
    final controller = TextEditingController();
    int rating = 0;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
          title: Text(
            'Send Feedback',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.white : AppColors.charcoal,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Star rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setDialogState(() => rating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        i < rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: const Color(0xFFF39C12),
                        size: 32,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tell us how we can improve...',
                  hintStyle: TextStyle(color: AppColors.mediumGrey),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightGrey.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                  color: isDark ? AppColors.white : AppColors.charcoal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.mediumGrey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _snack('Feedback submitted! Thank you 💚');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Help & FAQ Sheet ───
  void _showHelpSheet(BuildContext context, bool isDark) {
    final faqs = [
      {
        'q': 'How does KavachVerify detect fake content?',
        'a':
            'KavachVerify uses advanced AI models to analyze images, videos, documents, and voice recordings for signs of manipulation, deepfakes, and AI-generated content.',
      },
      {
        'q': 'What file types are supported?',
        'a':
            'We support images (JPG, PNG), videos (MP4, MOV), documents (PDF, DOC, DOCX, TXT), and voice recordings.',
      },
      {
        'q': 'How accurate is the detection?',
        'a':
            'Our AI models achieve over 95% accuracy on known manipulation techniques. Accuracy may vary for novel manipulation methods.',
      },
      {
        'q': 'Can I report fake content I find online?',
        'a':
            'Yes! Use the Report feature to submit suspicious content with supporting documentation and proof.',
      },
      {
        'q': 'Is my data private?',
        'a':
            'All uploaded content is analyzed locally or on secure servers and is never shared with third parties. Files are deleted after analysis.',
      },
      {
        'q': 'How do I improve my community rank?',
        'a':
            'Verify more content and maintain high accuracy! Active community members earn higher ranks and badges.',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (ctx, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.mediumGrey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  'Help & FAQ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.white : AppColors.charcoal,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: faqs.length,
                  itemBuilder: (ctx, i) {
                    return _FAQTile(
                      question: faqs[i]['q']!,
                      answer: faqs[i]['a']!,
                      isDark: isDark,
                      index: i,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── About Dialog ───
  void _showAboutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'assets/images/kavach_logo.png',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, -0.15),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'KavachVerify',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.white : AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 12, color: AppColors.mediumGrey),
            ),
            const SizedBox(height: 14),
            Text(
              'Truth Shield for the Digital Age.\n\nKavachVerify helps you verify the authenticity of digital content using advanced AI technology. Fight misinformation, detect deepfakes, and protect truth.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark ? AppColors.mediumGrey : AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface
                    : AppColors.lightGrey.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _aboutRow('Developed by', 'HASS Coders', isDark),
                  const SizedBox(height: 6),
                  _aboutRow('Built with', 'Flutter', isDark),
                  const SizedBox(height: 6),
                  _aboutRow('AI Models', 'Advanced ML', isDark),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Close', style: TextStyle(color: AppColors.deepBlue)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aboutRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.mediumGrey),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.white : AppColors.charcoal,
          ),
        ),
      ],
    );
  }

  // ─── Language Dialog ───
  void _showLanguageDialog(BuildContext context, bool isDark) {
    String selected = 'English';
    final langs = ['English', 'हिन्दी', 'मराठी'];
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
          title: Text(
            'Select Language',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.white : AppColors.charcoal,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: langs
                .map(
                  (lang) => RadioListTile<String>(
                    title: Text(
                      lang,
                      style: TextStyle(
                        color: isDark ? AppColors.white : AppColors.charcoal,
                        fontSize: 14,
                      ),
                    ),
                    value: lang,
                    groupValue: selected,
                    activeColor: AppColors.deepBlue,
                    onChanged: (v) =>
                        setDialogState(() => selected = v ?? 'English'),
                    dense: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                )
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.mediumGrey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _snack('Language set to $selected');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Privacy Sheet ───
  void _showPrivacySheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mediumGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Privacy & Security',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.white : AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 20),
            _privacyRow(
              Icons.lock_rounded,
              'End-to-end encrypted analysis',
              isDark,
            ),
            const SizedBox(height: 12),
            _privacyRow(
              Icons.delete_forever_rounded,
              'Files deleted after processing',
              isDark,
            ),
            const SizedBox(height: 12),
            _privacyRow(
              Icons.visibility_off_rounded,
              'No data shared with third parties',
              isDark,
            ),
            const SizedBox(height: 12),
            _privacyRow(
              Icons.cloud_off_rounded,
              'Offline analysis available',
              isDark,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _snack('All personal data cleared');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger.withValues(alpha: 0.1),
                  foregroundColor: AppColors.danger,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Clear All Data',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 200.ms),
    );
  }

  Widget _privacyRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.emeraldGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.emeraldGreen),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.white : AppColors.charcoal,
            ),
          ),
        ),
        const Icon(
          Icons.check_circle_rounded,
          size: 18,
          color: AppColors.emeraldGreen,
        ),
      ],
    );
  }

  // ─── Confirm Logout ───
  void _confirmLogout(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
        title: Text(
          'Log Out?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.white : AppColors.charcoal,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of KavachVerify?',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.mediumGrey : AppColors.darkGrey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.mediumGrey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Provider.of<AuthProvider>(context, listen: false).logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final int delay;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.white : AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.mediumGrey),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
      delay: Duration(milliseconds: 200 + delay),
      duration: 400.ms,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionTitle({required this.title, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.mediumGrey : AppColors.darkGrey,
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? value;
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.isDark,
    this.trailing,
    this.onTap,
    this.value,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: onTap,
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.deepBlue.withValues(alpha: isDark ? 0.2 : 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.deepBlue),
          ),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.white : AppColors.charcoal,
            ),
          ),
          subtitle: value != null
              ? Text(
                  value!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.mediumGrey,
                  ),
                )
              : null,
          trailing:
              trailing ??
              Icon(Icons.chevron_right_rounded, color: AppColors.mediumGrey),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.deepBlue.withValues(
                  alpha: isDark ? 0.2 : 0.08,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: AppColors.deepBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.white : AppColors.charcoal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String action;
  final String result;
  final IconData icon;
  final Color color;
  final String time;
  final bool isDark;
  final int delay;
  const _ActivityTile({
    required this.action,
    required this.result,
    required this.icon,
    required this.color,
    required this.time,
    required this.isDark,
    required this.delay,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.white : AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result,
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: const TextStyle(fontSize: 10, color: AppColors.mediumGrey),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
      delay: Duration(milliseconds: 400 + delay),
      duration: 300.ms,
    );
  }
}

class _FAQTile extends StatefulWidget {
  final String question;
  final String answer;
  final bool isDark;
  final int index;
  const _FAQTile({
    required this.question,
    required this.answer,
    required this.isDark,
    required this.index,
  });
  @override
  State<_FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<_FAQTile> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: widget.isDark
            ? AppColors.darkSurface
            : AppColors.lightGrey.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.deepBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Q${widget.index + 1}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepBlue,
                ),
              ),
            ),
          ),
          title: Text(
            widget.question,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.isDark ? AppColors.white : AppColors.charcoal,
            ),
          ),
          trailing: AnimatedRotation(
            turns: _expanded ? 0.5 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(
              Icons.expand_more_rounded,
              color: AppColors.mediumGrey,
            ),
          ),
          onExpansionChanged: (v) => setState(() => _expanded = v),
          children: [
            Text(
              widget.answer,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: widget.isDark
                    ? AppColors.mediumGrey
                    : AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

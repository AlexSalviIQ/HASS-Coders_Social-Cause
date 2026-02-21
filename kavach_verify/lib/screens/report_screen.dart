import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _platformController = TextEditingController();
  String _contentType = 'Text';
  String _severity = 'Medium';
  bool _isSubmitting = false;

  final _contentTypes = [
    'Text',
    'Image',
    'Video',
    'Audio',
    'Document',
    'Website/Link',
  ];
  final _severityLevels = ['Low', 'Medium', 'High', 'Critical'];

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _descriptionController.dispose();
    _platformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF1744), Color(0xFFFF5252)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF1744).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.flag_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Report Fake Content',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.white : AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Submit to Cyber Security team',
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
            ).animate().fadeIn(duration: 350.ms),
            const SizedBox(height: 24),

            // Content Title
            _buildLabel('Title / Subject', isDark),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _titleController,
              hint: 'e.g. Fake news about government policy',
              isDark: isDark,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 18),

            // Content Type
            _buildLabel('Content Type', isDark),
            const SizedBox(height: 6),
            _buildDropdown(
              value: _contentType,
              items: _contentTypes,
              isDark: isDark,
              onChanged: (v) => setState(() => _contentType = v!),
            ),
            const SizedBox(height: 18),

            // URL / Source
            _buildLabel('URL / Source Link', isDark),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _urlController,
              hint: 'https://example.com/fake-article',
              isDark: isDark,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 18),

            // Platform
            _buildLabel('Platform / Source', isDark),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _platformController,
              hint: 'e.g. WhatsApp, Facebook, Twitter, News site',
              isDark: isDark,
            ),
            const SizedBox(height: 18),

            // Severity
            _buildLabel('Severity', isDark),
            const SizedBox(height: 8),
            Row(
              children: _severityLevels.map((level) {
                final isSelected = _severity == level;
                final color = _severityColor(level);
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: level != 'Critical' ? 8 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () => setState(() => _severity = level),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: 0.15)
                              : (isDark
                                    ? AppColors.darkCard
                                    : AppColors.offWhite),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? color
                                : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightGrey),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            level,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? color
                                  : (isDark
                                        ? AppColors.mediumGrey
                                        : AppColors.darkGrey),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Description
            _buildLabel('Description', isDark),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _descriptionController,
              hint:
                  'Describe the fake content in detail — what is false, why it is harmful, any evidence...',
              isDark: isDark,
              maxLines: 5,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please describe the content'
                  : null,
            ),
            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Submit Report',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 350.ms),
            const SizedBox(height: 16),

            // Info note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.deepBlue.withValues(alpha: 0.1)
                    : AppColors.deepBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.deepBlue.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.deepBlueLight,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your report will be reviewed by the Cyber Security team. You may be contacted for additional evidence.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.mediumGrey
                            : AppColors.darkGrey,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.white : AppColors.charcoal,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? AppColors.white : AppColors.charcoal,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 13,
          color: isDark ? AppColors.mediumGrey : AppColors.darkGrey,
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkCard : AppColors.offWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightGrey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightGrey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.deepBlueLight),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required bool isDark,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightGrey,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: isDark ? AppColors.darkCard : AppColors.white,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.white : AppColors.charcoal,
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Color _severityColor(String level) {
    switch (level) {
      case 'Low':
        return const Color(0xFF4CAF50);
      case 'Medium':
        return const Color(0xFFF59E0B);
      case 'High':
        return const Color(0xFFFF5722);
      case 'Critical':
        return const Color(0xFFFF1744);
      default:
        return AppColors.mediumGrey;
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Simulate submission delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // Clear form
    _titleController.clear();
    _urlController.clear();
    _descriptionController.clear();
    _platformController.clear();
    setState(() {
      _contentType = 'Text';
      _severity = 'Medium';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Report submitted successfully! The Cyber Security team will review it.',
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

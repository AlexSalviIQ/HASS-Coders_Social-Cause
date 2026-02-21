import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _descController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  // Documentation uploads (proof documents)
  final List<Map<String, String>> _documentation = [];
  // Proof uploads (images, videos, documents as evidence)
  final List<Map<String, String>> _proof = [];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _pickDocumentation() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _documentation.add({
            'path': result.files.single.path ?? '',
            'name': result.files.single.name,
            'type': 'document',
          });
        });
      }
    } catch (e) {
      _snack('Cannot pick document');
    }
  }

  void _pickProof() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(18),
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
              'Add Proof',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ProofOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Image',
                  color: AppColors.deepBlue,
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final f = await _imagePicker.pickImage(
                        source: ImageSource.gallery,
                        requestFullMetadata: false,
                      );
                      if (f != null) {
                        setState(() {
                          _proof.add({
                            'path': f.path,
                            'name': f.name,
                            'type': 'image',
                          });
                        });
                      }
                    } catch (e) {
                      _snack('Cannot pick image');
                    }
                  },
                ),
                _ProofOption(
                  icon: Icons.videocam_rounded,
                  label: 'Video',
                  color: AppColors.danger,
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final f = await _imagePicker.pickVideo(
                        source: ImageSource.gallery,
                      );
                      if (f != null) {
                        setState(() {
                          _proof.add({
                            'path': f.path,
                            'name': f.name,
                            'type': 'video',
                          });
                        });
                      }
                    } catch (e) {
                      _snack('Cannot pick video');
                    }
                  },
                ),
                _ProofOption(
                  icon: Icons.description_rounded,
                  label: 'Document',
                  color: const Color(0xFF8B5CF6),
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: [
                          'pdf',
                          'doc',
                          'docx',
                          'txt',
                          'png',
                          'jpg',
                        ],
                      );
                      if (result != null && result.files.isNotEmpty) {
                        setState(() {
                          _proof.add({
                            'path': result.files.single.path ?? '',
                            'name': result.files.single.name,
                            'type': 'document',
                          });
                        });
                      }
                    } catch (e) {
                      _snack('Cannot pick document');
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 180.ms),
    );
  }

  void _removeDoc(int index) {
    setState(() => _documentation.removeAt(index));
  }

  void _removeProof(int index) {
    setState(() => _proof.removeAt(index));
  }

  void _submit() async {
    if (_descController.text.trim().isEmpty &&
        _documentation.isEmpty &&
        _proof.isEmpty) {
      _snack('Please add a description or upload proof');
      return;
    }
    setState(() => _isSubmitting = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final result = await ApiService.submitReport(
      userId: auth.userId,
      description: _descController.text.trim(),
      proofUrls: _proof.map((p) => p['path'] ?? '').toList(),
      documentationUrls: _documentation.map((d) => d['path'] ?? '').toList(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result['status'] == 'success') {
      _snack('Report submitted successfully! 🛡️');
      _descController.clear();
      setState(() {
        _documentation.clear();
        _proof.clear();
      });
    } else {
      _snack(result['message'] ?? 'Failed to submit report');
    }
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Report Fake Content',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.white : AppColors.charcoal,
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 4),
          Text(
            'Help us fight misinformation by reporting suspicious content',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.mediumGrey : AppColors.darkGrey,
            ),
          ).animate().fadeIn(delay: 80.ms, duration: 300.ms),
          const SizedBox(height: 24),

          // Description field
          _sectionLabel('Description', isDark),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkCard
                  : AppColors.lightGrey.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorder
                    : AppColors.mediumGrey.withValues(alpha: 0.2),
              ),
            ),
            child: TextField(
              controller: _descController,
              maxLines: 4,
              minLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe the fake content you want to report...',
                hintStyle: TextStyle(color: AppColors.mediumGrey, fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.white : AppColors.charcoal,
              ),
            ),
          ).animate().fadeIn(delay: 120.ms, duration: 300.ms),
          const SizedBox(height: 24),

          // Documentation section
          _sectionLabel('Documentation', isDark),
          const SizedBox(height: 4),
          Text(
            'Upload supporting documents (PDFs, Word docs, etc.)',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.mediumGrey : AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 10),
          // Uploaded docs
          if (_documentation.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_documentation.length, (i) {
                final doc = _documentation[i];
                return _FileChip(
                  name: doc['name'] ?? 'file',
                  type: 'document',
                  isDark: isDark,
                  onRemove: () => _removeDoc(i),
                );
              }),
            ),
          if (_documentation.isNotEmpty) const SizedBox(height: 10),
          _UploadButton(
            label: 'Upload Document',
            icon: Icons.upload_file_rounded,
            color: const Color(0xFF8B5CF6),
            isDark: isDark,
            onTap: _pickDocumentation,
          ).animate().fadeIn(delay: 160.ms, duration: 300.ms),
          const SizedBox(height: 24),

          // Proof section
          _sectionLabel('Proof', isDark),
          const SizedBox(height: 4),
          Text(
            'Upload images, videos, or documents as evidence',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.mediumGrey : AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 10),
          // Uploaded proof previews
          if (_proof.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_proof.length, (i) {
                  final item = _proof[i];
                  final type = item['type'] ?? '';
                  final name = item['name'] ?? 'file';
                  final path = item['path'] ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        if (type == 'image')
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isDark
                                  ? AppColors.darkCard
                                  : AppColors.lightGrey,
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.mediumGrey.withValues(
                                        alpha: 0.3,
                                      ),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: kIsWeb
                                  ? const Icon(
                                      Icons.image_rounded,
                                      color: AppColors.mediumGrey,
                                      size: 30,
                                    )
                                  : Image.file(
                                      File(path),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.image_rounded,
                                        color: AppColors.mediumGrey,
                                        size: 30,
                                      ),
                                    ),
                            ),
                          )
                        else if (type == 'video')
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                              ),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.mediumGrey.withValues(
                                        alpha: 0.3,
                                      ),
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.videocam_rounded,
                                color: Colors.white70,
                                size: 28,
                              ),
                            ),
                          )
                        else
                          _FileChip(
                            name: name,
                            type: 'document',
                            isDark: isDark,
                            onRemove: () => _removeProof(i),
                            showRemove: false,
                          ),
                        // Remove button
                        Positioned(
                          top: -6,
                          right: -6,
                          child: GestureDetector(
                            onTap: () => _removeProof(i),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.charcoal
                                    : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: isDark
                                    ? AppColors.white
                                    : AppColors.charcoal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          if (_proof.isNotEmpty) const SizedBox(height: 10),
          _UploadButton(
            label: 'Add Proof',
            icon: Icons.add_photo_alternate_rounded,
            color: AppColors.deepBlue,
            isDark: isDark,
            onTap: _pickProof,
          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
          const SizedBox(height: 32),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepBlue,
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
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ).animate().fadeIn(delay: 240.ms, duration: 300.ms),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label, bool isDark) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.deepBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.white : AppColors.charcoal,
          ),
        ),
      ],
    );
  }
}

// Reusable upload button
class _UploadButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  const _UploadButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
          color: color.withValues(alpha: isDark ? 0.08 : 0.04),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// File chip widget
class _FileChip extends StatelessWidget {
  final String name;
  final String type;
  final bool isDark;
  final VoidCallback? onRemove;
  final bool showRemove;
  const _FileChip({
    required this.name,
    required this.type,
    required this.isDark,
    this.onRemove,
    this.showRemove = true,
  });

  @override
  Widget build(BuildContext context) {
    final isPdf = name.toLowerCase().endsWith('.pdf');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isDark ? AppColors.darkCard : AppColors.lightGrey,
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.mediumGrey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPdf ? Icons.picture_as_pdf_rounded : Icons.description_rounded,
            color: isPdf ? AppColors.danger : const Color(0xFF8B5CF6),
            size: 18,
          ),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.white : AppColors.charcoal,
              ),
            ),
          ),
          if (showRemove && onRemove != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: AppColors.mediumGrey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Proof option button
class _ProofOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ProofOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.white
                  : AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }
}

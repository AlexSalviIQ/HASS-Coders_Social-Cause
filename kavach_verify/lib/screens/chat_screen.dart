import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/detection_item.dart';

class ChatScreen extends StatefulWidget {
  final String? initialAttachmentPath;
  final String? initialAttachmentType;
  final String? initialAttachmentName;
  const ChatScreen({
    super.key,
    this.initialAttachmentPath,
    this.initialAttachmentType,
    this.initialAttachmentName,
  });
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = List.from(mockChatMessages);
  final ImagePicker _imagePicker = ImagePicker();
  bool _hasText = false;
  bool _isTyping = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      final hasText = _textController.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
    // Handle initial attachment from quick access
    if (widget.initialAttachmentPath != null &&
        widget.initialAttachmentType != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _addAttachment(
          widget.initialAttachmentPath!,
          widget.initialAttachmentType!,
          widget.initialAttachmentName ?? 'file',
        );
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _addAttachment(String path, String type, String name) {
    String emoji;
    switch (type) {
      case 'image':
        emoji = '📷';
        break;
      case 'video':
        emoji = '🎥';
        break;
      case 'document':
        emoji = '📄';
        break;
      case 'govid':
        emoji = '🪪';
        break;
      default:
        emoji = '📎';
    }
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: '$emoji $name',
          isUser: true,
          timestamp: DateTime.now(),
          attachmentPath: path,
          attachmentType: type,
        ),
      );
      _isTyping = true;
    });
    _scrollToBottom();
    _simulateAIResponse(type, name);
  }

  void _simulateAIResponse(String type, String name) {
    final delay = type == 'video' ? 4 : 3;
    Future.delayed(Duration(seconds: delay), () {
      if (!mounted) return;
      String response;
      switch (type) {
        case 'image':
          response =
              '🔍 Analyzing your image...\n\n⚠️ **MANIPULATED IMAGE DETECTED**\nConfidence: 91%\n\n• Error Level Analysis reveals inconsistent compression.\n• Metadata shows editing software.\n• Color histogram anomalies detected.\n\nThis image appears digitally altered.';
          break;
        case 'video':
          response =
              '🔍 Analyzing video content...\n\n⚠️ **DEEPFAKE VIDEO DETECTED**\nConfidence: 93%\n\n• Facial landmark inconsistencies detected.\n• Lip-sync below natural threshold.\n• Temporal artifacts in frames.\n• Audio-visual sync anomalies.';
          break;
        case 'document':
          response =
              '🔍 Analyzing document: $name\n\n⚠️ **FORGED DOCUMENT SUSPECTED**\nConfidence: 89%\n\n• Font mismatch with official templates.\n• Consumer software metadata.\n• Missing digital signatures.\n• Header formatting inconsistencies.';
          break;
        case 'govid':
          response =
              '🔍 Verifying Government ID...\n\n⚠️ **FAKE ID DETECTED**\nConfidence: 87%\n\n• Hologram pattern missing.\n• Font doesn\'t match official standard.\n• QR code data mismatch.\n• Photo shows signs of manipulation.';
          break;
        case 'voice':
          response =
              '🔍 Analyzing voice recording...\n\n⚠️ **AI-GENERATED VOICE DETECTED**\nConfidence: 88%\n\n• Unnatural micro-pauses detected.\n• Spectral analysis shows synthesis patterns.\n• Pitch variation below human norm.\n• Missing natural breathing artifacts.';
          break;
        default:
          response =
              '🔍 Analysis complete.\n\n✅ No strong indicators of manipulation found.';
      }
      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text.trim(),
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _textController.clear();
      _hasText = false;
      _isTyping = true;
    });
    _scrollToBottom();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: _getAIResponse(text),
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    });
  }

  String _getAIResponse(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('http') ||
        lower.contains('www') ||
        lower.contains('.com')) {
      return '🔍 Analyzing the link...\n\n⚠️ **SUSPICIOUS LINK**\nConfidence: 88%\n\nRecently registered domain with no verified ownership. Mimics a legitimate news portal.';
    } else if (lower.contains('free') ||
        lower.contains('win') ||
        lower.contains('prize')) {
      return '🔍 Analyzing...\n\n⚠️ **SCAM ALERT**\nConfidence: 95%\n\nCommon scam pattern offering fake rewards. No legitimate org sends unsolicited prizes.';
    } else if (lower.contains('forward') || lower.contains('share')) {
      return '🔍 Analyzing...\n\n⚠️ **MISINFORMATION**\nConfidence: 87%\n\nViral forward with unverified claims. No credible sources found.';
    }
    return '🔍 Analysis complete.\n\n✅ No strong indicators of fake content. Always verify from multiple credible sources.';
  }

  Future<void> _pickMediaOrVideo() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          Container(
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
                      'Image / Video',
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
                        _AttachOption(
                          icon: Icons.camera_alt_rounded,
                          label: 'Camera',
                          color: const Color(0xFF5B7DB1),
                          onTap: () async {
                            Navigator.pop(ctx);
                            try {
                              final f = await _imagePicker.pickImage(
                                source: ImageSource.camera,
                              );
                              if (f != null)
                                _addAttachment(f.path, 'image', f.name);
                            } catch (e) {
                              _snack('Camera unavailable');
                            }
                          },
                        ),
                        _AttachOption(
                          icon: Icons.photo_library_rounded,
                          label: 'Gallery',
                          color: const Color(0xFF4E8B6E),
                          onTap: () async {
                            Navigator.pop(ctx);
                            try {
                              final f = await _imagePicker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (f != null)
                                _addAttachment(f.path, 'image', f.name);
                            } catch (e) {
                              _snack('Cannot access gallery');
                            }
                          },
                        ),
                        _AttachOption(
                          icon: Icons.videocam_rounded,
                          label: 'Video',
                          color: const Color(0xFFB85C5C),
                          onTap: () async {
                            Navigator.pop(ctx);
                            try {
                              final f = await _imagePicker.pickVideo(
                                source: ImageSource.gallery,
                              );
                              if (f != null)
                                _addAttachment(f.path, 'video', f.name);
                            } catch (e) {
                              _snack('Cannot pick video');
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              )
              .animate()
              .slideY(begin: 0.25, duration: 280.ms, curve: Curves.easeOutCubic)
              .fadeIn(duration: 180.ms),
    );
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'png', 'jpg'],
      );
      if (result != null && result.files.isNotEmpty) {
        _addAttachment(
          result.files.single.path ?? '',
          'document',
          result.files.single.name,
        );
      }
    } catch (_) {
      _snack('Cannot pick document');
    }
  }

  void _toggleVoiceRecording() {
    setState(() {
      if (_isRecording) {
        _isRecording = false;
        // Simulate voice upload
        _addAttachment('voice_recording.aac', 'voice', 'Voice Message');
      } else {
        _isRecording = true;
      }
    });
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showAttachmentMenu() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          Container(
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
                      'Attach Content',
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
                        _AttachOption(
                          icon: Icons.photo_library_rounded,
                          label: 'Image/Video',
                          color: const Color(0xFF5B7DB1),
                          onTap: () {
                            Navigator.pop(ctx);
                            _pickMediaOrVideo();
                          },
                        ),
                        _AttachOption(
                          icon: Icons.description_rounded,
                          label: 'Document',
                          color: const Color(0xFF7B68AE),
                          onTap: () {
                            Navigator.pop(ctx);
                            _pickDocument();
                          },
                        ),
                        _AttachOption(
                          icon: Icons.badge_rounded,
                          label: 'Gov ID',
                          color: const Color(0xFF4E8B6E),
                          onTap: () async {
                            Navigator.pop(ctx);
                            try {
                              final f = await _imagePicker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (f != null)
                                _addAttachment(f.path, 'govid', f.name);
                            } catch (_) {
                              _snack('Cannot pick file');
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              )
              .animate()
              .slideY(begin: 0.25, duration: 280.ms, curve: Curves.easeOutCubic)
              .fadeIn(duration: 180.ms),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length && _isTyping)
                return _TypingIndicator();
              return _ChatBubble(message: _messages[index], index: index);
            },
          ),
        ),
        // Input
        Container(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // +
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: _showAttachmentMenu,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.deepBlue.withValues(
                              alpha: isDark ? 0.25 : 0.07,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: AppColors.deepBlue,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Text field
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCard
                              : AppColors.lightGrey.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: 'Paste text, links, or message...',
                            hintStyle: TextStyle(
                              color: AppColors.mediumGrey,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.white
                                : AppColors.charcoal,
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: _sendMessage,
                          maxLines: 4,
                          minLines: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Mic / Send
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) => ScaleTransition(
                        scale: anim,
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: _hasText
                          ? Material(
                              key: const ValueKey('send'),
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(22),
                                onTap: () => _sendMessage(_textController.text),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.emeraldGreen,
                                        AppColors.emeraldGreenLight,
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            )
                          : GestureDetector(
                              key: const ValueKey('mic'),
                              onLongPress: _toggleVoiceRecording,
                              onLongPressUp: () {
                                if (_isRecording) _toggleVoiceRecording();
                              },
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(22),
                                  onTap: _toggleVoiceRecording,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _isRecording
                                          ? AppColors.danger.withValues(
                                              alpha: 0.15,
                                            )
                                          : AppColors.deepBlue.withValues(
                                              alpha: isDark ? 0.25 : 0.07,
                                            ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _isRecording
                                          ? Icons.stop_rounded
                                          : Icons.mic_rounded,
                                      color: _isRecording
                                          ? AppColors.danger
                                          : AppColors.deepBlue,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            )
            .animate()
            .fadeIn(duration: 250.ms)
            .slideY(begin: 0.08, duration: 250.ms, curve: Curves.easeOutCubic),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final int index;
  const _ChatBubble({required this.message, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.isUser;
    final timeStr =
        '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}';
    final hasAttachment =
        message.attachmentPath != null && message.attachmentPath!.isNotEmpty;
    final isImage =
        message.attachmentType == 'image' || message.attachmentType == 'govid';
    final isDoc = message.attachmentType == 'document';
    final isVideo = message.attachmentType == 'video';
    final isVoice = message.attachmentType == 'voice';

    return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isUser
                  ? AppColors.emeraldGreen
                  : (isDark ? AppColors.darkCard : AppColors.aiBubble),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: (isUser ? AppColors.emeraldGreen : Colors.black)
                      .withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Attachment preview
                if (hasAttachment && isUser && isImage)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: _buildImagePreview(message.attachmentPath!),
                  ),
                if (hasAttachment && isUser && isVideo)
                  _buildVideoPreview(isDark),
                if (hasAttachment && isUser && isDoc)
                  _buildDocPreview(message.text, isDark),
                if (hasAttachment && isUser && isVoice)
                  _buildVoicePreview(isDark),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    12,
                    hasAttachment && isUser && (isImage || isVideo) ? 6 : 10,
                    12,
                    5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isUser)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.deepBlue,
                                      AppColors.deepBlueLight,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Center(
                                  child: Text(
                                    '🛡️',
                                    style: TextStyle(fontSize: 8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'KavachVerify AI',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.deepBlueLight
                                      : AppColors.deepBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (!(hasAttachment && isUser && isDoc))
                        Text(
                          message.text,
                          style: TextStyle(
                            color: isUser
                                ? Colors.white
                                : (isDark
                                      ? AppColors.lightGrey
                                      : AppColors.charcoal),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      const SizedBox(height: 3),
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: isUser
                              ? Colors.white.withValues(alpha: 0.65)
                              : AppColors.mediumGrey,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 250.ms)
        .slideX(
          begin: isUser ? 0.08 : -0.08,
          duration: 250.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildImagePreview(String path) {
    if (kIsWeb) {
      return Container(
        width: double.infinity,
        height: 150,
        color: AppColors.deepBlue.withValues(alpha: 0.1),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_rounded, size: 40, color: AppColors.mediumGrey),
            SizedBox(height: 4),
            Text(
              'Image Preview',
              style: TextStyle(color: AppColors.mediumGrey, fontSize: 11),
            ),
          ],
        ),
      );
    }
    return Image.file(
      File(path),
      width: double.infinity,
      height: 150,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: double.infinity,
        height: 100,
        color: AppColors.deepBlue.withValues(alpha: 0.1),
        child: const Icon(
          Icons.broken_image_rounded,
          color: AppColors.mediumGrey,
          size: 36,
        ),
      ),
    );
  }

  Widget _buildVideoPreview(bool isDark) {
    return Container(
      width: double.infinity,
      height: 120,
      margin: const EdgeInsets.fromLTRB(3, 3, 3, 0),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.videocam_rounded,
            color: Colors.white.withValues(alpha: 0.3),
            size: 40,
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocPreview(String name, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.fromLTRB(3, 3, 3, 0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(13),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF7B68AE).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.description_rounded,
              color: Color(0xFF7B68AE),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'PDF Document',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoicePreview(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.fromLTRB(3, 3, 3, 0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(13),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Waveform bars
                Row(
                  children: List.generate(18, (i) {
                    final h = 6.0 + (i % 5) * 4.0 + (i % 3) * 2.0;
                    return Container(
                      width: 3,
                      height: h,
                      margin: const EdgeInsets.only(right: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 3),
                Text(
                  '0:05',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AttachOption({
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
              color: color.withValues(alpha: 0.1),
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
                  ? AppColors.lightGrey
                  : AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.aiBubble,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(delay: 0),
            const SizedBox(width: 3),
            _Dot(delay: 180),
            const SizedBox(width: 3),
            _Dot(delay: 360),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 180.ms);
  }
}

class _Dot extends StatelessWidget {
  final int delay;
  const _Dot({required this.delay});
  @override
  Widget build(BuildContext context) {
    return Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: AppColors.mediumGrey,
            shape: BoxShape.circle,
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn(delay: Duration(milliseconds: delay))
        .scaleXY(
          begin: 0.5,
          end: 1.0,
          delay: Duration(milliseconds: delay),
          duration: 500.ms,
          curve: Curves.easeInOut,
        );
  }
}

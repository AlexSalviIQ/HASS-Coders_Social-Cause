import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/detection_item.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      final hasText = _textController.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
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

    // Simulate AI response
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

  String _getAIResponse(String userText) {
    final lowerText = userText.toLowerCase();
    if (lowerText.contains('http') ||
        lowerText.contains('www') ||
        lowerText.contains('.com')) {
      return '🔍 Analyzing the link you shared...\n\n⚠️ **SUSPICIOUS LINK DETECTED**\nConfidence: 88%\n\nThis URL leads to a recently registered domain with no verified ownership. The site mimics a legitimate news portal but contains unverified claims. We recommend not sharing this link further.';
    } else if (lowerText.contains('free') ||
        lowerText.contains('win') ||
        lowerText.contains('prize')) {
      return '🔍 Analyzing your text...\n\n⚠️ **SCAM ALERT**\nConfidence: 95%\n\nThis message follows a common scam pattern offering fake rewards. No legitimate organization sends unsolicited prize notifications via messaging apps. Please block and report the sender.';
    } else if (lowerText.contains('forward') ||
        lowerText.contains('whatsapp') ||
        lowerText.contains('share')) {
      return '🔍 Analyzing your message...\n\n⚠️ **MISINFORMATION DETECTED**\nConfidence: 87%\n\nThis appears to be a viral forward with unverified claims. Our cross-reference analysis found no credible sources supporting this information. Such chain messages often contain misleading or false claims.';
    }
    return '🔍 I\'ve analyzed your input.\n\n✅ **ANALYSIS COMPLETE**\n\nI couldn\'t find strong indicators of fake content in this text. However, always verify information from multiple credible sources. Would you like to send me something else to check?';
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        setState(() {
          _messages.add(
            ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: '📷 Image uploaded for verification',
              isUser: true,
              timestamp: DateTime.now(),
              attachmentPath: image.path,
              attachmentType: 'image',
            ),
          );
          _isTyping = true;
        });
        _scrollToBottom();
        // Simulate AI analysis
        Future.delayed(const Duration(seconds: 3), () {
          if (!mounted) return;
          setState(() {
            _isTyping = false;
            _messages.add(
              ChatMessage(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                text:
                    '🔍 Analyzing your image...\n\n⚠️ **MANIPULATED IMAGE DETECTED**\nConfidence: 91%\n\n• Error Level Analysis reveals inconsistent compression.\n• Metadata shows signs of editing software usage.\n• Color histogram anomalies detected in certain regions.\n\nThis image appears to have been digitally altered.',
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );
          });
          _scrollToBottom();
        });
      }
    } catch (e) {
      _showSnackBar('Unable to pick image');
    }
  }

  Future<void> _pickCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );
      if (photo != null) {
        setState(() {
          _messages.add(
            ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: '📸 Photo captured for verification',
              isUser: true,
              timestamp: DateTime.now(),
              attachmentPath: photo.path,
              attachmentType: 'image',
            ),
          );
          _isTyping = true;
        });
        _scrollToBottom();
        Future.delayed(const Duration(seconds: 3), () {
          if (!mounted) return;
          setState(() {
            _isTyping = false;
            _messages.add(
              ChatMessage(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                text:
                    '🔍 Analyzing your photo...\n\n✅ **IMAGE ANALYSIS COMPLETE**\nConfidence: 94%\n\nThis appears to be an authentic, unmodified photograph. No signs of digital manipulation detected.',
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );
          });
          _scrollToBottom();
        });
      }
    } catch (e) {
      _showSnackBar('Unable to access camera');
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'png', 'jpg'],
      );
      if (result != null) {
        final fileName = result.files.single.name;
        setState(() {
          _messages.add(
            ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: '📄 Document uploaded: $fileName',
              isUser: true,
              timestamp: DateTime.now(),
              attachmentPath: result.files.single.path,
              attachmentType: 'document',
            ),
          );
          _isTyping = true;
        });
        _scrollToBottom();
        Future.delayed(const Duration(seconds: 3), () {
          if (!mounted) return;
          setState(() {
            _isTyping = false;
            _messages.add(
              ChatMessage(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                text:
                    '🔍 Analyzing document: $fileName\n\n⚠️ **FORGED DOCUMENT SUSPECTED**\nConfidence: 89%\n\n• Font analysis does not match official templates.\n• Metadata shows creation with consumer software.\n• Digital signatures are missing or invalid.\n• Formatting inconsistencies found in header section.',
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );
          });
          _scrollToBottom();
        });
      }
    } catch (e) {
      _showSnackBar('Unable to pick document');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );
      if (video != null) {
        setState(() {
          _messages.add(
            ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: '🎥 Video uploaded for verification',
              isUser: true,
              timestamp: DateTime.now(),
              attachmentPath: video.path,
              attachmentType: 'video',
            ),
          );
          _isTyping = true;
        });
        _scrollToBottom();
        Future.delayed(const Duration(seconds: 4), () {
          if (!mounted) return;
          setState(() {
            _isTyping = false;
            _messages.add(
              ChatMessage(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                text:
                    '🔍 Analyzing video content...\n\n⚠️ **DEEPFAKE VIDEO DETECTED**\nConfidence: 93%\n\n• Facial landmark inconsistencies detected.\n• Lip-sync accuracy is below natural threshold.\n• Frame-by-frame analysis reveals temporal artifacts.\n• Audio-visual synchronization anomalies found.',
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );
          });
          _scrollToBottom();
        });
      }
    } catch (e) {
      _showSnackBar('Unable to pick video');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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
      builder: (context) =>
          Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.mediumGrey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Attach Content',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.white : AppColors.charcoal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _AttachmentOption(
                          icon: Icons.camera_alt_rounded,
                          label: 'Camera',
                          color: const Color(0xFF667EEA),
                          onTap: () {
                            Navigator.pop(context);
                            _pickCamera();
                          },
                        ),
                        _AttachmentOption(
                          icon: Icons.photo_library_rounded,
                          label: 'Gallery',
                          color: const Color(0xFF43E97B),
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage();
                          },
                        ),
                        _AttachmentOption(
                          icon: Icons.videocam_rounded,
                          label: 'Video',
                          color: const Color(0xFFF5576C),
                          onTap: () {
                            Navigator.pop(context);
                            _pickVideo();
                          },
                        ),
                        _AttachmentOption(
                          icon: Icons.description_rounded,
                          label: 'Document',
                          color: const Color(0xFFF093FB),
                          onTap: () {
                            Navigator.pop(context);
                            _pickDocument();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              )
              .animate()
              .slideY(begin: 0.3, duration: 300.ms, curve: Curves.easeOutCubic)
              .fadeIn(duration: 200.ms),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Chat Messages
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length && _isTyping) {
                return _TypingIndicator();
              }
              final msg = _messages[index];
              return _ChatBubble(message: msg, index: index);
            },
          ),
        ),
        // Input Bar
        Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Attachment Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: _showAttachmentMenu,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.deepBlue.withValues(
                              alpha: isDark ? 0.3 : 0.08,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: AppColors.deepBlue,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Text Field
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCard
                              : AppColors.lightGrey.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: 'Paste text, links, or message...',
                            hintStyle: TextStyle(
                              color: AppColors.mediumGrey,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 14,
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
                    const SizedBox(width: 8),
                    // Mic / Send Button with animated crossfade
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: _hasText
                          ? Material(
                              key: const ValueKey('send'),
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () => _sendMessage(_textController.text),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
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
                                    size: 20,
                                  ),
                                ),
                              ),
                            )
                          : Material(
                              key: const ValueKey('mic'),
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () {
                                  _showSnackBar('Voice recording coming soon');
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.deepBlue.withValues(
                                      alpha: isDark ? 0.3 : 0.08,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.mic_rounded,
                                    color: AppColors.deepBlue,
                                    size: 22,
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
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, duration: 300.ms, curve: Curves.easeOutCubic),
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

    return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            decoration: BoxDecoration(
              color: isUser
                  ? AppColors.emeraldGreen
                  : (isDark ? AppColors.darkCard : AppColors.aiBubble),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 18),
              ),
              boxShadow: [
                BoxShadow(
                  color: (isUser ? AppColors.emeraldGreen : Colors.black)
                      .withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
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
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.deepBlue,
                                AppColors.deepBlueLight,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Center(
                            child: Text('🛡️', style: TextStyle(fontSize: 10)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'KavachVerify AI',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.deepBlueLight
                                : AppColors.deepBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  message.text,
                  style: TextStyle(
                    color: isUser
                        ? Colors.white
                        : (isDark ? AppColors.lightGrey : AppColors.charcoal),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: TextStyle(
                    color: isUser
                        ? Colors.white.withValues(alpha: 0.7)
                        : AppColors.mediumGrey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(
          begin: isUser ? 0.1 : -0.1,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.aiBubble,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TypingDot(delay: 0),
            const SizedBox(width: 4),
            _TypingDot(delay: 200),
            const SizedBox(width: 4),
            _TypingDot(delay: 400),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

class _TypingDot extends StatelessWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.mediumGrey,
            shape: BoxShape.circle,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .fadeIn(delay: Duration(milliseconds: delay))
        .scaleXY(
          begin: 0.6,
          end: 1.0,
          delay: Duration(milliseconds: delay),
          duration: 600.ms,
          curve: Curves.easeInOut,
        );
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
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

import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/detection_item.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

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
  final List<ChatMessage> _messages = [];
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _hasText = false;
  bool _isTyping = false;
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  final List<Map<String, String>> _pendingAttachments = [];

  String get _userId {
    try {
      return Provider.of<AuthProvider>(context, listen: false).userId;
    } catch (_) {
      return '';
    }
  }

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      final hasText = _textController.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
    _loadChatHistory();
    if (widget.initialAttachmentPath != null &&
        widget.initialAttachmentType != null) {
      WidgetsBinding.instance.addPostFrameCallback((v) {
        _stageAttachment(
          widget.initialAttachmentPath!,
          widget.initialAttachmentType!,
          widget.initialAttachmentName ?? 'file',
        );
      });
    }
  }

  Future<void> _loadChatHistory() async {
    if (_userId.isEmpty) return;
    final result = await ApiService.getChatHistory(userId: _userId);
    if (!mounted) return;
    if (result['status'] == 'success') {
      final msgs = (result['messages'] as List?) ?? [];
      setState(() {
        _messages.addAll(msgs.map((m) => ChatMessage.fromJson(m)));
      });
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _recordingTimer?.cancel();
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

  void _stageAttachment(String path, String type, String name) {
    setState(() {
      _pendingAttachments.add({'path': path, 'type': type, 'name': name});
    });
  }

  void _removeAttachment(int index) {
    setState(() {
      _pendingAttachments.removeAt(index);
    });
  }

  void _sendPendingAttachments() {
    if (_pendingAttachments.isEmpty && _textController.text.trim().isEmpty) {
      return;
    }
    final attachments = List<Map<String, String>>.from(_pendingAttachments);
    final text = _textController.text.trim();
    setState(() {
      for (final att in attachments) {
        _messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: att['name'] ?? 'file',
            isUser: true,
            timestamp: DateTime.now(),
            attachmentPath: att['path'],
            attachmentType: att['type'],
          ),
        );
      }
      if (text.isNotEmpty) {
        _messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: text,
            isUser: true,
            timestamp: DateTime.now(),
          ),
        );
      }
      _pendingAttachments.clear();
      _textController.clear();
      _hasText = false;
      _isTyping = true;
    });
    _scrollToBottom();

    // Save user messages to backend
    for (final att in attachments) {
      ApiService.saveChatMessage(
        userId: _userId,
        text: att['name'] ?? 'file',
        isUser: true,
        attachmentPath: att['path'],
        attachmentType: att['type'],
      );
    }
    if (text.isNotEmpty) {
      ApiService.saveChatMessage(userId: _userId, text: text, isUser: true);
    }

    // Call /api/verify for AI analysis
    _callVerifyAPI(
      claimText: text.isNotEmpty ? text : null,
      filePath: attachments.isNotEmpty ? attachments.last['path'] : null,
      attachmentType: attachments.isNotEmpty ? attachments.last['type'] : null,
    );
  }

  Future<void> _callVerifyAPI({
    String? claimText,
    String? filePath,
    String? attachmentType,
  }) async {
    try {
      final result = await ApiService.verify(
        claimText: claimText,
        filePath: filePath,
      );

      if (!mounted) return;

      String response;
      if (result['status'] == 'success') {
        response = result['message'] ?? 'Analysis complete.';

        // Save detection to backend
        final category = attachmentType ?? 'text';
        final isFake =
            (result['category'] ?? '').toString().toUpperCase() == 'FAKE';
        final confidence = isFake ? 0.9 : 0.1;

        if (_userId.isNotEmpty) {
          ApiService.createDetection(
            userId: _userId,
            title: claimText ?? 'Media Verification',
            description: response.length > 200
                ? response.substring(0, 200)
                : response,
            category: category,
            confidenceScore: confidence,
            analysisDetails: response,
            isFake: isFake,
          );
        }
      } else {
        response = result['message'] ?? 'Analysis failed. Please try again.';
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

      // Save AI response to backend
      ApiService.saveChatMessage(
        userId: _userId,
        text: response,
        isUser: false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: '❌ Could not reach the server. Please check your connection.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    }
  }

  void _sendMessage(String text) {
    _sendPendingAttachments();
  }

  Future<void> _pickMediaOrVideo() async {
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
                  color: AppColors.deepBlue,
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final f = await _imagePicker.pickImage(
                        source: ImageSource.camera,
                        requestFullMetadata: false,
                      );
                      if (f != null) {
                        _stageAttachment(f.path, 'image', f.name);
                      }
                    } catch (e) {
                      _snack('Camera unavailable');
                    }
                  },
                ),
                _AttachOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: AppColors.emeraldGreen,
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final f = await _imagePicker.pickImage(
                        source: ImageSource.gallery,
                        requestFullMetadata: false,
                      );
                      if (f != null) {
                        _stageAttachment(f.path, 'image', f.name);
                      }
                    } catch (e) {
                      _snack('Cannot access gallery');
                    }
                  },
                ),
                _AttachOption(
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
                        _stageAttachment(f.path, 'video', f.name);
                      }
                    } catch (e) {
                      _snack('Cannot pick video');
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

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'png', 'jpg'],
      );
      if (result != null && result.files.isNotEmpty) {
        _stageAttachment(
          result.files.single.path ?? '',
          'document',
          result.files.single.name,
        );
      }
    } catch (e) {
      _snack('Cannot pick document');
    }
  }

  Future<void> _toggleVoiceRecording() async {
    if (_isRecording) {
      // Stop recording
      _recordingTimer?.cancel();
      try {
        final path = await _audioRecorder.stop();
        if (path != null && mounted) {
          setState(() {
            _isRecording = false;
          });
          _stageAttachment(
            path,
            'voice',
            'Voice Message (${_recordingSeconds}s)',
          );
        } else {
          setState(() => _isRecording = false);
        }
      } catch (e) {
        setState(() => _isRecording = false);
        _snack('Recording failed');
      }
    } else {
      // Start recording
      try {
        if (await _audioRecorder.hasPermission()) {
          RecordConfig config;
          String filePath;
          if (kIsWeb) {
            // Web browsers support opus in webm container
            config = const RecordConfig(
              encoder: AudioEncoder.opus,
              numChannels: 1,
            );
            filePath = '';
          } else {
            // Mobile supports AAC
            config = const RecordConfig(
              encoder: AudioEncoder.aacLc,
              sampleRate: 44100,
            );
            final dir = await getTemporaryDirectory();
            filePath =
                '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
          }
          await _audioRecorder.start(config, path: filePath);
          setState(() {
            _isRecording = true;
            _recordingSeconds = 0;
          });
          _recordingTimer = Timer.periodic(const Duration(seconds: 1), (t) {
            if (mounted) {
              setState(() => _recordingSeconds++);
            }
          });
        } else {
          _snack('Microphone permission denied');
        }
      } catch (e) {
        _snack('Cannot start recording: $e');
      }
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
                          color: AppColors.deepBlue,
                          onTap: () {
                            Navigator.pop(ctx);
                            _pickMediaOrVideo();
                          },
                        ),
                        _AttachOption(
                          icon: Icons.description_rounded,
                          label: 'Document',
                          color: const Color(0xFF8B5CF6),
                          onTap: () {
                            Navigator.pop(ctx);
                            _pickDocument();
                          },
                        ),
                        _AttachOption(
                          icon: Icons.badge_rounded,
                          label: 'Gov ID',
                          color: AppColors.emeraldGreen,
                          onTap: () async {
                            Navigator.pop(ctx);
                            try {
                              final f = await _imagePicker.pickImage(
                                source: ImageSource.gallery,
                                requestFullMetadata: false,
                              );
                              if (f != null) {
                                _stageAttachment(f.path, 'govid', f.name);
                              }
                            } catch (e) {
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
              if (index == _messages.length && _isTyping) {
                return const _TypingIndicator();
              }
              return _ChatBubble(
                message: _messages[index],
                index: index,
                audioPlayer: _audioPlayer,
              );
            },
          ),
        ),
        // Recording indicator
        if (_isRecording)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.danger.withValues(alpha: 0.1),
            child: Row(
              children: [
                Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(duration: 500.ms),
                const SizedBox(width: 10),
                Text(
                  'Recording... ${_recordingSeconds}s',
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  'Tap mic to stop',
                  style: TextStyle(
                    color: AppColors.danger.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        // Staged attachments preview strip (ChatGPT/Gemini style)
        if (_pendingAttachments.isNotEmpty)
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightGrey,
                  width: 1,
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_pendingAttachments.length, (i) {
                  final att = _pendingAttachments[i];
                  final type = att['type'] ?? '';
                  final name = att['name'] ?? 'file';
                  final path = att['path'] ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Preview content
                        if (type == 'image' || type == 'govid')
                          Container(
                            width: 64,
                            height: 64,
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
                                  ? Icon(
                                      Icons.image_rounded,
                                      color: AppColors.mediumGrey,
                                      size: 28,
                                    )
                                  : Image.file(
                                      File(path),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Icon(
                                        Icons.image_rounded,
                                        color: AppColors.mediumGrey,
                                        size: 28,
                                      ),
                                    ),
                            ),
                          )
                        else if (type == 'video')
                          Container(
                            width: 64,
                            height: 64,
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
                                size: 26,
                              ),
                            ),
                          )
                        else if (type == 'voice')
                          Container(
                            height: 64,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.mic_rounded,
                                  color: AppColors.danger,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 100,
                                  ),
                                  child: Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppColors.white
                                          : AppColors.charcoal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          // Document chip
                          Container(
                            height: 64,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  name.toLowerCase().endsWith('.pdf')
                                      ? Icons.picture_as_pdf_rounded
                                      : Icons.description_rounded,
                                  color: name.toLowerCase().endsWith('.pdf')
                                      ? AppColors.danger
                                      : const Color(0xFF8B5CF6),
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 100,
                                  ),
                                  child: Text(
                                    name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.white
                                          : AppColors.charcoal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Remove button
                        Positioned(
                          top: -6,
                          right: -6,
                          child: GestureDetector(
                            onTap: () => _removeAttachment(i),
                            child: Container(
                              width: 20,
                              height: 20,
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
                                size: 13,
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
          ),
        // Input bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.white,
            border: Border(
              top: BorderSide(
                color: isDark
                    ? AppColors.darkBorder
                    : Colors.black.withValues(alpha: 0.08),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // Attach button – subtle, no colored background
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _showAttachmentMenu,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.add_rounded,
                        color: isDark
                            ? AppColors.mediumGrey
                            : AppColors.darkGrey,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Text field – the only visible rounded container
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkCard
                          : const Color(0xFFF0F1F3),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : const Color(0xFFDCDFE3),
                        width: 0.5,
                      ),
                    ),
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        hintStyle: TextStyle(
                          color: AppColors.mediumGrey,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.white : AppColors.charcoal,
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      maxLines: 4,
                      minLines: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Send / Mic button – clean, professional
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: anim,
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: (_hasText || _pendingAttachments.isNotEmpty)
                      ? Material(
                          key: const ValueKey('send'),
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _sendMessage(_textController.text),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.deepBlue
                                    : AppColors.deepBlueDark,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_upward_rounded,
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
                            borderRadius: BorderRadius.circular(20),
                            onTap: _toggleVoiceRecording,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                _isRecording
                                    ? Icons.stop_rounded
                                    : Icons.mic_none_rounded,
                                color: _isRecording
                                    ? AppColors.danger
                                    : (isDark
                                          ? AppColors.mediumGrey
                                          : AppColors.darkGrey),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatBubble extends StatefulWidget {
  final ChatMessage message;
  final int index;
  final AudioPlayer audioPlayer;
  const _ChatBubble({
    required this.message,
    required this.index,
    required this.audioPlayer,
  });

  @override
  State<_ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<_ChatBubble> {
  bool _isPlaying = false;
  bool _isSpeaking = false;
  static FlutterTts? _flutterTts;
  static String? _currentSpeakingId;

  FlutterTts get tts {
    _flutterTts ??= FlutterTts();
    return _flutterTts!;
  }

  @override
  void initState() {
    super.initState();
    widget.audioPlayer.onPlayerComplete.listen((v) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  /// Detect if text contains Devanagari characters (Hindi/Marathi)
  bool _isDevanagari(String text) {
    return RegExp(r'[\u0900-\u097F]').hasMatch(text);
  }

  Future<void> _speakText(String text) async {
    if (_isSpeaking && _currentSpeakingId == message.id) {
      // Stop speaking
      await tts.stop();
      if (mounted) {
        setState(() => _isSpeaking = false);
      }
      _currentSpeakingId = null;
      return;
    }

    // Stop any other bubble that's speaking
    await tts.stop();
    _currentSpeakingId = message.id;

    // Set language based on text content
    if (_isDevanagari(text)) {
      await tts.setLanguage('hi-IN');
    } else {
      await tts.setLanguage('en-IN');
    }

    await tts.setSpeechRate(0.45);
    await tts.setVolume(1.0);
    await tts.setPitch(1.0);

    tts.setCompletionHandler(() {
      if (mounted) {
        setState(() => _isSpeaking = false);
      }
      _currentSpeakingId = null;
    });

    // Strip markdown-style formatting and emojis for cleaner speech
    final cleanText = text
        .replaceAll(RegExp(r'\*\*'), '')
        .replaceAll(RegExp(r'[•\n]+'), '. ')
        .replaceAll(
          RegExp(
            r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{FE00}-\u{FE0F}]|[\u{1F900}-\u{1F9FF}]|[\u{1FA00}-\u{1FA6F}]|[\u{1FA70}-\u{1FAFF}]|[\u{200D}]|[\u{20E3}]|[\u{E0020}-\u{E007F}]',
            unicode: true,
          ),
          '',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (mounted) {
      setState(() => _isSpeaking = true);
    }
    await tts.speak(cleanText);
  }

  ChatMessage get message => widget.message;
  int get index => widget.index;
  AudioPlayer get audioPlayer => widget.audioPlayer;

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

    // Professional bubble colors
    final bubbleColor = (isUser && hasAttachment && isImage)
        ? (isDark ? AppColors.darkCard : const Color(0xFFF0F0F0))
        : isUser
        ? (isDark ? const Color(0xFF1E3A5F) : const Color(0xFF1B3A5C))
        : (isDark ? AppColors.darkCard : const Color(0xFFF0F2F5));

    // Text color: white on user bubble, standard otherwise
    final textColor = (isUser && !(hasAttachment && isImage))
        ? Colors.white
        : (isDark ? AppColors.white : AppColors.charcoal);

    final timeColor = (isUser && !(hasAttachment && isImage))
        ? Colors.white.withValues(alpha: 0.55)
        : AppColors.mediumGrey;

    return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // IMAGE preview — bigger, no green, tap to fullscreen
                if (hasAttachment && isUser && isImage)
                  GestureDetector(
                    onTap: () =>
                        _openImageViewer(context, message.attachmentPath!),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: _buildImagePreview(message.attachmentPath!),
                    ),
                  ),
                // VIDEO preview — tappable like images
                if (hasAttachment && isUser && isVideo)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => _FullScreenVideoViewer(
                            path: message.attachmentPath!,
                          ),
                        ),
                      );
                    },
                    child: _buildVideoPreview(isDark),
                  ),
                // DOC preview — WhatsApp style
                if (hasAttachment && isUser && isDoc)
                  GestureDetector(
                    onTap: () =>
                        _openDocument(context, message.attachmentPath!),
                    child: _buildDocPreview(message.text, isDark),
                  ),
                // VOICE preview — playable
                if (hasAttachment && isUser && isVoice)
                  _buildVoicePreview(context, isDark),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.asset(
                                      'assets/images/kavach_logo.png',
                                      width: 16,
                                      height: 16,
                                      fit: BoxFit.cover,
                                      alignment: const Alignment(0, -0.15),
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
                              GestureDetector(
                                onTap: () => _speakText(message.text),
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color:
                                        (_isSpeaking &&
                                            _currentSpeakingId == message.id)
                                        ? AppColors.deepBlue.withValues(
                                            alpha: 0.15,
                                          )
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Icon(
                                    (_isSpeaking &&
                                            _currentSpeakingId == message.id)
                                        ? Icons.volume_up_rounded
                                        : Icons.volume_up_outlined,
                                    size: 16,
                                    color: isDark
                                        ? AppColors.deepBlueLight
                                        : AppColors.deepBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Hide filename text for image/doc/voice attachments
                      if (!(hasAttachment &&
                          isUser &&
                          (isImage || isDoc || isVoice)))
                        Text(
                          message.text,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      const SizedBox(height: 3),
                      Text(
                        timeStr,
                        style: TextStyle(color: timeColor, fontSize: 9),
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

  void _openImageViewer(BuildContext context, String path) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => _FullScreenImageViewer(path: path)),
    );
  }

  void _openDocument(BuildContext context, String path) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Document received for analysis'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    try {
      // Use open_filex to open on mobile
      // ignore: depend_on_referenced_packages
      await _openFileNative(path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cannot open document'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _openFileNative(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await OpenFilex.open(path);
      }
    } catch (e) {
      // File cannot be opened
    }
  }

  Widget _buildImagePreview(String path) {
    if (kIsWeb) {
      return Container(
        width: double.infinity,
        height: 240,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.deepBlue.withValues(alpha: 0.15),
              AppColors.deepBlueLight.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_rounded,
              size: 48,
              color: AppColors.deepBlueLight.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap to view',
              style: TextStyle(color: AppColors.mediumGrey, fontSize: 11),
            ),
          ],
        ),
      );
    }
    return Image.file(
      File(path),
      width: double.infinity,
      height: 240,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.deepBlue.withValues(alpha: 0.1),
        ),
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
      height: 160,
      margin: const EdgeInsets.fromLTRB(3, 3, 3, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.videocam_rounded,
            color: Colors.white.withValues(alpha: 0.15),
            size: 60,
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          Positioned(
            bottom: 8,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'VIDEO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocPreview(String name, bool isDark) {
    final isPdf = name.toLowerCase().contains('.pdf');
    final ext = name.split('.').last.toUpperCase();
    // Simulate file info like WhatsApp
    final fileSize = '${(100 + name.length * 7) ~/ 1} KB';
    final pageCount = isPdf ? '${2 + name.length % 5} pages' : '1 page';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.fromLTRB(3, 3, 3, 0),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF1E3A24) : const Color(0xFFE8F5E9)),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(13),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 52,
            decoration: BoxDecoration(
              color: (isPdf ? AppColors.danger : const Color(0xFF8B5CF6))
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPdf
                      ? Icons.picture_as_pdf_rounded
                      : Icons.description_rounded,
                  color: isPdf ? AppColors.danger : const Color(0xFF8B5CF6),
                  size: 22,
                ),
                const SizedBox(height: 2),
                Text(
                  ext.length > 4 ? ext.substring(0, 4) : ext,
                  style: TextStyle(
                    color: isPdf ? AppColors.danger : const Color(0xFF8B5CF6),
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.charcoal,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$pageCount • $fileSize • $ext',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppColors.darkGrey,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 11,
                      color: isDark
                          ? AppColors.emeraldGreenLight
                          : AppColors.emeraldGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      kIsWeb ? 'Document received' : 'Tap to open',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.emeraldGreenLight
                            : AppColors.emeraldGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoicePreview(BuildContext context, bool isDark) {
    final path = message.attachmentPath ?? '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          GestureDetector(
            onTap: () => _toggleVoice(context, path),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Waveform bars
                Row(
                  children: List.generate(22, (i) {
                    // Hash-based unique waveform per message
                    final seed =
                        message.text.hashCode ^
                        (message.attachmentPath?.hashCode ?? 0);
                    final rng = (seed + i * 7 + i * i * 3) & 0xFFFF;
                    final h = 4.0 + (rng % 18) * 1.2;
                    return Container(
                      width: 2.5,
                      height: h,
                      margin: const EdgeInsets.only(right: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: _isPlaying ? 0.9 : 0.6,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      message.text,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 9,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.mic_rounded,
                      size: 10,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _isPlaying ? 'Playing...' : 'Tap ▶ to play',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleVoice(BuildContext context, String path) async {
    try {
      if (path.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No recording to play'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }
      if (_isPlaying) {
        await audioPlayer.pause();
        if (mounted) setState(() => _isPlaying = false);
      } else {
        await audioPlayer.stop();
        if (kIsWeb) {
          await audioPlayer.play(UrlSource(path));
        } else {
          await audioPlayer.play(DeviceFileSource(path));
        }
        if (mounted) setState(() => _isPlaying = true);
      }
    } catch (e) {
      if (mounted) setState(() => _isPlaying = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playback error: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}

// Fullscreen image viewer
class _FullScreenImageViewer extends StatelessWidget {
  final String path;
  const _FullScreenImageViewer({required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Image Preview', style: TextStyle(fontSize: 16)),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: kIsWeb
              ? Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_rounded,
                        size: 64,
                        color: AppColors.mediumGrey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Image Preview',
                        style: TextStyle(color: AppColors.mediumGrey),
                      ),
                    ],
                  ),
                )
              : Image.file(
                  File(path),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image_rounded,
                    color: AppColors.mediumGrey,
                    size: 64,
                  ),
                ),
        ),
      ),
    );
  }
}

// Fullscreen video viewer
class _FullScreenVideoViewer extends StatefulWidget {
  final String path;
  const _FullScreenVideoViewer({required this.path});
  @override
  State<_FullScreenVideoViewer> createState() => _FullScreenVideoViewerState();
}

class _FullScreenVideoViewerState extends State<_FullScreenVideoViewer> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      if (kIsWeb) {
        setState(() => _error = 'Video playback not supported on web preview');
        return;
      }
      _controller = VideoPlayerController.file(File(widget.path));
      await _controller!.initialize();
      if (mounted) {
        setState(() => _initialized = true);
        _controller!.play();
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Cannot play video');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Video Preview', style: TextStyle(fontSize: 16)),
      ),
      body: Center(
        child: _error != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.videocam_off_rounded,
                    color: AppColors.mediumGrey,
                    size: 64,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(color: AppColors.mediumGrey),
                  ),
                ],
              )
            : !_initialized
            ? const CircularProgressIndicator(color: Colors.white)
            : GestureDetector(
                onTap: () {
                  setState(() {
                    if (_controller!.value.isPlaying) {
                      _controller!.pause();
                    } else {
                      _controller!.play();
                    }
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    ),
                    if (!_controller!.value.isPlaying)
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              ),
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

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();
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
          decoration: BoxDecoration(
            color: AppColors.deepBlueLight,
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

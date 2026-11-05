import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/channels.dart';
import '../../auth/providers/auth_provider.dart';
import '../../feed/providers/feed_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late String _selectedChannelId;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedChannelId = ref.read(selectedChannelIdProvider);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handlePostSubmit() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a post title.';
      });
      return;
    }

    if (content.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter discussion content.';
      });
      return;
    }

    final author = ref.read(currentUserProvider);
    if (author == null) {
      setState(() {
        _errorMessage = 'Authentication required. Please sign in with your work email.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(feedRepositoryProvider);
      final newPost = await repo.createPost(
        channelId: _selectedChannelId,
        title: title,
        content: content,
        author: author,
      );

      // Add to local state
      await ref.read(postsProvider.notifier).addPost(newPost);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your anonymous post is live on Majlis!')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to submit post: $e';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final channelsAsync = ref.watch(channelsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Anonymous Post'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton(
              onPressed: _isSubmitting ? null : _handlePostSubmit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.uaeEmerald),
                    )
                  : const Text(
                      'POST',
                      style: TextStyle(
                        color: AppColors.uaeEmerald,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Author Identity Preview
            if (currentUser != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: currentUser.company.brandColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Posting Anonymously As:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            currentUser.badgeLabel,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.shield_outlined, size: 18, color: AppColors.uaeEmerald),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Channel Selector
            const Text(
              'Select Channel',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),

            channelsAsync.when(
              data: (channels) => DropdownButtonFormField<String>(
                initialValue: _selectedChannelId,
                dropdownColor: AppColors.surfaceElevated,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: channels.map((c) {
                  String label = c.name;
                  if (c.id == AppChannelIds.companyLounge && currentUser != null) {
                    label = '🏢 ${currentUser.company.name} Lounge (Private)';
                  }
                  return DropdownMenuItem(
                    value: c.id,
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedChannelId = val;
                    });
                  }
                },
              ),
              loading: () => const SizedBox(height: 48),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            // Post Title
            const Text(
              'Title',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'e.g. Compensation packages and Golden Visa experience',
              ),
            ),
            const SizedBox(height: 20),

            // Post Content
            const Text(
              'Discussion Content',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 8,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.5),
              decoration: const InputDecoration(
                hintText: 'Share your authentic thoughts, industry questions, or workplace insights...',
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ],

            const SizedBox(height: 24),

            // Community Guidelines
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Majlis Zero-PII Policy: Do not mention real personal names, private phone numbers, or confidential proprietary trade secrets.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
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

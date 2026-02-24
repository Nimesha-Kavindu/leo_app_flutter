import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _selectedImages = [];
  bool _isPosting = false;
  String? _username;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final token = await StorageService.getToken();
    if (token == null) return;
    try {
      final data = await ApiService.getProfile(token);
      final user = data['user'] as Map<String, dynamic>?;
      if (user != null && mounted) {
        setState(() {
          _username = user['username'] as String?;
          _avatarUrl = user['avatarUrl'] as String?;
        });
      }
    } catch (_) {
      // Non-critical
    }
  }

  Future<void> _handlePost() async {
    final caption = _textController.text.trim();
    if (caption.isEmpty && _selectedImages.isEmpty) return;

    setState(() => _isPosting = true);

    try {
      final token = await StorageService.getToken();
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Not authenticated')),
          );
        }
        return;
      }

      // If multiple images selected, use first one (single image per post for now)
      final imageUrl =
          _selectedImages.isNotEmpty ? _selectedImages.first : null;

      await ApiService.createPost(
        token,
        imageUrl: imageUrl,
        caption: caption.isNotEmpty ? caption : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _MockMediaPicker(
        onImagesSelected: (images) {
          setState(() {
            // Add new images up to 4 total
            final remainingSlots = 4 - _selectedImages.length;
            final imagesToAdd = images.take(remainingSlots);
            _selectedImages.addAll(imagesToAdd);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Create Post',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(PhosphorIcons.x()),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: FilledButton(
              onPressed: (_textController.text.isNotEmpty ||
                          _selectedImages.isNotEmpty) &&
                      !_isPosting
                  ? _handlePost
                  : null,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isPosting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Post'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: _avatarUrl != null
                      ? NetworkImage(_avatarUrl!) as ImageProvider
                      : null,
                  child: _avatarUrl == null ? Icon(PhosphorIcons.user()) : null,
                ),
                const SizedBox(width: 12),
                Text(
                  _username ?? 'You',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Text Input
            TextField(
              controller: _textController,
              autofocus: true,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 18),
              onChanged: (val) => setState(() {}),
            ),

            const SizedBox(height: 16),

            // Image Grid
            if (_selectedImages.isNotEmpty) _buildImageGrid(),
          ],
        ),
      ),
      bottomSheet: Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            IconButton(
              onPressed: _selectedImages.length < 4 ? _showMediaPicker : null,
              icon: Icon(
                PhosphorIcons.image(),
                color: _selectedImages.length < 4
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                PhosphorIcons.videoCamera(),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                PhosphorIcons.mapPin(),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    int count = _selectedImages.length;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 300,
        child: Builder(
          builder: (context) {
            if (count == 1) {
              return _buildImageItem(0, BoxFit.cover);
            } else if (count == 2) {
              return Row(
                children: [
                  Expanded(child: _buildImageItem(0, BoxFit.cover)),
                  const SizedBox(width: 2),
                  Expanded(child: _buildImageItem(1, BoxFit.cover)),
                ],
              );
            } else if (count == 3) {
              return Row(
                children: [
                  Expanded(child: _buildImageItem(0, BoxFit.cover)),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(child: _buildImageItem(1, BoxFit.cover)),
                        const SizedBox(height: 2),
                        Expanded(child: _buildImageItem(2, BoxFit.cover)),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _buildImageItem(0, BoxFit.cover)),
                        const SizedBox(width: 2),
                        Expanded(child: _buildImageItem(1, BoxFit.cover)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _buildImageItem(2, BoxFit.cover)),
                        const SizedBox(width: 2),
                        Expanded(child: _buildImageItem(3, BoxFit.cover)),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildImageItem(int index, BoxFit fit) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(imageUrl: _selectedImages[index], fit: fit),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedImages.removeAt(index);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Icon(PhosphorIcons.x(), color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _MockMediaPicker extends StatefulWidget {
  final Function(List<String>) onImagesSelected;

  const _MockMediaPicker({required this.onImagesSelected});

  @override
  State<_MockMediaPicker> createState() => _MockMediaPickerState();
}

class _MockMediaPickerState extends State<_MockMediaPicker> {
  final List<String> _mockImages = List.generate(
    20,
    (index) => 'https://picsum.photos/seed/post_mock_$index/400',
  );
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gallery',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                TextButton(
                  onPressed: _selected.isNotEmpty
                      ? () {
                          widget.onImagesSelected(_selected.toList());
                          Navigator.pop(context);
                        }
                      : null,
                  child: Text('Add (${_selected.length})'),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: _mockImages.length,
              itemBuilder: (context, index) {
                final url = _mockImages[index];
                final isSelected = _selected.contains(url);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selected.remove(url);
                      } else {
                        if (_selected.length < 4) {
                          _selected.add(url);
                        }
                      }
                    });
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
                      if (isSelected)
                        Container(
                          color: Colors.black45,
                          child: const Center(
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.blue,
                              size: 32,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

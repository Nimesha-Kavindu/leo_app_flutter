import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../screens/home/home_screen.dart';
import '../screens/clubs/clubs_screen.dart';
import '../screens/post/create_post_screen.dart';
import '../screens/profile/user_profile_screen.dart';
import '../screens/messages/messages_screen.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final token = await StorageService.getToken();
    if (token == null) return;
    try {
      final data = await ApiService.getProfile(token);
      final user = data['user'] as Map<String, dynamic>?;
      final url = user?['avatarUrl'] as String?;
      if (url != null && url.isNotEmpty && mounted) {
        setState(() => _avatarUrl = url);
      }
    } catch (_) {
      // Non-critical — nav bar just shows icon instead of avatar
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pages for the Bottom Nav
    final pages = [
      const HomeScreen(), // 0: Home (Feed/Explore/Events)
      const ClubsScreen(), // 1: Clubs
      const SizedBox.shrink(), // 2: Create Post (Handled by FAB)
      const MessagesScreen(), // 3: Messages
      const UserProfileScreen(), // 4: Profile
    ];

    return Scaffold(
      extendBody: true, // Crucial for floating/glass bottom bar
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: _buildCustomBottomBar(context),
    );
  }

  Widget _buildCustomBottomBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, PhosphorIcons.house(), 'Home'),
                _buildNavItem(1, PhosphorIcons.usersThree(), 'Clubs'),
                // Central FAB - Create Post
                _buildCreatePostFab(context),
                _buildNavItem(3, PhosphorIcons.chatCircle(), 'Messages'),
                _buildNavItem(
                  4,
                  PhosphorIcons.user(),
                  'Profile',
                  imageUrl: _avatarUrl,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label, {
    String? imageUrl,
  }) {
    final isSelected = _selectedIndex == index;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imageUrl != null)
            Container(
              padding: isSelected ? const EdgeInsets.all(2) : EdgeInsets.zero,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )
                    : null,
              ),
              child: CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(imageUrl),
              ),
            )
          else
            Icon(
              icon,
              color: color,
              weight: isSelected ? 800 : 400, // Simulate bold icon
            ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePostFab(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle Create Post Action
        Navigator.of(
          context,
          rootNavigator: true,
        ).push(MaterialPageRoute(builder: (c) => const CreatePostScreen()));
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.5),
              Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.1),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          PhosphorIcons.plus(),
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

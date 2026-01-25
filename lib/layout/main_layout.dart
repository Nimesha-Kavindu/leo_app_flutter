import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/user.dart';
import '../screens/home/home_screen.dart';
import '../screens/clubs/clubs_screen.dart';
import '../screens/profile/user_profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Pages for the Bottom Nav
    final pages = [
      const HomeScreen(), // 0: Home (Feed/Explore/Events)
      const ClubsScreen(), // 1: Clubs
      const SizedBox.shrink(), // 2: Create Post (Handled by FAB)
      const PlaceholderScreen(title: 'Messages'), // 3: Messages
      UserProfileScreen(user: currentUser), // 4: Profile
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
                  imageUrl: currentUser.avatarUrl,
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
        showModalBottomSheet(
          context: context,
          builder: (c) => Container(
            height: 200,
            color: Colors.white,
            child: Center(child: Text("Create Post")),
          ),
        );
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

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text("$title Screen")),
    );
  }
}

// Extension to split Row children easily if needed, but here we just used list literal
extension ListExtension<T> on List<T> {
  // Helper not strictly needed if we construct list directly
}

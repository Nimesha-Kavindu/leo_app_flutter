import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../models/event.dart';
import '../../models/post.dart';
import '../../models/user.dart';
import '../../widgets/event_card.dart';
import '../../widgets/post_card.dart';
import '../profile/user_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110), // Height for Title + Tabs
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.85),
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: Text(
                      'LeoConnect',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(
                          PhosphorIcons.magnifyingGlass(),
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(
                          PhosphorIcons.bell(),
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onPressed: () {},
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16, left: 8),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    UserProfileScreen(user: currentUser),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(
                              currentUser.avatarUrl ?? '',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant,
                    labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'Feed'),
                      Tab(text: 'Explore'),
                      Tab(text: 'Events'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFeedTab(), _buildExploreTab(), _buildEventsTab()],
      ),
    );
  }

  Widget _buildFeedTab() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 120, bottom: 20),
      itemCount: mockPosts.length,
      itemBuilder: (context, index) {
        return PostCard(
          post: mockPosts[index],
          onLike: () {},
          onComment: () {},
          onShare: () {},
          onUserClick: () => _navigateToProfile(mockPosts[index].author),
        );
      },
    );
  }

  Widget _buildExploreTab() {
    final explorePosts = [...mockPosts.reversed, ...mockPosts];
    return ListView.builder(
      padding: const EdgeInsets.only(top: 120, bottom: 20),
      itemCount: explorePosts.length,
      itemBuilder: (context, index) {
        return PostCard(
          post: explorePosts[index],
          onLike: () {},
          onUserClick: () => _navigateToProfile(explorePosts[index].author),
        );
      },
    );
  }

  Widget _buildEventsTab() {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(top: 120, bottom: 80),
          itemCount: mockEvents.length,
          itemBuilder: (context, index) {
            return EventCard(event: mockEvents[index], onRSVP: () {});
          },
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            onPressed: () {},
            child: Icon(PhosphorIcons.plus()),
          ),
        ),
      ],
    );
  }

  void _navigateToProfile(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserProfileScreen(user: user)),
    );
  }
}

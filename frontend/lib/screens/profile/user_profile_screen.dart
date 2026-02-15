import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../models/user.dart';
import '../../models/post.dart';

class UserProfileScreen extends StatefulWidget {
  final User user;

  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildAppBar(context),
              SliverToBoxAdapter(child: _buildProfileHeader(context)),
              // Persistent Tab Bar
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Theme.of(context).colorScheme.onSurface,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Theme.of(context).colorScheme.onSurface,
                    unselectedLabelColor: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    tabs: [
                      Tab(icon: Icon(PhosphorIcons.gridFour())),
                      Tab(icon: Icon(PhosphorIcons.userSquare())),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [_buildPostsGrid(), _buildTaggedGrid()],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIcons.lockKey(), size: 16),
          const SizedBox(width: 8),
          Text(
            widget.user.id, // Assuming 'id' is username-like, or use name logic
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          Icon(PhosphorIcons.caretDown(), size: 14),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(PhosphorIcons.plusSquare(), size: 28),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(PhosphorIcons.list(), size: 28), // Hamburger menu
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Profile Picture
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                padding: const EdgeInsets.all(3),
                child: CircleAvatar(
                  radius: 38,
                  backgroundImage: NetworkImage(widget.user.avatarUrl ?? ''),
                ),
              ),
              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStat('${widget.user.posts}', 'Posts'),
                    _buildStat('${widget.user.followers}', 'Followers'),
                    _buildStat('${widget.user.following}', 'Following'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Name & Bio
          Text(
            widget.user.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          if (widget.user.bio != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                widget.user.bio!,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          // Mock Link
          if (widget.user.leoId != null)
            Text(
              'Leo ID: ${widget.user.leoId}',
              style: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          const SizedBox(height: 16),
          // Buttons
          Row(
            children: [
              Expanded(child: _buildActionButton(context, 'Edit profile')),
              const SizedBox(width: 6),
              Expanded(child: _buildActionButton(context, 'Share profile')),
              const SizedBox(width: 6),
              Container(
                height: 32,
                width: 34,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(PhosphorIcons.userPlus(), size: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Highlights (Mock)
          SizedBox(
            height: 85,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        color: Colors.grey.shade100,
                      ),
                      child: Icon(
                        PhosphorIcons.plus(),
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('New', style: TextStyle(fontSize: 11)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label) {
    return Container(
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildPostsGrid() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: 30, // Mock items
      itemBuilder: (context, index) {
        // Reuse mock post images cyclically
        final post = mockPosts[index % mockPosts.length];
        return CachedNetworkImage(
          imageUrl: post.imageUrl ?? 'https://picsum.photos/200',
          fit: BoxFit.cover,
        );
      },
    );
  }

  Widget _buildTaggedGrid() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Icon(PhosphorIcons.userSquare(), size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'Photos and videos of you',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Text(
            'When people tag you in photos and videos,\nthey\'ll appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../models/club.dart';
import '../../models/post.dart';

class ClubProfileScreen extends StatefulWidget {
  final Club club;

  const ClubProfileScreen({super.key, required this.club});

  @override
  State<ClubProfileScreen> createState() => _ClubProfileScreenState();
}

class _ClubProfileScreenState extends State<ClubProfileScreen>
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
                      Tab(
                        icon: Icon(PhosphorIcons.info()),
                      ), // Info tab for Club Details
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [_buildPostsGrid(), _buildAboutSection()],
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
          // Club Name as Username (Truncated if too long)
          Flexible(
            child: Text(
              widget
                  .club
                  .id, // Using ID or short name for the "username" top bar feel
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 4),
          if (widget.club.isMember)
            Icon(
              PhosphorIcons.sealCheck(PhosphorIconsStyle.fill),
              size: 16,
              color: Colors.blue,
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(PhosphorIcons.bell(), size: 28),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(PhosphorIcons.dotsThreeVertical(), size: 28), // Menu
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
                  backgroundImage: NetworkImage(widget.club.logoUrl ?? ''),
                ),
              ),
              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mocks for Posts since we don't have it in Club model yet, usage logic or hardcode
                    _buildStat('128', 'Posts'),
                    _buildStat('${widget.club.followersCount}', 'Followers'),
                    _buildStat('${widget.club.membersCount}', 'Members'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Name & Bio
          Text(
            widget.club.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            widget.club.district,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          if (widget.club.description != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                widget.club.description!,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          // Link
          Text(
            'www.leoclubs.org',
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
              Expanded(
                child: _buildActionButton(
                  context,
                  widget.club.isMember ? 'Following' : 'Follow',
                  isPrimary: !widget.club.isMember,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(child: _buildActionButton(context, 'Message')),
              const SizedBox(width: 6),
              Expanded(child: _buildActionButton(context, 'Contact')),
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
                        index == 0
                            ? PhosphorIcons.calendarStar()
                            : PhosphorIcons.image(),
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      index == 0 ? 'Events' : 'Highlight',
                      style: const TextStyle(fontSize: 11),
                    ),
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

  Widget _buildActionButton(
    BuildContext context,
    String label, {
    bool isPrimary = false,
  }) {
    return Container(
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isPrimary
            ? Theme.of(context).colorScheme.primary
            : Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: isPrimary
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface,
        ),
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

  Widget _buildAboutSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(PhosphorIcons.mapPin(), widget.club.district),
          const SizedBox(height: 12),
          _buildInfoRow(
            PhosphorIcons.usersThree(),
            '${widget.club.membersCount} Members',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(PhosphorIcons.calendar(), 'Founded 2010'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
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

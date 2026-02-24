import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../screens/auth/login_screen.dart';
import 'edit_profile_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;
  User? _user;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        setState(() {
          _error = 'Not logged in';
          _isLoading = false;
        });
        return;
      }

      final response = await ApiService.getProfile(token);

      // Create User object from API response
      setState(() {
        _user = User(
          id: response['user']['username'] ?? 'user',
          name: response['user']['username'] ?? 'Leo Member',
          avatarUrl: response['user']['avatarUrl'] ??
              'https://i.pravatar.cc/150?u=${response['user']['id']}',
          bio: response['user']['about'] ?? response['user']['email'],
          followers: 0,
          following: 0,
          posts: 0,
          isVerified: true,
          leoId: response['user']['leoId'],
          leoDistrict: response['user']['leoDistrict'],
          clubName: response['user']['clubName'],
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PhosphorIcons.warningCircle(), size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(child: Text('No user data')),
      );
    }

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

  Future<void> _showMenu(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                PhosphorIcons.signOut(),
                color: Theme.of(ctx).colorScheme.error,
              ),
              title: Text(
                'Log out',
                style: TextStyle(color: Theme.of(ctx).colorScheme.error),
              ),
              onTap: () async {
                Navigator.of(ctx).pop();
                await StorageService.clearAuthData();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                    (_) => false,
                  );
                }
              },
            ),
          ],
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
            _user!.id,
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
          icon: Icon(PhosphorIcons.list(), size: 28),
          onPressed: () => _showMenu(context),
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
                  backgroundImage: NetworkImage(_user!.avatarUrl ?? ''),
                ),
              ),
              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStat('${_user!.posts}', 'Posts'),
                    _buildStat('${_user!.followers}', 'Followers'),
                    _buildStat('${_user!.following}', 'Following'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Name & Bio
          Text(
            _user!.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          if (_user!.bio != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(_user!.bio!, style: const TextStyle(fontSize: 13)),
            ),
          // Leo ID
          if (_user!.leoId != null && _user!.leoId!.isNotEmpty)
            Text(
              'Leo ID: ${_user!.leoId}',
              style: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          // Leo District
          if (_user!.leoDistrict != null && _user!.leoDistrict!.isNotEmpty)
            Text(
              '📍 ${_user!.leoDistrict}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          // Club Name
          if (_user!.clubName != null && _user!.clubName!.isNotEmpty)
            Text(
              '🏛️ ${_user!.clubName}',
              style: const TextStyle(fontSize: 13),
            ),
          const SizedBox(height: 16),
          // Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(
                          currentUsername: _user!.name,
                          currentAbout: _user!.bio,
                          currentAvatarUrl: _user!.avatarUrl,
                        ),
                      ),
                    );
                    // Refresh profile if edited
                    if (result == true) {
                      _loadUserProfile();
                    }
                  },
                  child: _buildActionButton(context, 'Edit profile'),
                ),
              ),
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
          // Highlights
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
    // Mock posts grid - same UI as before
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        return Container(
          color: Colors.grey.shade300,
          child: Center(
            child: Icon(PhosphorIcons.image(), color: Colors.grey.shade600),
          ),
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

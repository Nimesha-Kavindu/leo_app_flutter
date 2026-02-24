import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../models/event.dart';
import '../../models/post.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
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
  List<Post> _feedPosts = [];
  bool _feedLoading = true;
  String? _feedError;

  List<Event> _events = [];
  bool _eventsLoading = true;
  String? _eventsError;
  final Set<String> _pendingRsvp = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFeed();
    _loadEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFeed() async {
    setState(() {
      _feedLoading = true;
      _feedError = null;
    });
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        setState(() {
          _feedError = 'Not authenticated';
          _feedLoading = false;
        });
        return;
      }
      final data = await ApiService.getFeed(token);
      final List<dynamic> raw = data['posts'] as List<dynamic>? ?? [];
      setState(() {
        _feedPosts =
            raw.map((j) => Post.fromJson(j as Map<String, dynamic>)).toList();
        _feedLoading = false;
      });
    } catch (e) {
      setState(() {
        _feedError = e.toString().replaceAll('Exception: ', '');
        _feedLoading = false;
      });
    }
  }

  Future<void> _loadEvents() async {
    setState(() {
      _eventsLoading = true;
      _eventsError = null;
    });
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        setState(() {
          _eventsError = 'Not authenticated';
          _eventsLoading = false;
        });
        return;
      }
      final data = await ApiService.getEvents(token);
      final List<dynamic> raw = data['events'] as List<dynamic>? ?? [];
      setState(() {
        _events =
            raw.map((j) => Event.fromJson(j as Map<String, dynamic>)).toList();
        _eventsLoading = false;
      });
    } catch (e) {
      setState(() {
        _eventsError = e.toString().replaceAll('Exception: ', '');
        _eventsLoading = false;
      });
    }
  }

  Future<void> _toggleRsvp(Event event) async {
    if (_pendingRsvp.contains(event.id)) return;
    setState(() => _pendingRsvp.add(event.id));
    try {
      final token = await StorageService.getToken();
      if (token == null) return;
      if (event.isAttending) {
        await ApiService.cancelRsvp(token, event.id);
      } else {
        await ApiService.rsvpEvent(token, event.id);
      }
      await _loadEvents();
    } catch (_) {
      // Silently ignore
    } finally {
      setState(() => _pendingRsvp.remove(event.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
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
                      const SizedBox(width: 8),
                    ],
                  ),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor:
                        Theme.of(context).colorScheme.onSurfaceVariant,
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
    if (_feedLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_feedError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_feedError!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadFeed,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_feedPosts.isEmpty) {
      return const Center(child: Text('No posts yet. Be the first!'));
    }
    return RefreshIndicator(
      onRefresh: _loadFeed,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 120, bottom: 20),
        itemCount: _feedPosts.length,
        itemBuilder: (context, index) {
          return PostCard(
            post: _feedPosts[index],
            onLike: () {},
            onComment: () {},
            onShare: () {},
            onUserClick: () => _navigateToProfile(_feedPosts[index].author),
          );
        },
      ),
    );
  }

  Widget _buildExploreTab() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 120, bottom: 20),
      itemCount: mockPosts.length,
      itemBuilder: (context, index) {
        return PostCard(
          post: mockPosts[index],
          onLike: () {},
          onUserClick: () => _navigateToProfile(mockPosts[index].author),
        );
      },
    );
  }

  Widget _buildEventsTab() {
    if (_eventsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_eventsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_eventsError!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadEvents,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_events.isEmpty) {
      return const Center(child: Text('No upcoming events.'));
    }
    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 120, bottom: 80),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return EventCard(
            event: event,
            onRSVP: _pendingRsvp.contains(event.id)
                ? null
                : () => _toggleRsvp(event),
            onCancelRsvp: _pendingRsvp.contains(event.id)
                ? null
                : () => _toggleRsvp(event),
          );
        },
      ),
    );
  }

  void _navigateToProfile(_) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserProfileScreen()),
    );
  }
}

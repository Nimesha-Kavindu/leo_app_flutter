class User {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? bio;
  final int followers;
  final int following;
  final int posts;
  final bool isVerified;
  final String? leoId;
  final String? leoDistrict;
  final String? clubName;

  User({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.bio,
    this.followers = 0,
    this.following = 0,
    this.posts = 0,
    this.isVerified = false,
    this.leoId,
    this.leoDistrict,
    this.clubName,
  });
}

final currentUser = User(
  id: 'current_user',
  name: 'Leo Member',
  avatarUrl: 'https://i.pravatar.cc/150?u=current_user',
  followers: 120,
  following: 50,
  posts: 12,
  isVerified: true,
  leoId: 'LEO-12345',
);

final mockUser = User(
  id: 'user_1',
  name: 'John Doe',
  avatarUrl: 'https://i.pravatar.cc/150?u=user_1',
  bio: 'Leo Club President | Community Builder | 📸 Content Creator',
  followers: 1250,
  following: 450,
  posts: 89,
  isVerified: true,
  leoId: 'LEO-99887',
);

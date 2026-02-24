import 'user.dart';

class Post {
  final String id;
  final User author;
  final String content;
  final String? imageUrl;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final bool isLiked;

  Post({
    required this.id,
    required this.author,
    required this.content,
    this.imageUrl,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      author: User(
        id: json['authorId'] as String,
        name: json['username'] as String? ?? 'Unknown',
        avatarUrl: json['avatarUrl'] as String?,
      ),
      content: json['caption'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      timestamp: DateTime.parse(json['createdAt'] as String),
      likes: (json['likeCount'] as num?)?.toInt() ?? 0,
      comments: (json['commentCount'] as num?)?.toInt() ?? 0,
    );
  }
}

final mockPosts = [
  Post(
    id: 'post_1',
    author: mockUser,
    content:
        'Had a great time at the district installation ceremony! #LeoClub #Leadership',
    imageUrl: 'https://picsum.photos/seed/leo1/600/400',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    likes: 45,
    comments: 12,
  ),
  Post(
    id: 'post_2',
    author: mockUser,
    content:
        'Planning our next community service project. Stay tuned for details!',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    likes: 28,
    comments: 5,
  ),
  Post(
    id: 'post_3',
    author: currentUser,
    content: 'Just joined Leo Connect! Excited to meet everyone.',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    likes: 10,
    comments: 2,
  ),
];

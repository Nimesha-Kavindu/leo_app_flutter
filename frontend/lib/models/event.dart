class Event {
  final String id;
  final String? clubId;
  final String? clubName;
  final String title;
  final String? description;
  final DateTime startAt;
  final DateTime? endAt;
  final String? location;
  final String? imageUrl;
  final int attendeeCount;
  final bool isAttending;

  Event({
    required this.id,
    this.clubId,
    this.clubName,
    required this.title,
    this.description,
    required this.startAt,
    this.endAt,
    this.location,
    this.imageUrl,
    this.attendeeCount = 0,
    this.isAttending = false,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      clubId: json['clubId'] as String?,
      clubName: json['clubName'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: json['endAt'] != null
          ? DateTime.parse(json['endAt'] as String)
          : null,
      location: json['location'] as String?,
      imageUrl: json['imageUrl'] as String?,
      attendeeCount: (json['attendeeCount'] as num?)?.toInt() ?? 0,
      isAttending: (json['isAttending'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clubId': clubId,
      'clubName': clubName,
      'title': title,
      'description': description,
      'startAt': startAt.toIso8601String(),
      'endAt': endAt?.toIso8601String(),
      'location': location,
      'imageUrl': imageUrl,
      'attendeeCount': attendeeCount,
      'isAttending': isAttending,
    };
  }
}

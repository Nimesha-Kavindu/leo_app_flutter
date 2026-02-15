import 'user.dart';

class Event {
  final String id;
  final User organizer;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String? imageUrl;
  final int attendees;

  Event({
    required this.id,
    required this.organizer,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    this.imageUrl,
    this.attendees = 0,
  });
}

final mockEvents = [
  Event(
    id: 'event_1',
    organizer: mockUser,
    title: 'Beach Clean-up Drive',
    description:
        'Join us for a morning of cleaning up our beautiful coastline. Bags and gloves provided.',
    date: DateTime.now().add(const Duration(days: 5)),
    location: 'Sunset Beach, District 306',
    imageUrl: 'https://picsum.photos/seed/beach/600/400',
    attendees: 34,
  ),
  Event(
    id: 'event_2',
    organizer: mockUser,
    title: 'Leadership Workshop',
    description:
        'Learn effective leadership skills from district leaders. Open to all Leos.',
    date: DateTime.now().add(const Duration(days: 12)),
    location: 'Community Hall, Colombo',
    attendees: 50,
  ),
];

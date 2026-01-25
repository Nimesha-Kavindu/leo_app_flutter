class Club {
  final String id;
  final String name;
  final String district;
  final String? description;
  final String? logoUrl;
  final String? coverUrl;
  final int membersCount;
  final int followersCount;
  final bool isMember;
  final bool isFollowing;

  Club({
    required this.id,
    required this.name,
    required this.district,
    this.description,
    this.logoUrl,
    this.coverUrl,
    this.membersCount = 0,
    this.followersCount = 0,
    this.isMember = false,
    this.isFollowing = false,
  });
}

final mockClubs = [
  Club(
    id: 'club_1',
    name: 'Leo Club of Colombo City',
    district: '306 A1',
    description:
        'We are a group of young leaders dedicated to serving our community and developing leadership skills.',
    logoUrl: 'https://picsum.photos/seed/club1/200',
    coverUrl: 'https://picsum.photos/seed/club1cover/800/400',
    membersCount: 45,
    followersCount: 1200,
    isMember: true,
  ),
  Club(
    id: 'club_2',
    name: 'Leo Club of University of Moratuwa',
    district: '306 A2',
    description:
        'Empowering university students through community service and professional development.',
    logoUrl: 'https://picsum.photos/seed/uom/200',
    membersCount: 150,
    followersCount: 3500,
    isFollowing: true,
  ),
  Club(
    id: 'club_3',
    name: 'Leo Club of Wattala',
    district: '306 B1',
    description:
        'Serving the Wattala community with passion and dedication since 2010.',
    logoUrl: 'https://picsum.photos/seed/wattala/200',
    membersCount: 32,
    followersCount: 890,
  ),
  Club(
    id: 'club_4',
    name: 'Leo Club of Kandy',
    district: '306 C1',
    description: 'Service with Pride.',
    logoUrl: 'https://picsum.photos/seed/kandy/200',
    membersCount: 88,
    followersCount: 1500,
  ),
  Club(
    id: 'club_5',
    name: 'Leo Club of Galle',
    district: '306 A1',
    description: 'Protecting our ocean and serving the southern community.',
    logoUrl: 'https://picsum.photos/seed/galle/200',
    membersCount: 40,
    followersCount: 950,
  ),
];

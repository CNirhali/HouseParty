class Party {
  final int id;
  final String title;
  final String vibe;
  final DateTime dateTime;
  final double locationLat;
  final double locationLng;
  final int hostId;
  final int maxGuests;
  final int currentGuests;
  final double? distanceKm;
  final String? address; // Only available if booked

  Party({
    required this.id,
    required this.title,
    required this.vibe,
    required this.dateTime,
    required this.locationLat,
    required this.locationLng,
    required this.hostId,
    required this.maxGuests,
    required this.currentGuests,
    this.distanceKm,
    this.address,
  });

  factory Party.fromJson(Map<String, dynamic> json) {
    return Party(
      id: json['id'],
      title: json['title'],
      vibe: json['vibe'],
      dateTime: DateTime.parse(json['date_time']),
      locationLat: json['location_lat'].toDouble(),
      locationLng: json['location_lng'].toDouble(),
      hostId: json['host_id'],
      maxGuests: json['max_guests'],
      currentGuests: json['current_guests'],
      distanceKm: json['distance_km']?.toDouble(),
      address: json['address'],
    );
  }
}

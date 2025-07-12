import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String name;
  final String bannerUrl;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final int availableTickets;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.name,
    required this.bannerUrl,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.availableTickets,
    required this.createdAt,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isBefore(endDate);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bannerUrl': bannerUrl,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'price': price,
      'availableTickets': availableTickets,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Event.fromMap(String id, Map<String, dynamic> map) {
    return Event(
      id: id,
      name: map['name'] ?? '',
      bannerUrl: map['bannerUrl'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      price: (map['price'] ?? 0.0).toDouble(),
      availableTickets: map['availableTickets'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}

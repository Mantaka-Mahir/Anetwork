import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final int availableTickets;
  final int ticketsSold;
  final String bannerUrl;
  final bool isActive;
  final bool hasCoupon;
  final String? couponCode;
  final double? couponDiscount;
  final DateTime createdAt;
  final String description;

  Event({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.availableTickets,
    required this.ticketsSold,
    required this.bannerUrl,
    required this.isActive,
    required this.createdAt,
    this.description = '',
    this.hasCoupon = false,
    this.couponCode,
    this.couponDiscount,
  });

  factory Event.fromMap(String id, Map<String, dynamic> data) {
    return Event(
      id: id,
      name: data['name'] ?? 'Unnamed Event',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      price: (data['price'] ?? 0).toDouble(),
      availableTickets: data['availableTickets'] ?? 0,
      ticketsSold: data['ticketsSold'] ?? 0,
      bannerUrl: data['bannerUrl'] ?? 'https://via.placeholder.com/400',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: data['description'] ?? '',
      hasCoupon: data['hasCoupon'] ?? false,
      couponCode: data['couponCode'],
      couponDiscount: data['couponDiscount'] != null
          ? (data['couponDiscount']).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'price': price,
      'availableTickets': availableTickets,
      'ticketsSold': ticketsSold,
      'bannerUrl': bannerUrl,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'description': description,
      'hasCoupon': hasCoupon,
      'couponCode': couponCode,
      'couponDiscount': couponDiscount,
    };
  }
}

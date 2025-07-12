import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';

class AdminEventDetail extends StatefulWidget {
  final String eventId;

  const AdminEventDetail({Key? key, required this.eventId}) : super(key: key);

  @override
  State<AdminEventDetail> createState() => _AdminEventDetailState();
}

class _AdminEventDetailState extends State<AdminEventDetail> {
  bool _isLoading = true;
  Event? _event;
  List<Map<String, dynamic>> _bookings = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadEventData();
  }

  // Use a stream to get real-time updates for ticket purchases
  Stream<List<Map<String, dynamic>>> _getTicketPurchasesStream() {
    return _firestore
        .collection('ticket_purchases')
        .where('eventId', isEqualTo: widget.eventId)
        .orderBy('purchaseDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'userName': data['userName'] ?? 'Unknown User',
          'userEmail': data['userEmail'] ?? '',
          'userPhone': data['userPhone'] ?? '',
          'ticketCount': data['ticketCount'] ?? 0,
          'totalPrice': data['totalPrice'] ?? 0.0,
          'purchaseDate':
              (data['purchaseDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          'paymentMethod': data['paymentMethod'] ?? 'Unknown',
          'status': data['paymentStatus'] ?? 'Confirmed',
          'transactionId': data['transactionId'] ?? '',
        };
      }).toList();
    });
  }

  Future<void> _loadEventData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load event data
      final eventDoc =
          await _firestore.collection('events').doc(widget.eventId).get();

      if (!eventDoc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event not found'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        }
        return;
      }

      _event = Event.fromMap(
          widget.eventId, eventDoc.data() as Map<String, dynamic>);

      try {
        // Load bookings from 'bookings' collection where eventId matches
        final bookingsSnapshot = await _firestore
            .collection('bookings')
            .where('eventId', isEqualTo: widget.eventId)
            .get();

        // Process booking data
        List<Map<String, dynamic>> bookings = [];
        for (final doc in bookingsSnapshot.docs) {
          final data = doc.data();
          final userId = data['userId'] as String? ?? '';
          String userName = 'Unknown User';
          String userEmail = '';
          String userPhone = '';

          // Fetch user information if userId is available
          if (userId.isNotEmpty) {
            try {
              final userDoc =
                  await _firestore.collection('users').doc(userId).get();

              if (userDoc.exists) {
                final userData = userDoc.data();
                userName = userData?['name'] ?? 'Unknown User';
                userEmail = userData?['email'] ?? '';
                userPhone = userData?['phone'] ?? 'Not provided';
              }
            } catch (e) {
              print('Error fetching user data: $e');
            }
          }

          bookings.add({
            'id': doc.id,
            'ticketCount': data['ticketCount'] ?? 0,
            'totalPrice': data['totalPrice'] ?? 0.0,
            'purchaseDate': (data['purchaseDate'] as Timestamp?)?.toDate() ??
                DateTime.now(),
            'userName': userName,
            'userEmail': userEmail,
            'userPhone': userPhone,
            'paymentMethod': data['paymentMethod'] ?? 'Unknown',
            'status': data['status'] ?? 'Confirmed',
          });
        }

        setState(() {
          _bookings = bookings;
          _isLoading = false;
        });
      } catch (e) {
        print('Error loading bookings: $e');

        // Check if the error is related to missing index
        if (e.toString().contains('failed-precondition') &&
            e.toString().contains('requires an index')) {
          // Show a custom dialog instead of a snackbar for better visibility
          if (mounted) {
            Future.microtask(() => _showIndexRequiredDialog());
          }

          // Still display the event without bookings
          setState(() {
            _bookings = [];
            _isLoading = false;
          });
        } else {
          // For other errors, show generic error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading bookings: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading event data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            'Event Dashboard',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_event == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            'Event Dashboard',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Text(
            'Event not found',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    final event = _event!;

    // Calculate total revenue from bookings
    final totalRevenue = _bookings.fold<double>(0,
        (total, booking) => total + (booking['totalPrice'] as double? ?? 0.0));

    // Get total tickets sold from the event data and from bookings
    // If bookings are available, use that data; otherwise use event.ticketsSold as fallback
    final totalTicketsSold = _bookings.isNotEmpty
        ? _bookings.fold<int>(0,
            (total, booking) => total + (booking['ticketCount'] as int? ?? 0))
        : event.ticketsSold;

    final totalTickets = event.availableTickets + event.ticketsSold;
    final soldPercentage =
        totalTickets > 0 ? (event.ticketsSold / totalTickets) * 100 : 0.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Event Dashboard',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadEventData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Banner
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: event.bannerUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: Colors.grey[800],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey[800],
                      child: const Icon(Icons.error, color: Colors.white),
                    ),
                  ),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Text(
                      event.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Details Section
                    Text(
                      'Event Details',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Start Date',
                        DateFormat('MMM dd, yyyy').format(event.startDate)),
                    _buildInfoRow('End Date',
                        DateFormat('MMM dd, yyyy').format(event.endDate)),
                    _buildInfoRow(
                        'Price', '\$${event.price.toStringAsFixed(2)}'),
                    _buildInfoRow(
                        'Available Tickets', event.availableTickets.toString()),
                    if (event.hasCoupon) ...[
                      _buildInfoRow('Coupon Code', event.couponCode ?? 'N/A'),
                      _buildInfoRow('Discount',
                          '${event.couponDiscount?.toString() ?? '0'}%'),
                    ],
                    const SizedBox(height: 24),

                    // Sales Overview
                    Text(
                      'Sales Overview',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard(
                          'Total Revenue',
                          '\$${totalRevenue.toStringAsFixed(2)}',
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Tickets Sold',
                          '$totalTicketsSold',
                          Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ticket Sales Progress',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: soldPercentage / 100,
                        backgroundColor: Colors.grey[800],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          soldPercentage < 50
                              ? Colors.green
                              : soldPercentage < 80
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tickets Sold: ${event.ticketsSold}',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          'Remaining: ${event.availableTickets}',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Recent Bookings
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Bookings',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_bookings.length} total',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_bookings.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            'No bookings yet',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _bookings.length > 5 ? 5 : _bookings.length,
                        separatorBuilder: (context, index) => const Divider(
                          color: Colors.grey,
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final booking = _bookings[index];
                          return _buildBookingItem(booking);
                        },
                      ),
                    if (_bookings.length > 5) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            // Show all bookings in a modal bottom sheet or a new screen
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => _buildAllBookingsSheet(),
                            );
                          },
                          child: Text(
                            'View All Bookings',
                            style: GoogleFonts.poppins(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllBookingsSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'All Bookings',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.grey),

              // Bookings list
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: _bookings.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: Colors.grey,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    return _buildBookingItem(booking);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookingItem(Map<String, dynamic> booking) {
    final purchaseDate = booking['purchaseDate'] as DateTime;
    final formattedDate = DateFormat('MMM dd, yyyy').format(purchaseDate);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        booking['userName'],
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            booking['userEmail'],
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            'Phone: ${booking['userPhone']}',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${booking['ticketCount']} tickets',
                  style: GoogleFonts.poppins(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Booked: $formattedDate',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${booking['totalPrice'].toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              booking['status'],
              style: GoogleFonts.poppins(
                color: Colors.green,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Show dialog for missing index error
  void _showIndexRequiredDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Database Configuration Required',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This query requires a database index to be configured in Firebase. Please contact the administrator.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }
}

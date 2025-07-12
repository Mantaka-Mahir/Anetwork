import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../widget/admin_event_detail.dart';

class EventDetailDashboard extends StatefulWidget {
  final String eventId;

  const EventDetailDashboard({Key? key, required this.eventId})
      : super(key: key);

  @override
  State<EventDetailDashboard> createState() => _EventDetailDashboardState();
}

class _EventDetailDashboardState extends State<EventDetailDashboard>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  Event? _event;
  List<Map<String, dynamic>> _bookings = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;

  // Analytics data
  double _totalRevenue = 0;
  int _ticketsSold = 0;
  double _soldPercentage = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEventData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

      // Load bookings
      try {
        // Get bookings for this event
        final bookingsSnapshot = await _firestore
            .collection('bookings')
            .where('eventId', isEqualTo: widget.eventId)
            .get();

        // Process booking data
        List<Map<String, dynamic>> bookings = [];

        _totalRevenue = 0;
        _ticketsSold = 0;

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

          final ticketCount = data['ticketCount'] != null
              ? (data['ticketCount'] as num).toInt()
              : 0;
          final totalPrice = data['totalPrice'] ?? 0.0;

          // Update analytics data
          _ticketsSold += ticketCount;
          _totalRevenue += totalPrice;

          bookings.add({
            'id': doc.id,
            'ticketCount': ticketCount,
            'totalPrice': totalPrice,
            'purchaseDate': (data['purchaseDate'] as Timestamp?)?.toDate() ??
                DateTime.now(),
            'userName': userName,
            'userEmail': userEmail,
            'userPhone': userPhone,
            'paymentMethod': data['paymentMethod'] ?? 'Unknown',
            'status': data['status'] ?? 'Confirmed',
          });
        }

        // Calculate percentage
        final totalTickets = (_event?.availableTickets ?? 0) + _ticketsSold;
        _soldPercentage =
            totalTickets > 0 ? (_ticketsSold / totalTickets) * 100 : 0.0;

        if (mounted) {
          setState(() {
            _bookings = bookings;
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Error loading bookings: $e');
        if (mounted) {
          setState(() {
            _bookings = [];
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
        setState(() {
          _isLoading = false;
        });
      }
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
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminEventDetail(eventId: event.id),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Attendees'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(event),
          _buildAttendeesTab(),
          _buildAnalyticsTab(event),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(Event event) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Banner
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
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
          ),
          const SizedBox(height: 16),

          // Event Title
          Text(
            event.name,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // Event Details
          _buildInfoRow(
              'Start Date', DateFormat('MMM dd, yyyy').format(event.startDate)),
          _buildInfoRow(
              'End Date', DateFormat('MMM dd, yyyy').format(event.endDate)),
          _buildInfoRow('Price', '\$${event.price.toStringAsFixed(2)}'),
          _buildInfoRow('Available Tickets', event.availableTickets.toString()),
          _buildInfoRow('Tickets Sold', _ticketsSold.toString()),

          const SizedBox(height: 24),

          // Key Performance Indicators
          Row(
            children: [
              _buildStatCard('Revenue', '\$${_totalRevenue.toStringAsFixed(2)}',
                  Colors.green),
              const SizedBox(width: 16),
              _buildStatCard(
                  'Sold',
                  '${_soldPercentage.toStringAsFixed(1)}%',
                  _soldPercentage < 50
                      ? Colors.red
                      : _soldPercentage < 80
                          ? Colors.orange
                          : Colors.green),
            ],
          ),

          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.edit,
                label: 'Edit',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context); // Close the dashboard
                  // The edit functionality is already implemented in the calling screen
                },
              ),
              _buildActionButton(
                icon: Icons.add_shopping_cart,
                label: 'Add Ticket',
                color: Colors.green,
                onTap: () {
                  _showAddTicketDialog(context, event);
                },
              ),
              _buildActionButton(
                icon: Icons.people,
                label: 'View Bookings',
                color: Colors.purple,
                onTap: () {
                  _tabController.animateTo(1); // Switch to Attendees tab
                },
              ),
              _buildActionButton(
                icon: Icons.analytics,
                label: 'Analytics',
                color: Colors.orange,
                onTap: () {
                  _tabController.animateTo(2); // Switch to Analytics tab
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeesTab() {
    // Check if event is null
    if (_event == null) {
      return Center(
        child: Text(
          'Event data unavailable',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    }

    if (_bookings.isEmpty) {
      return Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 72, color: Colors.grey[700]),
                const SizedBox(height: 16),
                Text(
                  'No bookings found for this event',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddTicketDialog(context, _event!),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text('Add Tickets Manually',
                      style: GoogleFonts.poppins()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () => _showAddTicketDialog(context, _event!),
              backgroundColor: Colors.green,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _bookings.length,
          separatorBuilder: (context, index) =>
              const Divider(color: Colors.grey),
          itemBuilder: (context, index) {
            final booking = _bookings[index];
            return _buildBookingItem(booking);
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => _showAddTicketDialog(context, _event!),
            backgroundColor: Colors.green,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab(Event event) {
    // Daily ticket sales - fake data for demonstration
    final daysUntilEvent = event.startDate.difference(DateTime.now()).inDays;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales Overview',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Ticket Sales Progress
          Card(
            color: Colors.grey[850],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ticket Sales Progress',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _soldPercentage / 100,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _soldPercentage < 50
                            ? Colors.green
                            : _soldPercentage < 80
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
                        'Sold: $_ticketsSold',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        'Available: ${event.availableTickets}',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Time to Event
          Card(
            color: Colors.grey[850],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Time to Event',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTimeCircle(daysUntilEvent, 'Days'),
                      _buildTimeCircle(daysUntilEvent * 24, 'Hours'),
                      _buildTimeCircle(daysUntilEvent * 24 * 60, 'Minutes'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Payment Methods
          Card(
            color: Colors.grey[850],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Methods',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPaymentMethodItem(
                          'Credit Card', Icons.credit_card, Colors.blue, 70),
                      _buildPaymentMethodItem('PayPal',
                          Icons.account_balance_wallet, Colors.purple, 20),
                      _buildPaymentMethodItem(
                          'Other', Icons.more_horiz, Colors.orange, 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem(
      String label, IconData icon, Color color, int percentage) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 60,
              width: 60,
              child: CircularProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey[700],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 6,
              ),
            ),
            Icon(icon, color: Colors.white, size: 24),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        Text(
          '$percentage%',
          style: GoogleFonts.poppins(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeCircle(int value, String label) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[800],
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
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
    return Expanded(
      child: Container(
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
      ),
    );
  }

  void _showAddTicketDialog(BuildContext context, Event event) {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _nameController = TextEditingController();
    final _phoneController = TextEditingController();
    final _ticketCountController = TextEditingController(text: '1');
    bool _userExists = false;
    bool _isLoading = false;
    bool _isCheckingUser = false;
    bool _createAccount = false;
    String _paymentMethod = 'Cash';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Method to check if user exists
            Future<void> checkUserExists() async {
              setState(() {
                _isCheckingUser = true;
                _userExists = false;
              });

              try {
                final email = _emailController.text.trim();
                if (email.isNotEmpty) {
                  // Check in Firestore users collection
                  final usersQuery = await _firestore
                      .collection('users')
                      .where('email', isEqualTo: email)
                      .limit(1)
                      .get();

                  if (usersQuery.docs.isNotEmpty) {
                    final userData = usersQuery.docs.first.data();
                    _nameController.text = userData['name'] ?? '';
                    _phoneController.text = userData['phone'] ?? '';
                    setState(() {
                      _userExists = true;
                    });
                  }
                }
              } catch (e) {
                print('Error checking user: $e');
              } finally {
                setState(() {
                  _isCheckingUser = false;
                });
              }
            }

            // Method to add ticket
            Future<void> addTicket() async {
              if (!_formKey.currentState!.validate()) return;

              setState(() {
                _isLoading = true;
              });

              try {
                final email = _emailController.text.trim();
                final name = _nameController.text.trim();
                final phone = _phoneController.text.trim();
                final ticketCount =
                    int.parse(_ticketCountController.text.trim());
                final totalPrice = event.price * ticketCount;
                String userId = '';

                // If user doesn't exist and we need to create an account
                if (!_userExists && _createAccount) {
                  try {
                    // Create user in Firebase Auth (in a real app, you'd use Firebase Auth functions)
                    // For now, we'll just create a Firestore user
                    // Create user document in Firestore
                    final userDoc = await _firestore.collection('users').add({
                      'email': email,
                      'name': name,
                      'phone': phone,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    userId = userDoc.id;
                  } catch (e) {
                    print('Error creating user: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating user: $e')));
                    return;
                  }
                } else if (_userExists) {
                  // Get user ID from existing user
                  final usersQuery = await _firestore
                      .collection('users')
                      .where('email', isEqualTo: email)
                      .limit(1)
                      .get();

                  if (usersQuery.docs.isNotEmpty) {
                    userId = usersQuery.docs.first.id;
                  }
                }

                // Create booking record
                await _firestore.collection('bookings').add({
                  'eventId': event.id,
                  'userId': userId,
                  'userName':
                      name, // Adding direct user info for non-registered users
                  'userEmail': email,
                  'userPhone': phone,
                  'ticketCount': ticketCount,
                  'totalPrice': totalPrice,
                  'purchaseDate': FieldValue.serverTimestamp(),
                  'paymentMethod': _paymentMethod,
                  'status': 'Confirmed',
                  'addedManually': true,
                });

                // Update event's available tickets
                await _firestore.collection('events').doc(event.id).update({
                  'availableTickets': FieldValue.increment(-ticketCount),
                  'ticketsSold': FieldValue.increment(ticketCount),
                });

                // Reload event data to reflect changes
                _loadEventData();

                // Success message
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Ticket added successfully for $name'),
                  backgroundColor: Colors.green,
                ));

                Navigator.of(context).pop(); // Close dialog
              } catch (e) {
                print('Error adding ticket: $e');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Error adding ticket: $e'),
                  backgroundColor: Colors.red,
                ));
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            }

            return AlertDialog(
              title: Text(
                'Add Ticket Manually',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Info at the top
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.name,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Price: \$${event.price.toStringAsFixed(2)} | Available: ${event.availableTickets}',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email with check button
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                                suffixIcon: _isCheckingUser
                                    ? Container(
                                        width: 20,
                                        height: 20,
                                        padding: const EdgeInsets.all(8),
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))
                                    : _userExists
                                        ? Icon(Icons.check_circle,
                                            color: Colors.green)
                                        : null,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                // Clear user exists flag when email changes
                                if (_userExists) {
                                  setState(() {
                                    _userExists = false;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _isCheckingUser ? null : checkUserExists,
                            child: Text('Check'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ],
                      ),
                      if (!_userExists)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _createAccount,
                                onChanged: (value) {
                                  setState(() {
                                    _createAccount = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(
                                  'Create new user account',
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                        enabled: !_userExists, // Disable if user exists
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                        enabled: !_userExists, // Disable if user exists
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Ticket Count
                      TextFormField(
                        controller: _ticketCountController,
                        decoration: InputDecoration(
                          labelText: 'Number of Tickets',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter ticket count';
                          }
                          final ticketCount = int.tryParse(value);
                          if (ticketCount == null || ticketCount <= 0) {
                            return 'Please enter a valid number';
                          }
                          if (ticketCount > event.availableTickets) {
                            return 'Not enough tickets available';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Payment Method
                      DropdownButtonFormField<String>(
                        value: _paymentMethod,
                        decoration: InputDecoration(
                          labelText: 'Payment Method',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                          DropdownMenuItem(
                              value: 'Credit Card', child: Text('Credit Card')),
                          DropdownMenuItem(
                              value: 'Bank Transfer',
                              child: Text('Bank Transfer')),
                          DropdownMenuItem(
                              value: 'Other', child: Text('Other')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _paymentMethod = value ?? 'Cash';
                          });
                        },
                      ),

                      // Total Price Display
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Price:',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${(event.price * (int.tryParse(_ticketCountController.text) ?? 0)).toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: Text('Cancel', style: GoogleFonts.poppins()),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : addTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Add Ticket', style: GoogleFonts.poppins()),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

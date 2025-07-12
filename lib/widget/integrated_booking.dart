import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:event_management_app/screeen/log in.dart';
import 'package:event_management_app/screeen/confarmation_screen.dart';

class IntegratedBookingScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const IntegratedBookingScreen({Key? key, required this.event})
      : super(key: key);

  @override
  _IntegratedBookingScreenState createState() =>
      _IntegratedBookingScreenState();
}

class _IntegratedBookingScreenState extends State<IntegratedBookingScreen> {
  // Event details
  late int totalTickets;
  late int availableTickets;
  int selectedTickets = 1;
  double ticketPrice = 100;

  // Payment details
  String selectedPaymentMethod = 'bKash';
  bool _isProcessing = false;
  bool _hasCompletedPayment = false;
  String _transactionId = '';
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _transactionPinController =
      TextEditingController();
  String couponMessage = '';
  bool couponApplied = false;
  double discountPercent = 0;

  // Current step in the booking process
  int _currentStep = 0;

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    totalTickets = widget.event['totalTickets'] ?? 500;
    availableTickets = widget.event['availableTickets'] ?? 120;
    ticketPrice = widget.event['ticketPrice'] ?? 100.0;
  }

  void _incrementTickets() {
    if (selectedTickets < availableTickets) {
      setState(() {
        selectedTickets++;
      });
    }
  }

  void _decrementTickets() {
    if (selectedTickets > 1) {
      setState(() {
        selectedTickets--;
      });
    }
  }

  void _applyCoupon() {
    final code = _couponController.text.trim();
    if (code.isEmpty) {
      setState(() {
        couponMessage = 'Please enter a coupon code';
      });
      return;
    }

    // Check for coupon in Firestore
    final String eventId = widget.event['eventId'] ?? '';
    if (eventId.isNotEmpty) {
      _firestore.collection('events').doc(eventId).get().then((doc) {
        if (doc.exists) {
          final eventData = doc.data();
          final couponCode = eventData?['couponCode'];
          final couponDiscount = eventData?['couponDiscount'];

          if (couponCode != null &&
              couponDiscount != null &&
              code.toUpperCase() == couponCode.toUpperCase()) {
            setState(() {
              couponMessage = 'Coupon applied: ${couponDiscount}% off!';
              discountPercent = couponDiscount;
              couponApplied = true;
              ticketPrice =
                  widget.event['ticketPrice'] * (1 - (couponDiscount / 100));
            });
          } else {
            setState(() {
              couponMessage = 'Invalid coupon code.';
              couponApplied = false;
            });
          }
        }
      }).catchError((e) {
        setState(() {
          couponMessage = 'Error checking coupon: $e';
          couponApplied = false;
        });
      });
    } else {
      // Fallback for testing
      if (code.toUpperCase() == 'DISCOUNT10') {
        setState(() {
          couponMessage = 'Coupon applied: 10% off!';
          discountPercent = 10;
          couponApplied = true;
          ticketPrice = widget.event['ticketPrice'] * 0.9;
        });
      } else {
        setState(() {
          couponMessage = 'Invalid coupon code.';
          couponApplied = false;
        });
      }
    }
  }

  void _resetCoupon() {
    setState(() {
      _couponController.clear();
      couponMessage = '';
      couponApplied = false;
      discountPercent = 0;
      ticketPrice = widget.event['ticketPrice'] ?? 100.0;
    });
  }

  void _processPayment() {
    // Verify user is logged in
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please log in to complete your purchase'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Login',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ),
      );
      return;
    }

    // Prevent duplicate payments
    if (_isProcessing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Your payment is already being processed. Please wait.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_hasCompletedPayment) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your payment has already been completed.'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    // Generate transaction ID and set processing state
    _transactionId = const Uuid().v4();
    setState(() {
      _isProcessing = true;
    });

    // Calculate total price
    double totalPrice = selectedTickets * ticketPrice;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );

    // Simulate payment processing with a delay
    Future.delayed(const Duration(seconds: 2), () {
      // Close loading dialog
      Navigator.pop(context);

      // Complete the booking process
      _completeBooking(user, totalPrice);
    });
  }

  void _completeBooking(User user, double totalPrice) async {
    try {
      // Update Firestore - update the event's available tickets and tickets sold
      final String eventId = widget.event['eventId'] ?? '';
      if (eventId.isNotEmpty) {
        final DocumentReference eventRef =
            _firestore.collection('events').doc(eventId);

        await _firestore.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(eventRef);

          if (snapshot.exists) {
            Map<String, dynamic> eventData =
                snapshot.data() as Map<String, dynamic>;
            int currentAvailable = eventData['availableTickets'] ?? 0;
            int currentSold = eventData['ticketsSold'] ?? 0;

            if (currentAvailable >= selectedTickets) {
              transaction.update(eventRef, {
                'availableTickets': currentAvailable - selectedTickets,
                'ticketsSold': currentSold + selectedTickets,
              });
            } else {
              throw Exception('Not enough tickets available');
            }
          }
        });

        // Create a booking record
        await _firestore.collection('bookings').add({
          'eventId': eventId,
          'userId': user.uid,
          'ticketCount': selectedTickets,
          'totalPrice': totalPrice,
          'purchaseDate': FieldValue.serverTimestamp(),
          'paymentMethod': selectedPaymentMethod,
          'status': 'Confirmed',
          'transactionId': _transactionId,
          'couponApplied': couponApplied,
          'discountPercent': discountPercent,
        });

        // Create a ticket_purchases record for the admin dashboard
        await _firestore.collection('ticket_purchases').add({
          'eventId': eventId,
          'userId': user.uid,
          'userName': user.displayName ?? 'User',
          'userEmail': user.email ?? '',
          'userPhone': '',
          'ticketCount': selectedTickets,
          'totalPrice': totalPrice,
          'purchaseDate': FieldValue.serverTimestamp(),
          'paymentMethod': selectedPaymentMethod,
          'paymentStatus': 'Confirmed',
          'transactionId': _transactionId,
        });

        // Update state
        setState(() {
          _isProcessing = false;
          _hasCompletedPayment = true;
          availableTickets -= selectedTickets;
        });

        // Navigate to confirmation screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TicketConfirmationScreen(
              event: widget.event,
              ticketsBought: selectedTickets,
              totalPrice: totalPrice,
              couponApplied: couponApplied,
              paymentMethod: selectedPaymentMethod,
              transactionId: _transactionId,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error completing booking: $e');
      setState(() {
        _isProcessing = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.event['title'] ?? 'No Title Available';
    String date = widget.event['date'] ?? 'No Date Available';
    String time = widget.event['time'] ?? 'No Time Available';
    String image = widget.event['image'] ?? 'https://via.placeholder.com/400';
    double totalPrice = ticketPrice * selectedTickets;
    final isUserLoggedIn = _auth.currentUser != null;

    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        title: Text(
          "Book Event Tickets",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Event image and details card
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: image,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),

                  // Event details
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              date,
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.access_time,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              time,
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              "Attention Network",
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Event Description
                        if (_getDescription() != null &&
                            _getDescription().trim().isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Event Description:",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    _buildExpandButton(
                                        context, _getDescription()),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _getShortDescription(_getDescription()),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Available Tickets:",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              availableTickets.toString(),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: availableTickets < 10
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Ticket Price:",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "৳ ${widget.event['ticketPrice'].toStringAsFixed(2)}",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        if (couponApplied) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Discounted Price:",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                "৳ ${ticketPrice.toStringAsFixed(2)} (${discountPercent.toInt()}% off)",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Ticket selection section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "How many tickets?",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _decrementTickets,
                        icon: const Icon(Icons.remove_circle),
                        color: Colors.red,
                        iconSize: 36,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          selectedTickets.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _incrementTickets,
                        icon: const Icon(Icons.add_circle),
                        color: Colors.green,
                        iconSize: 36,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Price:",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "৳ ${totalPrice.toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      labelText: 'Coupon Code',
                      labelStyle: GoogleFonts.poppins(color: Colors.grey),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (couponApplied)
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: _resetCoupon,
                            ),
                          ElevatedButton(
                            onPressed: _applyCoupon,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              couponApplied ? 'Applied' : 'Apply',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  if (couponMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        couponMessage,
                        style: GoogleFonts.poppins(
                          color: couponApplied ? Colors.green : Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Payment section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Payment Method",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment method selection
                  _buildPaymentMethodCard(
                    "bKash",
                    "https://i.postimg.cc/vmsgf62L/Screenshot-2025-04-04-220048.png",
                    'Pay with bKash mobile banking',
                  ),
                  _buildPaymentMethodCard(
                    "Nagad",
                    "https://i.postimg.cc/d061CNyw/Screenshot-2025-04-04-220511.png",
                    'Pay with Nagad mobile banking',
                  ),
                ],
              ),
            ),

            // Pay now button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: isUserLoggedIn
                    ? _processPayment
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                const Text('Please log in to book tickets'),
                            backgroundColor: Colors.red,
                            action: SnackBarAction(
                              label: 'Login',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen()),
                                );
                              },
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isUserLoggedIn ? Colors.red : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "Pay ৳ ${totalPrice.toStringAsFixed(2)}",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Status message for logged out users
            if (!isUserLoggedIn)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Please log in to book tickets",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(
      String name, String imageUrl, String description) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = name;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selectedPaymentMethod == name
              ? Colors.red.withOpacity(0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedPaymentMethod == name
                ? Colors.red
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              width: 36,
              height: 36,
              placeholder: (context, url) => const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (selectedPaymentMethod == name)
              const Icon(Icons.check_circle, color: Colors.red),
          ],
        ),
      ),
    );
  }

  String _getShortDescription(String description) {
    // Return the first 150 characters of the description or the full description if it's shorter
    if (description.length <= 150) return description;
    return '${description.substring(0, 150)}...';
  }

  Widget _buildExpandButton(BuildContext context, String fullDescription) {
    return ElevatedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "Event Description",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Text(
                  fullDescription,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Close",
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
      icon: const Icon(Icons.info_outline, size: 16),
      label: Text(
        "View Full",
        style: GoogleFonts.poppins(fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(30, 24),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  String _getDescription() {
    // Check for description with different possible key casings
    if (widget.event['description'] != null) {
      return widget.event['description'].toString();
    }
    if (widget.event['Description'] != null) {
      return widget.event['Description'].toString();
    }
    // Check Firestore's convention of using 'desc' sometimes
    if (widget.event['desc'] != null) {
      return widget.event['desc'].toString();
    }

    // Default empty description if none found
    return '';
  }
}

import 'package:event_management_app/screeen/log in.dart';
import 'package:event_management_app/widget/integrated_booking.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EventDetail extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventDetail({Key? key, required this.event}) : super(key: key);

  @override
  _EventDetailState createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  late int totalTickets;
  late int availableTickets;
  int selectedTickets = 1;
  double ticketPrice = 100;
  final TextEditingController _couponController = TextEditingController();
  String couponMessage = '';
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

  void _buyTicket() {
    final user = _auth.currentUser;

    // Check if user is logged in
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please login to book tickets'),
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

    if (availableTickets >= selectedTickets) {
      Navigator.push<int>(
        context,
        MaterialPageRoute(
          builder: (context) => IntegratedBookingScreen(
            event: widget.event,
          ),
        ),
      ).then((ticketsPurchased) async {
        if (ticketsPurchased != null && ticketsPurchased > 0) {
          // Update local state
          setState(() {
            availableTickets -= ticketsPurchased;
          });

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

                  if (currentAvailable >= ticketsPurchased) {
                    transaction.update(eventRef, {
                      'availableTickets': currentAvailable - ticketsPurchased,
                      'ticketsSold': currentSold + ticketsPurchased,
                    });
                  } else {
                    throw Exception('Not enough tickets available');
                  }
                }
              });

              // Create a booking record with the structure matching Firebase
              await _firestore.collection('bookings').add({
                'eventId': eventId,
                'userId': user.uid,
                'ticketCount': ticketsPurchased,
                'totalPrice': ticketsPurchased * ticketPrice,
                'purchaseDate': FieldValue.serverTimestamp(),
                'paymentMethod':
                    'Credit Card', // Default or get from payment method
                'status': 'Confirmed',
              });

              // Show success message
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tickets purchased successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          } catch (e) {
            print('Error updating event data: $e');
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
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough tickets available!'),
          backgroundColor: Colors.redAccent,
        ),
      );
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
              ticketPrice =
                  widget.event['ticketPrice'] * (1 - (couponDiscount / 100));
            });
          } else {
            setState(() {
              couponMessage = 'Invalid coupon code.';
            });
          }
        }
      }).catchError((e) {
        setState(() {
          couponMessage = 'Error checking coupon: $e';
        });
      });
    } else {
      // Fallback for testing
      if (code.toUpperCase() == 'DISCOUNT10') {
        setState(() {
          couponMessage = 'Coupon applied: 10% off!';
          ticketPrice = widget.event['ticketPrice'] * 0.9;
        });
      } else {
        setState(() {
          couponMessage = 'Invalid coupon code.';
        });
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero animation for the event image with gradient overlay
              Stack(
                children: [
                  Hero(
                    tag: title,
                    child: Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: image,
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
                    ),
                  ),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  // Back Button
                  Positioned(
                    top: 10,
                    left: 10,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  // Title with icon representing plan type
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Row(
                      children: [
                        // Sample icon; replace with an icon matching the plan type if needed.
                        const Icon(Icons.event, color: Colors.white, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          '$date | $time',
                          style: GoogleFonts.poppins(
                              fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Location Container (showing location clearly)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 20, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Attention Network',
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.event['description'] ?? 'No description provided.',
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    // User login status message if not logged in
                    if (!isUserLoggedIn)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Please login to book tickets',
                                style: GoogleFonts.poppins(color: Colors.white),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Login',
                                style: GoogleFonts.poppins(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Coupon Container
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Have a coupon?",
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _couponController,
                                  style:
                                      GoogleFonts.poppins(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: "Enter coupon code",
                                    hintStyle: GoogleFonts.poppins(
                                        color: Colors.white70),
                                    filled: true,
                                    fillColor: Colors.black38,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _applyCoupon,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "Apply",
                                  style: GoogleFonts.poppins(
                                      color: Colors.black, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          if (couponMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                couponMessage,
                                style: GoogleFonts.poppins(
                                    color: couponMessage.contains('Invalid')
                                        ? Colors.red
                                        : Colors.green,
                                    fontSize: 14),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Event Ticket Details Card
                    ClayContainer(
                      depth: 20,
                      borderRadius: 12,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total Tickets:",
                                    style: GoogleFonts.poppins(
                                        fontSize: 16, color: Colors.black)),
                                Text("$totalTickets",
                                    style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Available Tickets:",
                                    style: GoogleFonts.poppins(
                                        fontSize: 16, color: Colors.black)),
                                Text("$availableTickets",
                                    style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total Price:",
                                    style: GoogleFonts.poppins(
                                        fontSize: 16, color: Colors.black)),
                                Text("\$${totalPrice.toStringAsFixed(2)}",
                                    style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text("Select Tickets:",
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            const SizedBox(height: 10),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: _decrementTickets,
                                    icon: const Icon(
                                        Icons.remove_circle_outline,
                                        size: 32,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    '$selectedTickets',
                                    style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    onPressed: _incrementTickets,
                                    icon: const Icon(Icons.add_circle_outline,
                                        size: 32, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Tappable Book Ticket button with updated white style
                    Center(
                      child: InkWell(
                        onTap: _buyTicket,
                        borderRadius: BorderRadius.circular(12),
                        child: Hero(
                          tag: "bookTicketButton$title",
                          child: ClayContainer(
                            depth: 10,
                            borderRadius: 12,
                            color: const Color(0xFF100720),
                            child: Container(
                              width: 165,
                              height: 62,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: isUserLoggedIn
                                    ? Colors.white70
                                    : Colors.grey,
                              ),
                              child: Text(
                                "Book Ticket",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

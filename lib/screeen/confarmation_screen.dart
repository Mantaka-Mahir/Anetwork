import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class TicketConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> event;
  final int ticketsBought;
  final bool couponApplied;
  final double totalPrice;
  final String paymentMethod;
  final String transactionId;

  const TicketConfirmationScreen({
    Key? key,
    required this.event,
    required this.ticketsBought,
    this.couponApplied = false,
    required this.totalPrice,
    this.paymentMethod = 'Credit Card',
    this.transactionId = '',
  }) : super(key: key);

  @override
  State<TicketConfirmationScreen> createState() =>
      _TicketConfirmationScreenState();
}

class _TicketConfirmationScreenState extends State<TicketConfirmationScreen> {
  bool _isProcessing = true;
  String _message = 'Processing your ticket purchase...';
  bool _success = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _transactionId = '';

  @override
  void initState() {
    super.initState();
    _transactionId = widget.transactionId.isNotEmpty
        ? widget.transactionId
        : const Uuid().v4();
    _recordPurchase();
  }

  Future<void> _recordPurchase() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _isProcessing = false;
          _success = false;
          _message = 'Error: User not logged in';
        });
        return;
      }

      final String eventId = widget.event['eventId'] ?? '';
      if (eventId.isEmpty) {
        setState(() {
          _isProcessing = false;
          _success = false;
          _message = 'Error: Invalid event ID';
        });
        return;
      }

      // Check if a transaction with this ID already exists
      final existingPurchases = await _firestore
          .collection('ticket_purchases')
          .where('transactionId', isEqualTo: _transactionId)
          .limit(1)
          .get();

      if (existingPurchases.docs.isNotEmpty) {
        // Transaction already processed
        setState(() {
          _isProcessing = false;
          _success = true;
          _message = 'This purchase has already been processed.';
        });
        return;
      }

      // Get user info for the purchase record
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>? ?? {};
      final userName = userData['name'] ?? 'Unknown User';
      final userEmail = userData['email'] ?? user.email ?? '';
      final userPhone = userData['phone'] ?? '';

      // Generate a unique ID for this purchase
      final purchaseId = const Uuid().v4();

      // Update the event's available tickets and tickets sold in Firestore
      final DocumentReference eventRef =
          _firestore.collection('events').doc(eventId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(eventRef);

        if (!snapshot.exists) {
          throw Exception('Event does not exist');
        }

        Map<String, dynamic> eventData =
            snapshot.data() as Map<String, dynamic>;
        int currentAvailable = eventData['availableTickets'] ?? 0;
        int currentSold = eventData['ticketsSold'] ?? 0;
        String eventName = eventData['name'] ?? 'Event';

        if (currentAvailable < widget.ticketsBought) {
          throw Exception('Not enough tickets available');
        }

        // Update event
        transaction.update(eventRef, {
          'availableTickets': currentAvailable - widget.ticketsBought,
          'ticketsSold': currentSold + widget.ticketsBought,
        });

        // Create purchase record in ticket_purchases collection
        transaction
            .set(_firestore.collection('ticket_purchases').doc(purchaseId), {
          'purchaseId': purchaseId,
          'userId': user.uid,
          'eventId': eventId,
          'eventName': eventName,
          'userName': userName,
          'userEmail': userEmail,
          'userPhone': userPhone,
          'ticketCount': widget.ticketsBought,
          'totalPrice': widget.totalPrice,
          'purchaseDate': FieldValue.serverTimestamp(),
          'paymentMethod': widget.paymentMethod,
          'paymentStatus': 'Confirmed',
          'transactionId': _transactionId,
          'couponApplied': widget.couponApplied,
        });
      });

      // Also create a record in the bookings collection for backward compatibility
      await _firestore.collection('bookings').add({
        'eventId': eventId,
        'userId': user.uid,
        'ticketCount': widget.ticketsBought,
        'totalPrice': widget.totalPrice,
        'purchaseDate': FieldValue.serverTimestamp(),
        'paymentMethod': widget.paymentMethod,
        'status': 'Confirmed',
        'transactionId': _transactionId,
      });

      setState(() {
        _isProcessing = false;
        _success = true;
        _message = 'Ticket purchased successfully!';
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _success = false;
        _message = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String couponText = widget.couponApplied ? "with discount applied" : "";

    return Scaffold(
      backgroundColor: Colors.redAccent,
      appBar: AppBar(
        title: const Text("Ticket Confirmation"),
        backgroundColor: Colors.redAccent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isProcessing
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 20),
                    Text(
                      _message,
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _success ? Icons.check_circle : Icons.error,
                      size: 100,
                      color: _success ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _success
                          ? "Ticket Purchased Successfully!"
                          : "Purchase Failed",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    if (_success) ...[
                      Text(
                        "You bought ${widget.ticketsBought} ticket(s) for the event: ${widget.event['title']} $couponText",
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Total amount: \$${widget.totalPrice.toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      Text(
                        _message,
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        // Return the number of tickets purchased if successful, otherwise 0
                        Navigator.of(context)
                            .pop(_success ? widget.ticketsBought : 0);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Back to Events",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventDetail extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventDetail({Key? key, required this.event}) : super(key: key);

  @override
  _EventDetailState createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  int totalTickets = 50; // Total tickets for the event
  int availableTickets = 50; // Initially, all tickets are available
  int selectedTickets = 1; // Number of tickets user wants to buy

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

  // Modified _buyTicket: navigate to PaymentMethodScreen without immediately deducting tickets.
  void _buyTicket() {
    if (availableTickets >= selectedTickets) {
      Navigator.push<int>(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentMethodScreen(
            event: widget.event,
            ticketsBought: selectedTickets,
          ),
        ),
      ).then((ticketsPurchased) {
        // If payment confirmed and a result is returned, update availableTickets.
        if (ticketsPurchased != null && ticketsPurchased > 0) {
          setState(() {
            availableTickets -= ticketsPurchased;
          });
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough tickets available!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.event['title'])),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.event['image'],
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event['title'],
                    style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.event['date']} | ${widget.event['time']}',
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (widget.event.containsKey('location'))
                    Text(
                      '📍 ${widget.event['location']}',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    widget.event['description'] ?? 'No description provided.',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text("Total Tickets: $totalTickets", style: GoogleFonts.poppins(fontSize: 16)),
                  Text("Available Tickets: $availableTickets", style: GoogleFonts.poppins(fontSize: 16, color: Colors.green)),
                  const SizedBox(height: 20),
                  Text("Select Tickets:", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _decrementTickets,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$selectedTickets', style: GoogleFonts.poppins(fontSize: 18)),
                      IconButton(
                        onPressed: _incrementTickets,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _buyTicket,
                    child: const Text("Buy Ticket"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentMethodScreen extends StatefulWidget {
  final Map<String, dynamic> event;
  final int ticketsBought;

  const PaymentMethodScreen({
    Key? key,
    required this.event,
    required this.ticketsBought,
  }) : super(key: key);

  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String selectedPaymentMethod = 'Credit Card';
  final TextEditingController couponController = TextEditingController();
  bool couponApplied = false;

  void _applyCoupon() {
    // Dummy coupon logic
    if (couponController.text.trim().toUpperCase() == 'DISCOUNT10') {
      setState(() {
        couponApplied = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coupon Applied! 10% discount applied.')),
      );
    } else {
      setState(() {
        couponApplied = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid coupon code.')),
      );
    }
  }

  void _confirmPayment() {
    // Dummy payment confirmation
    Navigator.pop(context, widget.ticketsBought); // Return number of tickets purchased
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketConfirmationScreen(
          event: widget.event,
          ticketsBought: widget.ticketsBought,
          couponApplied: couponApplied,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Method"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Payment Method",
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Radio<String>(
                value: 'Credit Card',
                groupValue: selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    selectedPaymentMethod = value!;
                  });
                },
              ),
              title: const Text("Credit Card"),
            ),
            ListTile(
              leading: Radio<String>(
                value: 'PayPal',
                groupValue: selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    selectedPaymentMethod = value!;
                  });
                },
              ),
              title: const Text("PayPal"),
            ),
            ListTile(
              leading: Radio<String>(
                value: 'Google Pay',
                groupValue: selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    selectedPaymentMethod = value!;
                  });
                },
              ),
              title: const Text("Google Pay"),
            ),
            const SizedBox(height: 20),
            Text(
              "Enter Coupon Code",
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: couponController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter coupon code",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _applyCoupon,
                  child: const Text("Apply"),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _confirmPayment,
                child: const Text("Confirm Payment"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TicketConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> event;
  final int ticketsBought;
  final bool couponApplied;

  const TicketConfirmationScreen({
    Key? key,
    required this.event,
    required this.ticketsBought,
    this.couponApplied = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String couponText = couponApplied ? "with discount applied" : "";
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ticket Confirmation"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 100, color: Colors.green),
              const SizedBox(height: 20),
              Text(
                "Ticket Purchased Successfully!",
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "You bought $ticketsBought ticket(s) for the event: ${event['title']} $couponText",
                style: GoogleFonts.poppins(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text("Back to Events"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

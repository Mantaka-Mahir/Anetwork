import 'package:event_management_app/screeen/payment_method_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventDetail extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventDetail({Key? key, required this.event}) : super(key: key);

  @override
  _EventDetailState createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  int totalTickets = 50;
  int availableTickets = 50;
  int selectedTickets = 1;

  void _incrementTickets() {
    if (selectedTickets < availableTickets) {
      setState(() => selectedTickets++);
    }
  }

  void _decrementTickets() {
    if (selectedTickets > 1) {
      setState(() => selectedTickets--);
    }
  }

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
        if (ticketsPurchased != null && ticketsPurchased > 0) {
          setState(() => availableTickets -= ticketsPurchased);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Not enough tickets available!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light Background
      appBar: AppBar(
        title: Text(widget.event['title'], style: GoogleFonts.poppins()),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image with Gradient Overlay
            Stack(
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.event['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.8)],
                    ),
                  ),
                ),
              ],
            ),

            // Event Details Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event['title'],
                    style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.event['date']} | ${widget.event['time']}',
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (widget.event.containsKey('location'))
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 20, color: Colors.redAccent),
                        const SizedBox(width: 8),
                        Text(
                          widget.event['location'],
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  Text(
                    widget.event['description'] ?? 'No description provided.',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),

                  const SizedBox(height: 20),

                  // Ticket Information
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total Tickets:", style: GoogleFonts.poppins(fontSize: 16)),
                            Text("$totalTickets", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Available Tickets:", style: GoogleFonts.poppins(fontSize: 16)),
                            Text(
                              "$availableTickets",
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Ticket Selector
                  Text("Select Tickets:", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _decrementTickets,
                        icon: const Icon(Icons.remove_circle_outline, size: 32, color: Colors.redAccent),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$selectedTickets',
                          style: GoogleFonts.poppins(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: _incrementTickets,
                        icon: const Icon(Icons.add_circle_outline, size: 32, color: Colors.green),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Buy Ticket Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _buyTicket,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                      child: Text("Buy Ticket", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
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

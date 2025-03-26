import 'package:event_management_app/screeen/payment_method_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clay_containers/clay_containers.dart';

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
  double ticketPrice = 100; // Price per ticket

  @override
  void initState() {
    super.initState();
    totalTickets = widget.event['totalTickets'] ?? 500;
    availableTickets = widget.event['availableTickets'] ?? 120;
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

  // Navigate to PaymentMethodScreen without immediately deducting tickets.
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
          setState(() {
            availableTickets -= ticketsPurchased;
          });
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
    // Fallback values for event keys
    String title = widget.event['title'] ?? 'No Title Available';
    String date = widget.event['date'] ?? 'No Date Available';
    String time = widget.event['time'] ?? 'No Time Available';
    String location = widget.event['location'] ?? 'Location Not Provided';
    String image = widget.event['image'] ?? 'https://via.placeholder.com/400';

    // Ensure ticketPrice exists in event data, else use a fallback
    double ticketPrice = widget.event['totalPrice'] != null &&
        widget.event['totalPrice'] is double
        ? widget.event['totalPrice']
        : 100; // Default ticket price if not found

    // Calculate total price based on selected tickets
    double totalPrice = ticketPrice * selectedTickets;

    return Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Image with Gradient Overlay
              Stack(
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
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
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date & Time Row
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
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
                    // Location Row
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 20, color: Colors.redAccent),
                        const SizedBox(width: 8),
                        Text(
                          location,
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Description
                    Text(
                      widget.event['description'] ?? 'No description provided.',
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    // Ticket Information Container using ClayContainer for modern UI
                    ClayContainer(
                      depth: 20,
                      borderRadius: 12,
                      color: const Color(
                          0xFF2BCBF3), // Container background color in Taka section
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Total Tickets Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total Tickets:",
                                    style: GoogleFonts.poppins(
                                        fontSize: 16, color: Colors.white)),
                                Text("$totalTickets",
                                    style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ],
                            ),
                            // Available Tickets Row with price displayed in Taka
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Available Tickets:",
                                    style: GoogleFonts.poppins(
                                        fontSize: 16, color: Colors.white)),
                                Text(" $availableTickets",
                                    style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ],
                            ),
                            // Total Price Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total Price:",
                                    style: GoogleFonts.poppins(
                                        fontSize: 16, color: Colors.white)),
                                Text("৳ ${totalPrice.toStringAsFixed(2)}",
                                    style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Ticket Selector Text
                            Text("Select Tickets:",
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const SizedBox(height: 10),
                            // Ticket Selector Row with increment/decrement buttons
                            Container(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
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
                                        color: Colors.white,
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
                    // Modern "Book Ticket" Button inspired by Universe.io design
                    // Modern "Book Ticket" Button with #800080 color
                    Center(
                      child: InkWell(
                        onTap: _buyTicket,
                        borderRadius: BorderRadius.circular(12),
                        child: ClayContainer(
                          depth: 10,
                          borderRadius: 12,
                          color: const Color(0xFF100720), // Background color
                          child: Container(
                            width: 165,
                            height: 62,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(16), // 1rem ~16px
                              color:
                              const Color(0xFF800080), // Using Purple Color
                            ),
                            child: Text(
                              "Book Ticket",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
        ));
  }
}

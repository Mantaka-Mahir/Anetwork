import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TicketConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> event;
  final int ticketsBought;
  final bool couponApplied;
  final double totalPrice;

  const TicketConfirmationScreen({
    Key? key,
    required this.event,
    required this.ticketsBought,
    this.couponApplied = false,
    required this.totalPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String couponText = couponApplied ? "with discount applied" : "";
    return Scaffold(
      backgroundColor: Colors.redAccent,
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
                style: GoogleFonts.poppins(
                    fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "You bought $ticketsBought ticket(s) for the event: ${event['title']} $couponText",
                style: GoogleFonts.poppins(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Total amount: \$${totalPrice.toStringAsFixed(2)}",
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_current_event_screen.dart';

class CurrentEventScreen extends StatelessWidget {
  const CurrentEventScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      appBar: AppBar(
        title: Text(
          'Current Events',
          style: GoogleFonts.poppins(),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // Dummy data count
        itemBuilder: (context, index) {
          return _buildEventCard(
            context,
            'Event ${index + 1}',
            DateTime.now().add(Duration(days: index)),
            29.99,
            50,
            100,
          );
        },
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, String name, DateTime date,
      double price, int booked, int available) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EditCurrentEventScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date: ${date.toString().split(' ')[0]}',
                    style: GoogleFonts.poppins(),
                  ),
                  Text(
                    'Price: \$${price.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Booked: $booked',
                    style: GoogleFonts.poppins(),
                  ),
                  Text(
                    'Available: $available',
                    style: GoogleFonts.poppins(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
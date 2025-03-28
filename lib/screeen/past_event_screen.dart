import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clay_containers/clay_containers.dart';

class PastEventScreen extends StatelessWidget {
  const PastEventScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy data count: 5 past events
    return Scaffold(
      backgroundColor: Colors.redAccent,
      appBar: AppBar(
        title: Text(
          'Past Events',
          style: GoogleFonts.poppins(),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          // Create a dummy past date for each event
          DateTime pastDate = DateTime.now().subtract(Duration(days: (index + 1) * 10));
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildEventCard(
              context,
              "Past Event ${index + 1}",
              pastDate,
              29.99,
              50, // Dummy booked count
              0,  // No tickets available since event is past
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(
      BuildContext context,
      String name,
      DateTime date,
      double price,
      int booked,
      int available,
      ) {
    return ClayContainer(
      depth: 30,
      borderRadius: 20,
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${date.toLocal().toString().split(' ')[0]}',
                  style: GoogleFonts.poppins(),
                ),
                Text(
                  'Price: ৳${price.toStringAsFixed(2)}',
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
            const SizedBox(height: 8),
            Text(
              'This event is over. Editing is disabled.',
              style: GoogleFonts.poppins(
                color: Colors.redAccent,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

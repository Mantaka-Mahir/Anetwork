import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_event_screen.dart';

class EditCurrentEventScreen extends StatelessWidget {
  const EditCurrentEventScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Event Details',
          style: GoogleFonts.poppins(),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditEventScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEventHeader(),
            const SizedBox(height: 24),
            Text(
              'Booked Users',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildUsersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summer Festival 2025',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: July 15, 2025',
                  style: GoogleFonts.poppins(),
                ),
                Text(
                  'Price: \$29.99',
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tickets Booked: 50',
                  style: GoogleFonts.poppins(),
                ),
                Text(
                  'Available: 100',
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5, // Dummy data count
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: Text(
              'User ${index + 1}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'user${index + 1}@example.com',
                  style: GoogleFonts.poppins(),
                ),
                Text(
                  '+1 234 567 890${index}',
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            trailing: Text(
              '${index + 1} tickets',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      },
    );
  }
}
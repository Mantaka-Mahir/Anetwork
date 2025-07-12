import 'package:event_management_app/screeen/past_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'current_event_screen.dart';

class ManageEventScreen extends StatelessWidget {
  const ManageEventScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        title: Text(
          'Manage Events',
          style: GoogleFonts.poppins(),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildEventSection(
              context,
              'Current Events',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CurrentEventScreen(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildEventSection(
              context,
              'Past Events',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PastEventScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventSection(
      BuildContext context, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

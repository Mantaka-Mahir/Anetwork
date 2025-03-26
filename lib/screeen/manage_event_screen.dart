import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'current_event_screen.dart';

class ManageEventScreen extends StatelessWidget {
  const ManageEventScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Colors.blue,
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
              Colors.grey,
                  () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventSection(
      BuildContext context, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
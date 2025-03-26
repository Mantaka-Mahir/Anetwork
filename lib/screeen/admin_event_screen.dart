import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'manage_event_screen.dart';
import 'add_event_screen.dart';

class AdminEventScreen extends StatelessWidget {
  const AdminEventScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Event Management',
          style: GoogleFonts.poppins(),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildEventCard(
              context,
              'Manage Event',
              Icons.edit_calendar,
              Colors.blue,
                  () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageEventScreen(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildEventCard(
              context,
              'Add Event',
              Icons.add_circle_outline,
              Colors.green,
                  () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEventScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
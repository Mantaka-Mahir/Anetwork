import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clay_containers/clay_containers.dart';
import 'manage_event_screen.dart';
import 'add_event_screen.dart';

class AdminEventScreen extends StatefulWidget {
  const AdminEventScreen({Key? key}) : super(key: key);

  @override
  _AdminEventScreenState createState() => _AdminEventScreenState();
}

class _AdminEventScreenState extends State<AdminEventScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Start fade-in animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Modern AppBar with centered title and a deep purple background
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          'Event Management',
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      // Wrap the content in AnimatedOpacity for a subtle fade-in effect
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 500),
        child: Padding(
          padding: const EdgeInsets.all(20),
          // Use a Column with Expanded widgets so that each card fills available space
          child: Column(
            children: [
              Expanded(
                child: _buildSimpleCard(
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
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _buildSimpleCard(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Updated: Each navigation card now fills its Expanded area.
  Widget _buildSimpleCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: ClayContainer(
        depth: 20,
        borderRadius: 20,
        color: Colors.white,
        child: Container(
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
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          // Center the card's content both vertically and horizontally
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.white),
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
        ),
      ),
    );
  }
}

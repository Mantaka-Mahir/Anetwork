import 'package:event_management_app/screeen/admin_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clay_containers/clay_containers.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  bool isDarkMode = false;
  double opacityLevel = 0.0; // For fade-in animation

  @override
  void initState() {
    super.initState();
    // Start fade-in animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        opacityLevel = 1.0;
      });
    });
  }

  void _toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  /// Neumorphic Card Builder using ClayContainer
  Widget _buildAnimatedNavigationCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      String backgroundImageUrl,
      VoidCallback onTap,
      int index) {
    return AnimatedOpacity(
      opacity: opacityLevel,
      duration: Duration(milliseconds: 500 + index * 100),
      child: GestureDetector(
        onTap: onTap,
        child: ClayContainer(
          borderRadius: 20,
          depth: 40,
          spread: 2,
          color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: CachedNetworkImageProvider(backgroundImageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      // Use Material AppBar with custom styling instead of NeumorphicAppBar.
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
        elevation: 0,
        title: Row(
          children: [
            Center(child: Image.asset('assets/logo.png', height: 25)),
            const SizedBox(width: 16),
            Center(
              child: Text(
                'Attention Network',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _toggleDarkMode,
            icon: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Admin Dashboard',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount:
                  MediaQuery.of(context).size.width > 600 ? 3 : 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    _buildAnimatedNavigationCard(
                      context,
                      'Events',
                      Icons.event,
                      Colors.blue,
                      'https://tinyurl.com/5atfvs5y', // Image URL
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminEventScreen(),
                        ),
                      ),
                      0,
                    ),
                    _buildAnimatedNavigationCard(
                      context,
                      'Food',
                      Icons.restaurant,
                      Colors.orange,
                      'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
                          () {},
                      1,
                    ),
                    _buildAnimatedNavigationCard(
                      context,
                      'Merch',
                      Icons.shopping_bag,
                      Colors.purple,
                      'https://images.unsplash.com/photo-1441986300917-64674bd600d8',
                          () {},
                      2,
                    ),
                    _buildAnimatedNavigationCard(
                      context,
                      'Membership',
                      Icons.wallet_membership,
                      Colors.green,
                      'https://tinyurl.com/tsru8aat',
                          () {},
                      3,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

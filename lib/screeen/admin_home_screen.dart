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

  /// Updated Navigation Card Builder with Hero and fade transition.
  Widget _buildAnimatedNavigationCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      String backgroundImageUrl,
      VoidCallback onTap,
      int index,
      ) {
    return AnimatedOpacity(
      opacity: opacityLevel,
      duration: Duration(milliseconds: 500 + index * 100),
      child: GestureDetector(
        onTap: onTap,
        child: Hero(
          tag: title,
          child: ClayContainer(
            borderRadius: 20,
            depth: 40,
            spread: 2,
            color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
            child: Container(
              padding: const EdgeInsets.all(16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 40, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // You can add additional details (e.g., time range, price) here if needed.
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Vibrant red background for bold visual impact.
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            Center(child: Image.asset('assets/logo.png', height: 25)),
            const SizedBox(width: 16),
            Text(
              'Attention Network',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        // actions: [
        //   IconButton(
        //     onPressed: _toggleDarkMode,
        //     icon: Icon(
        //       isDarkMode ? Icons.dark_mode : Icons.light_mode,
        //       color: Colors.white,
        //     ),
        //   ),
        // ],
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
                color: Colors.white,
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
                    // Updated "Events" card with fade transition navigation.
                    _buildAnimatedNavigationCard(
                      context,
                      'Events',
                      Icons.event,
                      Colors.blue,
                      'https://tinyurl.com/4mdxuw5t',
                          () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 500),
                            pageBuilder: (_, __, ___) => const AdminEventScreen(),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      0,
                    ),
                    _buildAnimatedNavigationCard(
                      context,
                      'Food',
                      Icons.restaurant,
                      Colors.orange,
                      'https://tinyurl.com/5n75jpap',
                          () {},
                      1,
                    ),
                    _buildAnimatedNavigationCard(
                      context,
                      'Merch',
                      Icons.shopping_bag,
                      Colors.purple,
                      'https://tinyurl.com/58yyanwt',
                          () {},
                      2,
                    ),
                    _buildAnimatedNavigationCard(
                      context,
                      'Membership',
                      Icons.wallet_membership,
                      Colors.green,
                      'https://tinyurl.com/3xfwjjsc',
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

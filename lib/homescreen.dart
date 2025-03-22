import 'package:event_management_app/screeen/about_screen.dart';
import 'package:event_management_app/screeen/contact_screen.dart';
import 'package:event_management_app/screeen/events_screen.dart';
import 'package:event_management_app/screeen/food_screen.dart';
import 'package:event_management_app/screeen/log%20in.dart';

import 'package:event_management_app/screeen/membership_screen.dart';
import 'package:event_management_app/screeen/merch_screen.dart';
import 'package:event_management_app/screeen/privacy_policy_screen.dart';
import 'package:event_management_app/screeen/signup.dart';
import 'package:event_management_app/screeen/support_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const EventApp());
}

class EventApp extends StatelessWidget {
  const EventApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool isDarkMode = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final String _eventsBgUrl = 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30';
  final String _merchBgUrl = 'https://images.unsplash.com/photo-1441986300917-64674bd600d8';
  final String _foodBgUrl = 'https://images.unsplash.com/photo-1504674900247-0877df9cc836';

  // Social media links
  final String _facebookUrl = 'https://www.facebook.com/theattentionnetwork';
  final String _linkedinUrl = 'https://www.linkedin.com/company/the-attention-network-99';
  final String _instagramUrl = 'https://www.instagram.com/theattentionnetwork/';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Improved URL launcher with error handling.
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      )) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $url')),
      );
    }
  }

  // Method to navigate to different screens
  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            _buildOptionsGrid(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Image.asset(
                    'assets/eventhub_logo.png', // Use your uploaded logo
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.home, 'Home', const EventApp()),
            _buildDrawerItem(Icons.event, 'Events', EventsScreen()),
            _buildDrawerItem(Icons.card_membership, 'Membership', MembershipScreen()),
            _buildDrawerItem(Icons.shopping_bag, 'Merch', MerchScreen()),
            _buildDrawerItem(Icons.restaurant, 'Food', const FoodScreen()),
            _buildDrawerItem(Icons.contact_mail, 'Contact', const ContactScreen()),
            const Divider(),
            _buildDrawerItem(Icons.login, 'Log In', LoginScreen()),
            _buildDrawerItem(Icons.person_add, 'Sign Up', SignUpScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Widget screen) {
    return ListTile(
      leading: Icon(icon, color: isDarkMode ? Colors.white70 : Colors.black87),
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black87,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        _navigateToScreen(context, screen);
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      leading: MediaQuery.of(context).size.width <= 600
          ? IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      )
          : null,
      title: Row(
        children: [
          Image.asset(
            'assets/logo.png', // Place your logo in assets folder
            height: 25,
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => _navigateToScreen(context, const EventApp()),
            child: Text(
              'Attention Network',
              style: TextStyle(
                color: isDarkMode ? Colors.black : Colors.black,
              ),
            ),
          ),
        ],
      ),
      actions: [
        // NEW: Scanner Button added in the AppBar actions
        IconButton(
          icon: Icon(Icons.qr_code_scanner, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () {
            // Replace with your scanning functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Scanner pressed")),
            );
          },
        ),
        // Show additional nav buttons on larger screens
        if (MediaQuery.of(context).size.width > 600) ...[
          _buildNavButton('Home', const EventApp()),
          _buildNavButton('Events', EventsScreen()),
          _buildNavButton('Membership', MembershipScreen()),
          _buildNavButton('Merch', MerchScreen()),
          _buildNavButton('Food', FoodScreen()),
          _buildAuthButton('Log In', LoginScreen()),
          _buildAuthButton('Sign Up', SignUpScreen()),
        ],
      ],
    );
  }

  Widget _buildNavButton(String text, Widget screen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextButton(
        onPressed: () => _navigateToScreen(context, screen),
        child: Text(
          text,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButton(String text, Widget screen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        onPressed: () => _navigateToScreen(context, screen),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(_eventsBgUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Experience Amazing Events',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width > 600 ? 48 : 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Your one-stop platform for events, merchandise, and food ordering',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width > 600 ? 20 : 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => _navigateToScreen(context, EventsScreen()),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.blue,
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              textStyle: const TextStyle(fontSize: 18),
            ),
            child: const Text('Explore Events'),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: constraints.maxWidth > 900
                ? 3
                : constraints.maxWidth > 600
                ? 2
                : 1,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: constraints.maxWidth > 600 ? 1.2 : 1.5,
            children: [
              _buildOptionCard('Events', Icons.event, 'View Details → Purchase Tickets', Colors.blue, _eventsBgUrl, EventsScreen()),
              _buildOptionCard('Merch', Icons.shopping_bag, 'Browse & Purchase', Colors.green, _merchBgUrl, MerchScreen()),
              _buildOptionCard('Food', Icons.restaurant, 'View Menu → Order Food', Colors.orange, _foodBgUrl, FoodScreen()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOptionCard(String title, IconData icon, String description, Color color, String backgroundUrl, Widget screen) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: () => _navigateToScreen(context, screen),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              image: DecorationImage(
                image: NetworkImage(backgroundUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.6),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
      child: Column(
        children: [
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildFooterLink('About Us', const AboutScreen()),
              _buildFooterLink('Privacy Policy', const PrivacyPolicyScreen()),
              _buildFooterLink('Support', const SupportScreen()),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSocialIcon(FontAwesomeIcons.facebook, _facebookUrl),
                  _buildSocialIcon(FontAwesomeIcons.linkedin, _linkedinUrl),
                  _buildSocialIcon(FontAwesomeIcons.instagram, _instagramUrl),
                ],
              ),
              _buildDarkModeToggle(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text, Widget screen) {
    return TextButton(
      onPressed: () => _navigateToScreen(context, screen),
      child: Text(
        text,
        style: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String url) {
    return IconButton(
      icon: Icon(icon),
      onPressed: () => _launchUrl(url),
      color: isDarkMode ? Colors.white70 : Colors.black54,
    );
  }

  Widget _buildDarkModeToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isDarkMode = !isDarkMode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isDarkMode ? Colors.blue : Colors.grey[300],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: isDarkMode ? Colors.white : Colors.black54,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isDarkMode ? 'Dark' : 'Light',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

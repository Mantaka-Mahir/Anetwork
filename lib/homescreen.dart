import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'screeen/log in.dart';
import 'screeen/signup.dart';
import 'screeen/about_screen.dart';
import 'screeen/contact_screen.dart';
import 'screeen/events_screen.dart';
import 'screeen/food_screen.dart';
import 'screeen/membership_screen.dart';
import 'screeen/merch_screen.dart';
import 'screeen/profile_screen.dart';
import 'screeen/privacy_policy_screen.dart';
import 'screeen/support_screen.dart';

class EventApp extends StatefulWidget {
  const EventApp({Key? key}) : super(key: key);

  @override
  _EventAppState createState() => _EventAppState();
}

class _EventAppState extends State<EventApp> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  String _userName = '';
  bool _isLoading = true;
  bool isDarkMode = false;

  final String _eventsBgUrl = 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30';
  final String _merchBgUrl = 'https://images.unsplash.com/photo-1441986300917-64674bd600d8';
  final String _foodBgUrl = 'https://images.unsplash.com/photo-1504674900247-0877df9cc836';

  final String _facebookUrl = 'https://www.facebook.com/theattentionnetwork';
  final String _linkedinUrl = 'https://www.linkedin.com/company/the-attention-network-99';
  final String _instagramUrl = 'https://www.instagram.com/theattentionnetwork/';

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (mounted) {
          setState(() {
            _userName = userDoc.data()?['name'] ?? user.email?.split('@')[0] ?? 'User';
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _userName = user.email?.split('@')[0] ?? 'User';
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _userName = '';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error signing out')),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $url')),
      );
    }
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final user = _auth.currentUser;
    
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
            'assets/logo.png',
            height: 25,
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => _navigateToScreen(context, const EventApp()),
            child: Text(
              'Attention Network',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (!_isLoading && user != null) ...[
          Text(
            _userName,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
        ],
        IconButton(
          icon: Icon(
            Icons.person,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () {
            _navigateToScreen(context, const ProfileScreen());
          },
        ),
        if (user != null)
          IconButton(
            icon: Icon(Icons.logout, color: isDarkMode ? Colors.white : Colors.red),
            onPressed: _signOut,
          ),
        _buildDarkModeToggle(),
        if (MediaQuery.of(context).size.width > 600) ...[
          _buildNavButton('Home', const EventApp()),
          _buildNavButton('Events', EventsScreen()),
          _buildNavButton('Membership', MembershipScreen()),
          _buildNavButton('Merch', MerchScreen()),
          _buildNavButton('Food', const FoodScreen()),
          if (user == null) ...[
            _buildAuthButton('Login', const LoginScreen()),
            _buildAuthButton('Sign Up', const SignUpScreen()),
          ],
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

  Widget _buildDarkModeToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isDarkMode = !isDarkMode;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Icon(
          isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: _eventsBgUrl,
          height: MediaQuery.of(context).size.height * 0.7,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => Container(
            color: Colors.black54,
            child: Icon(Icons.error, color: Colors.white),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.7,
          width: double.infinity,
          color: Colors.black.withOpacity(0.5),
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
        ),
      ],
    );
  }

  Widget _buildOptionsGrid() {
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
              _buildOptionCard('Food', Icons.restaurant, 'View Menu → Order Food', Colors.orange, _foodBgUrl, const FoodScreen()),
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
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: backgroundUrl,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Container(
                    color: color.withOpacity(0.2),
                    child: Icon(Icons.error),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.6),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 24, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      textAlign: TextAlign.left,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
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

  Widget _buildDrawer() {
    final user = _auth.currentUser;
    
    return Drawer(
      child: Container(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.blue),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isLoading ? 'Loading...' : (user != null ? _userName : 'Guest User'),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  if (user != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      user.email ?? '',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _buildDrawerItem(Icons.event, 'Events', EventsScreen()),
            _buildDrawerItem(Icons.info, 'About', AboutScreen()),
            _buildDrawerItem(Icons.card_membership, 'Membership', MembershipScreen()),
            _buildDrawerItem(Icons.shopping_bag, 'Merch', MerchScreen()),
            _buildDrawerItem(Icons.restaurant, 'Food', const FoodScreen()),
            _buildDrawerItem(Icons.contact_mail, 'Contact', const ContactScreen()),
            const Divider(color: Colors.white24),
            if (user != null) ...[
              _buildDrawerItem(Icons.person, 'Profile', const ProfileScreen()),
              _buildDrawerItem(Icons.logout, 'Logout', null, onTap: _signOut),
            ] else ...[
              _buildDrawerItem(Icons.login, 'Login', const LoginScreen()),
              _buildDrawerItem(Icons.person_add, 'Sign Up', const SignUpScreen()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Widget? destination, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: isDarkMode ? Colors.white : Colors.black),
      title: Text(title, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
      onTap: onTap ?? () {
        Navigator.pop(context);
        if (destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            _buildOptionsGrid(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }
}

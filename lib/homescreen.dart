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
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class EventApp extends StatefulWidget {
  const EventApp({Key? key}) : super(key: key);

  @override
  _EventAppState createState() => _EventAppState();
}

class _EventAppState extends State<EventApp>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  String _userName = '';
  bool _isLoading = true;
  bool isDarkMode = false;
  late PageController _bannerPageController;
  Timer? _bannerTimer;
  int _currentBannerIndex = 0;

  // Company theme colors
  final Color _primaryRed = Color(0xFFE41E26); // Attention Network red
  final Color _primaryWhite = Colors.white;
  final Color _accentColor = Color(0xFFE41E26).withOpacity(0.8);

  // Banner images list
  final List<String> _bannerImages = [
    'https://i.ibb.co.com/KccCVmcq/488455986-122226720884196112-7459824431490570372-n.jpg',
    'https://i.postimg.cc/DZ5P31Bv/hmceventbanner.png',
    'https://i.postimg.cc/bJCwC6p8/488648065-122226905168196112-1814701038135143718-n.jpg',
  ];

  final String _facebookEventImageUrl =
      'https://www.facebook.com/photo/?fbid=122226720878196112&set=gm.1211641657424426';
  final String _merchBgUrl =
      'https://images.unsplash.com/photo-1441986300917-64674bd600d8';
  final String _foodBgUrl =
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836';

  final String _facebookUrl = 'https://www.facebook.com/theattentionnetwork';
  final String _linkedinUrl =
      'https://www.linkedin.com/company/the-attention-network-99';
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

    // Initialize banner page controller
    _bannerPageController = PageController();
    _startBannerTimer();

    // Listen for authentication state changes
    _auth.authStateChanges().listen((User? user) {
      if (mounted) {
        if (user != null) {
          _loadUserData();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _bannerPageController.dispose();
    _bannerTimer?.cancel();
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
            _userName =
                userDoc.data()?['name'] ?? user.email?.split('@')[0] ?? 'User';
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
      // Clear shared preferences for authentication
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.setBool('isAdmin', false);

      // Sign out from Firebase Auth
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

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_bannerPageController.hasClients) {
        _currentBannerIndex = (_currentBannerIndex + 1) % _bannerImages.length;
        _bannerPageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final user = _auth.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;

    return AppBar(
      elevation: 0,
      backgroundColor: isDarkMode ? Colors.black : _primaryWhite,
      leading: screenWidth <= 600
          ? IconButton(
              icon: Icon(Icons.menu, color: _primaryRed),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            )
          : null,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/logo.png',
            height: 25,
          ),
          const SizedBox(width: 8),
          if (screenWidth > 360)
            Flexible(
              child: GestureDetector(
                onTap: () => _navigateToScreen(context, const EventApp()),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attention',
                      style: TextStyle(
                        color: isDarkMode ? _primaryWhite : Colors.black,
                        fontSize: screenWidth < 400 ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        height: 0.9,
                      ),
                    ),
                    Text(
                      'Network',
                      style: TextStyle(
                        color: isDarkMode ? _primaryWhite : Colors.black,
                        fontSize: screenWidth < 400 ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      actions: [
        _buildDarkModeToggle(),
        if (screenWidth > 600) ...[
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
            color: isDarkMode ? _primaryWhite : _primaryRed,
            fontWeight: FontWeight.w500,
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
          foregroundColor: _primaryWhite,
          backgroundColor: _primaryRed,
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
          color: _primaryRed,
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    // Calculate responsive height based on screen size
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Adjust banner height for different screen sizes
    final bannerHeight = screenWidth < 600
        ? screenHeight * 0.4 // Mobile height
        : screenWidth < 900
            ? screenHeight * 0.5 // Tablet height
            : screenHeight * 0.7; // Desktop height

    return GestureDetector(
      onTap: () => _navigateToScreen(context, EventsScreen()),
      child: Container(
        width: double.infinity,
        height: bannerHeight,
        child: Stack(
          children: [
            // Page view for rotating banners
            PageView.builder(
              controller: _bannerPageController,
              onPageChanged: (index) {
                setState(() {
                  _currentBannerIndex = index;
                });
              },
              itemCount: _bannerImages.length,
              itemBuilder: (context, index) {
                // Use a container to maintain consistent dimensions
                return Container(
                  width: double.infinity,
                  height: bannerHeight,
                  child: CachedNetworkImage(
                    imageUrl: _bannerImages[index],
                    width: double.infinity,
                    height: bannerHeight,
                    fit: screenWidth < 600 ? BoxFit.contain : BoxFit.cover,
                    alignment: Alignment.center,
                    placeholder: (context, url) => Container(
                      color: Colors.transparent,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(_primaryRed),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.withOpacity(0.3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.error, color: Colors.white, size: 40),
                          SizedBox(height: 8),
                          Text(
                            "Image couldn't be loaded",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Page indicators
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _bannerImages.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentBannerIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
              _buildOptionCard('Events', Icons.event, '', Colors.blue,
                  _bannerImages[0], EventsScreen()),
              _buildOptionCard('Merch', Icons.shopping_bag, '', Colors.green,
                  _merchBgUrl, MerchScreen()),
              _buildOptionCard('Food', Icons.restaurant, '', Colors.orange,
                  _foodBgUrl, const FoodScreen()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOptionCard(String title, IconData icon, String description,
      Color color, String backgroundUrl, Widget screen) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: () => _navigateToScreen(context, screen),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Stack(
            children: [
              // Background image with clarity improvement
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: backgroundUrl,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_primaryRed),
                  )),
                  errorWidget: (context, url, error) => Container(
                    color: _primaryRed.withOpacity(0.2),
                    child: Icon(Icons.error, color: _primaryWhite),
                  ),
                ),
              ),
              // Content overlay - clear with just darkened bottom
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                    stops: [0.7, 1.0],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with icon
                    Row(
                      children: [
                        Icon(icon, size: 32, color: _primaryWhite),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: _primaryWhite,
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 3,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
      color: isDarkMode ? Colors.black : _primaryRed.withOpacity(0.05),
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
          color: isDarkMode ? _primaryWhite : _primaryRed,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String url) {
    return IconButton(
      icon: Icon(icon),
      onPressed: () => _launchUrl(url),
      color: isDarkMode ? _primaryWhite : _primaryRed,
    );
  }

  Widget _buildDrawer() {
    final user = _auth.currentUser;

    return Drawer(
      child: Container(
        color: isDarkMode ? Colors.black : _primaryWhite,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: _primaryRed,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child:
                        Icon(Icons.person, size: 40, color: Color(0xFFE41E26)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isLoading
                        ? 'Loading...'
                        : (user != null ? _userName : 'Guest User'),
                    style: TextStyle(
                      color: _primaryWhite,
                      fontSize: 18,
                    ),
                  ),
                  if (user != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      user.email ?? '',
                      style: TextStyle(
                        color: _primaryWhite.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _buildDrawerItem(Icons.event, 'Events', EventsScreen()),
            _buildDrawerItem(Icons.info, 'About', AboutScreen()),
            _buildDrawerItem(
                Icons.card_membership, 'Membership', MembershipScreen()),
            _buildDrawerItem(Icons.shopping_bag, 'Merch', MerchScreen()),
            _buildDrawerItem(Icons.restaurant, 'Food', const FoodScreen()),
            _buildDrawerItem(
                Icons.contact_mail, 'Contact', const ContactScreen()),
            const Divider(color: Colors.red),
            if (user != null) ...[
              _buildDrawerItem(Icons.person, 'Profile', const ProfileScreen()),
              _buildDrawerItem(Icons.logout, 'Logout', null, onTap: _signOut),
            ] else ...[
              _buildDrawerItem(Icons.login, 'Login', const LoginScreen()),
              _buildDrawerItem(
                  Icons.person_add, 'Sign Up', const SignUpScreen()),
            ],
            const Divider(color: Colors.red),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Follow Us',
                style: TextStyle(
                  color: isDarkMode ? _primaryWhite : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildSocialIcon(FontAwesomeIcons.facebook, _facebookUrl),
                  _buildSocialIcon(FontAwesomeIcons.linkedin, _linkedinUrl),
                  _buildSocialIcon(FontAwesomeIcons.instagram, _instagramUrl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Widget? destination,
      {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: _primaryRed),
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? _primaryWhite : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap ??
          () {
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
      backgroundColor: isDarkMode ? Colors.black : _primaryWhite,
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

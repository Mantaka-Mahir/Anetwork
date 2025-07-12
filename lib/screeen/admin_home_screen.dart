import 'package:event_management_app/screeen/admin_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/supabase_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  bool isDarkMode = false;
  double opacityLevel = 0.0; // For fade-in animation
  final _auth = FirebaseAuth.instance;
  final _supabaseService = SupabaseService();

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

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/signup',
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error signing out')),
      );
    }
  }
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      try {
        File file = File(image.path);
        
        // Validate file
        if (!file.existsSync()) {
          throw Exception('Image file does not exist');
        }
        
        final fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) { // 10MB limit
          throw Exception('Image file is too large (${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB). Maximum size is 10MB.');
        }
        
        // Use Supabase service
        String? imageUrl = await _supabaseService.uploadFile(
          file,
          folder: 'admin_uploads',
          bucket: 'admin_uploads',
        );
        
        if (imageUrl != null) {
          // Use the imageUrl as needed (e.g., save to Firestore)
          print('Image uploaded successfully to Supabase: $imageUrl');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image uploaded successfully to Supabase!')),
            );
          }
        } else {
          throw Exception('Failed to upload image to Supabase');
        }
      } catch (e) {
        print('Error uploading image: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
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
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: backgroundImageUrl,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      color: color.withOpacity(0.3),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: color.withOpacity(0.3),
                      child: Icon(Icons.error, color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black.withOpacity(0.4),
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
              ],
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _signOut,
          ),
          IconButton(
            icon: const Icon(Icons.cloud_upload, color: Colors.white),
            onPressed: _pickImage,
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

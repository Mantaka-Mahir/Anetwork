import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screeen/log in.dart';
import 'screeen/signup.dart';
import 'homescreen.dart';
import 'screeen/admin_home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Set preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Management App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        textTheme: GoogleFonts.poppinsTextTheme(),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthWrapper(),
      routes: {
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const EventApp(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// Authentication wrapper to handle authentication state
class AuthWrapper extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        // Check if we're still waiting for the auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.red),
            ),
          );
        }

        // User is signed in
        if (snapshot.hasData) {
          // Check if user is admin
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  ),
                );
              }

              if (userSnapshot.hasData && userSnapshot.data != null) {
                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>?;
                final bool isAdmin = userData?['isAdmin'] == true;

                // Save authentication state to shared preferences
                _saveAuthState(true, isAdmin);

                if (isAdmin) {
                  return AdminHomeScreen();
                } else {
                  return EventApp();
                }
              }

              // Default to normal user if we can't determine admin status
              return EventApp();
            },
          );
        }

        // User is not signed in
        _saveAuthState(false, false);
        return EventApp();
      },
    );
  }

  // Save authentication state to shared preferences
  Future<void> _saveAuthState(bool isLoggedIn, bool isAdmin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
    await prefs.setBool('isAdmin', isAdmin);
  }
}

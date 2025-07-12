import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFF2F2F2), // Light beige background
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ABOUT Section
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'ABOUT',
                        style: TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        'The Attention Network',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // JOURNEY Section
                Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'JOURNEY',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE36254), // Coral red color
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Attention Network was born from a passion for creativity and a desire to build a thriving community of artists, makers, and innovators. Founded in March 2024, our studio has quickly become a hub for collaboration, learning, and artistic expression in the heart of the city.',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'We believe in the power of shared spaces and collective creativity. Our mission is to provide a platform for diverse voices and talents to come together, learn from one another, and create something extraordinary.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // MISSION Section
                Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MISSION',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE36254), // Coral red color
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'We strive to empower professionals, entrepreneurs, and creatives by providing world-class coworking facilities, dynamic event spaces, and a strong network of like-minded individuals.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // VISION Section
                Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'VISION',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE36254), // Coral red color
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Our vision is to create a thriving ecosystem where creativity flourishes, ideas are exchanged freely, and innovation is nurtured. We aim to be the catalyst for a new wave of creative entrepreneurship in Bangladesh, fostering collaborations that transcend traditional boundaries.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // WHAT WE OFFER Section
                const Text(
                  'WHAT WE OFFER',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE36254), // Coral red color
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildOfferCard('Cafe',
                        'A vibrant space to connect, collaborate, and caffeinate.'),
                    _buildOfferCard('Coworking',
                        'Flexible workspaces designed for productivity and collaboration.'),
                    _buildOfferCard('Workshops',
                        'Learn new skills from industry experts in our hands-on workshops.'),
                    _buildOfferCard('Events',
                        'Attend inspiring talks, exhibitions, and networking events.'),
                    _buildOfferCard('Studio',
                        'Rent our fully-equipped studio spaces for your creative projects.'),
                    _buildOfferCard('Community',
                        'Join a diverse network of creatives and innovators.'),
                  ],
                ),
                const SizedBox(height: 16),

                // OUR COMMUNITY Section
                Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'OUR COMMUNITY',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE36254), // Coral red color
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'At Attention Network, we\'re proud to host a diverse community of creatives, from seasoned professionals to emerging talents. Our members come from various backgrounds, including visual arts, design, technology, and more. Together, we\'re building a collaborative ecosystem that fosters innovation and pushes creative boundaries.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // LEGAL INFORMATION Section
                Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LEGAL INFORMATION',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE36254), // Coral red color
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'The Attention Network operates under the following legal framework:',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        _buildBulletPoint(
                            'Company Name: The Attention Network Limited'),
                        _buildBulletPoint(
                            'Trade License Number: TRAD/DSCC/000000/2024'),
                        _buildBulletPoint(
                            'Registered Address: 99 Kazi Nazrul Islam Avenue, Dhaka Trade Centre, 16th Floor, Kawran Bazar, Dhaka'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // JOIN US Section
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'JOIN US',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE36254), // Coral red color
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Whether you\'re looking to learn, create, or connect, there\'s a place for you at Attention Network. Explore our upcoming events and become part of our vibrant community.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to events page or show more info
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE36254),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                        ),
                        child: const Text(
                          'Explore Events',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 30),
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

  Widget _buildOfferCard(String title, String description) {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFF2F2F2), // Light beige background
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // CONTACT Header
                Center(
                  child: Column(
                    children: const [
                      Text(
                        'CONTACT',
                        style: TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Get in Touch',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF666666),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),

                // Description Text
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                  child: Text(
                    'For questions, clarifications, or assistance, please reach out:',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF444444),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // ADDRESS Section
                Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ADDRESS',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE36254), // Coral red color
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Color(0xFFE36254),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'The Attention Network',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '99 Kazi Nazrul Islam Avenue',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    '(Dhaka Trade Centre), 16th Floor',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Kawran Bazar, Dhaka',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            _launchURL(
                                'https://maps.google.com/?q=99+Kazi+Nazrul+Islam+Avenue+Dhaka+Trade+Centre');
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'View on Maps',
                                style: TextStyle(
                                  color: Color(0xFFE36254),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.open_in_new,
                                color: Color(0xFFE36254),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // EMAIL Section
                Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'EMAIL',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE36254), // Coral red color
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            _launchURL('mailto:marketing@theattention.network');
                          },
                          child: Row(
                            children: const [
                              Icon(
                                Icons.email_outlined,
                                color: Color(0xFFE36254),
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'marketing@theattention.network',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // PHONE Section
                Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PHONE',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE36254), // Coral red color
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            _launchURL('tel:+8801334334176');
                          },
                          child: Row(
                            children: const [
                              Icon(
                                Icons.phone,
                                color: Color(0xFFE36254),
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '+880 133 433 4176',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.only(left: 32.0),
                          child: Text(
                            'Available during business hours',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // CONNECT WITH US Section
                Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CONNECT WITH US',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE36254), // Coral red color
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Follow us on social media for updates and announcements',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildSocialButton(
                              'https://linkedin.com/company/theattentionnetwork',
                              FontAwesomeIcons.linkedin,
                            ),
                            const SizedBox(width: 16),
                            _buildSocialButton(
                              'https://facebook.com/theattentionnetwork',
                              FontAwesomeIcons.facebook,
                            ),
                            const SizedBox(width: 16),
                            _buildSocialButton(
                              'https://instagram.com/theattentionnetwork',
                              FontAwesomeIcons.instagram,
                            ),
                            const SizedBox(width: 16),
                            _buildSocialButton(
                              'https://youtube.com/c/theattentionnetwork',
                              FontAwesomeIcons.youtube,
                            ),
                            const SizedBox(width: 16),
                            _buildSocialButton(
                              'https://tiktok.com/@theattentionnetwork',
                              FontAwesomeIcons.tiktok,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String url, IconData icon) {
    return InkWell(
      onTap: () => _launchURL(url),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: FaIcon(
            icon,
            color: const Color(0xFF666666),
            size: 20,
          ),
        ),
      ),
    );
  }
}

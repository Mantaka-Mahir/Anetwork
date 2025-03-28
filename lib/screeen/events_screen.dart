import 'package:event_management_app/widget/eventdetail.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clay_containers/clay_containers.dart';

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  int _currentCarouselIndex = 0;
  String _selectedFilter = 'UPCOMING';

  final List<String> _filters = ['UPCOMING', 'ALL'];

  final List<Map<String, dynamic>> _featuredEvents = [
    {
      'title': 'GAME NIGHT 2.0',
      'subtitle': 'SQUID GAME EDITION',
      'date': '06 FEB, THU',
      'time': '6:00-10:00PM',
      'image': 'https://images.unsplash.com/photo-1561034645-e6f28dcd5ac5',
    },
    {
      'title': 'CO-WORKING EXTRAVAGANZA',
      'subtitle': 'OPEN SPACE DAY',
      'date': '12 FEB, SUN',
      'time': '9:00AM - 5:00PM',
      'image': 'https://images.unsplash.com/photo-1556740749-887f6717d7e4',
    },
    {
      'title': 'NETWORKING NIGHT',
      'subtitle': 'Connect & Grow',
      'date': '20 FEB, MON',
      'time': '7:00PM - 11:00PM',
      'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
    },
  ];

  final List<Map<String, dynamic>> _events = [
    {
      'title': 'Falgun Games at The Attention',
      'date': '27 FEB',
      'time': 'THU, 6:00 PM - 9:00 PM',
      'image': 'https://images.unsplash.com/photo-1553481187-be93c21490a9',
    },
    {
      'title': 'Tech Talk: Future of AI',
      'date': '22 AUG',
      'time': 'WED, 5:00 PM - 7:00 PM',
      'image': 'https://images.unsplash.com/photo-1556740749-887f6717d7e4',
    },
    {
      'title': 'Networking Brunch',
      'date': '30 SEP',
      'time': 'SUN, 11:00 AM - 1:00 PM',
      'image': 'https://images.unsplash.com/photo-1556740749-887f6717d7e4',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red, // Bold red background
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            floating: false,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 400,
                      viewportFraction: 1.0,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentCarouselIndex = index;
                        });
                      },
                      autoPlay: true,
                    ),
                    items: _featuredEvents.map((event) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Hero(
                            tag: event['title'],
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(event['image']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event['title'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      event['subtitle'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final event = _events[index];
                  return Hero(
                    tag: event['title'],
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: Duration(milliseconds: 500),
                            pageBuilder: (_, __, ___) => EventDetail(event: event),
                            transitionsBuilder: (_, anim, __, child) {
                              return FadeTransition(
                                opacity: anim,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Card(
                        margin: EdgeInsets.all(8),
                        color: Color(0xFF1E1E1E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                event['image'],
                                height: double.infinity,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey,
                                    child: Icon(Icons.error, color: Colors.white),
                                  );
                                },
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.8),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 15,
                              left: 15,
                              right: 15,
                              child: Row(
                                children: [
                                  // Icon representing the plan type
                                  Icon(Icons.event, color: Colors.white, size: 20),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event['title'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${event['date']} | ${event['time']}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

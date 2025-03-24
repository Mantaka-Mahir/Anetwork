import 'package:event_management_app/widget/eventdetail.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 400,
                      viewportFraction: 1.0,
                      enlargeCenterPage: false,
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
                          return Container(
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
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          color: Colors.white, size: 16),
                                      SizedBox(width: 8),
                                      Text(
                                        '${event['date']} | ${event['time']}',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _featuredEvents.asMap().entries.map((entry) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentCarouselIndex == entry.key
                                ? Colors.red
                                : Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'EXPLORE EVENTS',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filters.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: FilterChip(
                            label: Text(_filters[index]),
                            selected: _selectedFilter == _filters[index],
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = _filters[index];
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: Colors.red,
                            labelStyle: GoogleFonts.poppins(
                              color: _selectedFilter == _filters[index]
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(20),
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final event = _events[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: EventCard(event: event),
                      );
                    },
                  ),
                  // Extra bottom padding to fix overflow
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>EventDetail(event: event)));// Navigate to event details if needed
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  event['image'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'],
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16),
                          SizedBox(width: 8),
                          Text(
                            '${event['date']} | ${event['time']}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
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
      ),
    );
  }
}

final List<Map<String, dynamic>> _events = [
  {
    'title': 'Falgun Games at The Attention',
    'date': '27 FEB',
    'time': 'THU, 6:00 PM - 9:00 PM',
    'image': 'https://images.unsplash.com/photo-1553481187-be93c21490a9',
  },
  {
    'title': 'Summer Soirée 2024',
    'date': '05 JUN',
    'time': 'FRI, 7:00 PM - 11:00 PM',
    'image': 'https://images.unsplash.com/photo-1556741533-f6acd647d2fb',
  },
  {
    'title': 'Art & Music Festival',
    'date': '15 JUL',
    'time': 'SAT, 4:00 PM - 10:00 PM',
    'image': 'https://images.unsplash.com/photo-1531266755785-cc8d48c7a468',
  },
  {
    'title': 'Tech Talk: Future of AI',
    'date': '22 AUG',
    'time': 'WED, 5:00 PM - 7:00 PM',
    'image': 'https://images.unsplash.com/photo-1581091012184-8e46c2a40331',
  },
  {
    'title': 'Networking Brunch',
    'date': '30 SEP',
    'time': 'SUN, 11:00 AM - 1:00 PM',
    'image': 'https://images.unsplash.com/photo-1556740749-887f6717d7e4',
  },
];

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

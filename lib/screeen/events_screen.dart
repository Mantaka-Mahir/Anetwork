import 'package:event_management_app/widget/eventdetail.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/event.dart';

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with WidgetsBindingObserver {
  int _currentCarouselIndex = 0;
  String _selectedFilter = 'UPCOMING';
  final List<String> _filters = ['UPCOMING', 'ALL'];

  // Cache for events data
  List<Event> _cachedEvents = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Keys for shared preferences cache
  static const String _eventsDataKey = 'events_data';
  static const String _eventsTimestampKey = 'events_timestamp';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize with cached data first then fetch from network
    _loadCachedEventsAndFetch();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh data when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _fetchEvents(silent: true);
    }
  }

  // Load events from local cache first for instant display
  Future<void> _loadCachedEventsAndFetch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString(_eventsDataKey);

      if (eventsJson != null) {
        final timestamp = prefs.getInt(_eventsTimestampKey) ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;

        // Parse cached data
        final List<dynamic> eventsList = jsonDecode(eventsJson);
        final List<Event> events = _parseEventsFromJson(eventsList);

        if (events.isNotEmpty) {
          setState(() {
            _cachedEvents = events;
            _isLoading = false;
          });

          // If cache is older than 5 minutes, refresh in background
          if (now - timestamp > 5 * 60 * 1000) {
            _fetchEvents(silent: true);
          }
        } else {
          // If cache is empty, fetch normally
          _fetchEvents();
        }
      } else {
        // No cache, fetch normally
        _fetchEvents();
      }
    } catch (e) {
      print('Error loading cached events: $e');
      _fetchEvents();
    }
  }

  // Parse the event list from JSON
  List<Event> _parseEventsFromJson(List<dynamic> eventsList) {
    try {
      return eventsList.map((item) {
        return Event(
          id: item['id'],
          name: item['name'],
          bannerUrl: item['bannerUrl'],
          startDate: DateTime.parse(item['startDate']),
          endDate: DateTime.parse(item['endDate']),
          price: item['price'].toDouble(),
          availableTickets: item['availableTickets'],
          createdAt: DateTime.parse(item['createdAt']),
        );
      }).toList();
    } catch (e) {
      print('Error parsing events from JSON: $e');
      return [];
    }
  }

  // Fetch events from Firestore
  Future<void> _fetchEvents({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .orderBy('startDate', descending: false)
          .get();

      final events = snapshot.docs
          .map((doc) => Event.fromMap(doc.id, doc.data()))
          .where((event) => event.isActive)
          .toList();

      // Save to state
      setState(() {
        _cachedEvents = events;
        _isLoading = false;
      });

      // Cache events to shared preferences
      _cacheEvents(events);

      // Pre-download images for smoother experience
      _preloadImages(events);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Cache events to shared preferences for offline/faster loading
  Future<void> _cacheEvents(List<Event> events) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert events to JSON-friendly format
      List<Map<String, dynamic>> jsonList = events
          .map((event) => {
                'id': event.id,
                'name': event.name,
                'bannerUrl': event.bannerUrl,
                'startDate': event.startDate.toIso8601String(),
                'endDate': event.endDate.toIso8601String(),
                'price': event.price,
                'availableTickets': event.availableTickets,
                'createdAt': event.createdAt.toIso8601String(),
              })
          .toList();

      // Save to SharedPreferences
      await prefs.setString(_eventsDataKey, jsonEncode(jsonList));
      await prefs.setInt(
          _eventsTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching events: $e');
    }
  }

  // Preload images for smoother scrolling experience
  void _preloadImages(List<Event> events) {
    for (var event in events) {
      precacheImage(
        CachedNetworkImageProvider(
          event.bannerUrl,
          cacheKey: 'event_banner_${event.id}',
        ),
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: RefreshIndicator(
        onRefresh: () => _fetchEvents(),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // Show placeholder UI with skeleton loading effect if loading for first time
    if (_isLoading && _cachedEvents.isEmpty) {
      return _buildLoadingPlaceholder();
    }

    // Show error with retry button
    if (_errorMessage != null && _cachedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_errorMessage',
              style: GoogleFonts.poppins(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _fetchEvents(),
              child: Text('Retry', style: GoogleFonts.poppins()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      );
    }

    // Show empty state if no events
    if (_cachedEvents.isEmpty) {
      return Center(
        child: Text(
          'No current events',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      );
    }

    // Use first 3 events as featured events for carousel or all if less than 3
    final featuredEvents = _cachedEvents.length > 3
        ? _cachedEvents.take(3).toList()
        : _cachedEvents;

    return CustomScrollView(
      physics: BouncingScrollPhysics(),
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
                    autoPlayInterval: Duration(seconds: 5),
                  ),
                  items: featuredEvents.map((event) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Hero(
                          tag: event.id,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                  event.bannerUrl,
                                  cacheKey: 'event_banner_${event.id}',
                                ),
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
                                    event.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "${event.startDate.toString().split(' ')[0]}",
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
                // Carousel indicators
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: featuredEvents.asMap().entries.map((entry) {
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentCarouselIndex == entry.key
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Loading indicator for silent refresh
                if (_isLoading && _cachedEvents.isNotEmpty)
                  Positioned(
                    top: 50,
                    right: 20,
                    child: Container(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Upcoming Events",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8, // Adjust for better proportions
                  ),
                  itemCount: _cachedEvents.length,
                  itemBuilder: (context, index) {
                    final event = _cachedEvents[index];
                    return Hero(
                      tag: "event_card_${event.id}",
                      child: GestureDetector(
                        onTap: () {
                          // Convert Event to Map for EventDetail
                          Map<String, dynamic> eventMap = {
                            'title': event.name,
                            'date': event.startDate.toString().split(' ')[0],
                            'time':
                                "${event.startDate.hour}:${event.startDate.minute.toString().padLeft(2, '0')}",
                            'image': event.bannerUrl,
                            'totalTickets': event.availableTickets +
                                0, // Add sold tickets when you have them
                            'availableTickets': event.availableTickets,
                            'ticketPrice': event.price,
                            'eventId': event
                                .id // Pass the event ID for ticket purchases
                          };

                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: Duration(milliseconds: 500),
                              pageBuilder: (_, __, ___) =>
                                  EventDetail(event: eventMap),
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
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: CachedNetworkImage(
                                  imageUrl: event.bannerUrl,
                                  fit: BoxFit.cover,
                                  cacheKey: 'event_thumbnail_${event.id}',
                                  memCacheWidth: 300, // Limit memory cache size
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[800],
                                    child: Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: Colors.grey[800],
                                    child:
                                        Icon(Icons.error, color: Colors.white),
                                  ),
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
                                    Icon(Icons.event,
                                        color: Colors.white, size: 20),
                                    SizedBox(width: 5),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event.name,
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${event.startDate.toString().split(' ')[0]}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Skeleton loading placeholder UI
  Widget _buildLoadingPlaceholder() {
    return CustomScrollView(
      physics: NeverScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 400,
          floating: false,
          pinned: true,
          backgroundColor: Colors.black,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: Colors.grey[800],
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shimmer effect for title
                Container(
                  width: 180,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 20),
                // Grid placeholder
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: 4, // Show 4 placeholders
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.all(8),
                      color: Colors.grey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

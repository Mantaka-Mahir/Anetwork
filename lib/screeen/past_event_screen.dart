import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/event.dart';

class PastEventScreen extends StatelessWidget {
  const PastEventScreen({Key? key}) : super(key: key);

  Stream<List<Event>> _getPastEvents() {
    return FirebaseFirestore.instance
        .collection('events')
        .orderBy('endDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Event.fromMap(doc.id, doc.data()))
              .where((event) => !event.isActive)
              .toList();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      appBar: AppBar(
        title: Text(
          'Past Events',
          style: GoogleFonts.poppins(),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Event>>(
        stream: _getPastEvents(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data ?? [];
          
          if (events.isEmpty) {
            return Center(
              child: Text(
                'No past events',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _buildEventCard(context, event);
            },
          );
        },
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Event event) {
    return ClayContainer(
      depth: 30,
      borderRadius: 20,
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Banner
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: CachedNetworkImage(
              imageUrl: event.bannerUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 150,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 150,
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Start Date: ${event.startDate.toString().split(' ')[0]}',
                      style: GoogleFonts.poppins(),
                    ),
                    Text(
                      'Price: ৳${event.price.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'End Date: ${event.endDate.toString().split(' ')[0]}',
                      style: GoogleFonts.poppins(),
                    ),
                    Text(
                      'Tickets: ${event.availableTickets}',
                      style: GoogleFonts.poppins(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This event is over. Editing is disabled.',
                  style: GoogleFonts.poppins(
                    color: Colors.redAccent,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

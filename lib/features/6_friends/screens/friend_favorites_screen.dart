import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../1_event/models/event_model.dart';
import '../../1_event/screens/event_detail_screen.dart';
import '../services/friend_service.dart';

class FriendFavoritesScreen extends StatefulWidget {
  final int friendId;
  final String friendUsername;

  const FriendFavoritesScreen({
    super.key,
    required this.friendId,
    required this.friendUsername,
  });

  @override
  State<FriendFavoritesScreen> createState() => _FriendFavoritesScreenState();
}

class _FriendFavoritesScreenState extends State<FriendFavoritesScreen> {
  final FriendService _friendService = FriendService();
  late Future<List<EventModel>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _loadFriendFavorites();
  }

  Future<List<EventModel>> _loadFriendFavorites() async {
    final List<Map<String, dynamic>> favoriteRows =
        await _friendService.getFavoritesForUser(widget.friendId);
    
    return favoriteRows.map((row) {
      try {
        final Map<String, dynamic> eventJson = jsonDecode(row['eventJson']);
        return EventModel.fromJson(eventJson);
      } catch (e) {
        print('Error parsing event JSON: $e');
        return null;
      }
    }).whereType<EventModel>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorit ${widget.friendUsername}'),
      ),
      body: FutureBuilder<List<EventModel>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Gagal memuat favorit: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text(
                    '${widget.friendUsername} tidak memiliki event favorit.'));
          }

          final List<EventModel> favoriteEvents = snapshot.data!;

          return ListView.builder(
            itemCount: favoriteEvents.length,
            itemBuilder: (context, index) {
              final event = favoriteEvents[index];
              return _buildEventCard(event); 
            },
          );
        },
      ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    // Format date from the simplified EventModel (localDate)
    String formattedDate = "Tanggal tidak tersedia";
    if (event.localDate.isNotEmpty && event.localDate != 'No Date') {
      try {
        DateTime date = DateTime.parse(event.localDate);
        formattedDate = DateFormat('d MMMM y', 'id_ID').format(date);
      } catch (e) {
        // jika parsing gagal, biarkan teks default
      }
    }

    // Use the single imageUrl field available in EventModel
    final imageUrl = event.imageUrl.isNotEmpty ? event.imageUrl : '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(event: event),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  imageUrl,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: Icon(Icons.broken_image,
                        color: Colors.grey[600], size: 40),
                  ),
                ),
              )
            else
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Icon(Icons.image, color: Colors.grey[600], size: 40),
              ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Show time and price range in a single row
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 14, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        event.localTime != 'No Time' ? event.localTime : '-',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Text(
                        '${event.currency} ${event.minPrice.toStringAsFixed(0)} - ${event.maxPrice.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Use venueName and venueCity from simplified EventModel
                  if (event.venueName.isNotEmpty || event.venueCity.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${event.venueName}, ${event.venueCity}',
                            style: Theme.of(context).textTheme.bodyMedium,
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
    );
  }
}
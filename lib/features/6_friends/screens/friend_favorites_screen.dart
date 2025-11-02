import 'dart:convert';
import 'package:flutter/material.dart';
import '../../1_event/models/event_model.dart';
import '../../1_event/screens/event_detail_screen.dart';
import '../services/friend_service.dart';
import '../../../core/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: AppColors.kBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.kPrimaryColor,
        elevation: 0,
        title: Text(
          'Acara Favorit ${widget.friendUsername}',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<List<EventModel>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat favorit: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text('${widget.friendUsername} tidak memiliki event favorit.'));
          }

          final List<EventModel> favoriteEvents = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              itemCount: favoriteEvents.length,
              itemBuilder: (context, index) {
                final event = favoriteEvents[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildEventCard(event),
                );
              },
            ),
          );
        },
      ),
    );
  }


   Widget _buildEventCard(EventModel event) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailScreen(event: event),
        ),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  event.imageUrl,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 80,
                    width: 80,
                    color: AppColors.kBackgroundColor,
                    child: Icon(
                      Icons.broken_image,
                      size: 40,
                      color: AppColors.kSecondaryTextColor,
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.venueCity != 'N/A'
                              ? event.venueCity
                              : event.venueCountry,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.localDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.kPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatCurrency(event.minPrice, event.currency),
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            color: AppColors.kPrimaryColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
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


  String _formatCurrency(double? price, String currency) {
    if (price == null) return 'Free';
    
    String symbol = '';
    switch (currency.toUpperCase()) {
      case 'USD':
        symbol = '\$';
        break;
      case 'IDR':
        symbol = 'Rp';
        break;
      case 'EUR':
        symbol = '€';
        break;
      case 'GBP':
        symbol = '£';
        break;
      default:
        symbol = currency;
    }

    if (price == 0) return 'Free';
    final priceStr = price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    );
    
    return '$symbol$priceStr';
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../1_event/models/event_model.dart';
import '../../1_event/screens/event_detail_screen.dart';
import '../../1_event/widgets/event_card.dart';
import '../../3_favorites/model/favorites_model.dart';
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
      final fav = FavoriteModel.fromJson(eventJson);
      return fav.toEventModel();
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
                  child: EventCard(
                    event: event,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailScreen(event: event),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
 
}
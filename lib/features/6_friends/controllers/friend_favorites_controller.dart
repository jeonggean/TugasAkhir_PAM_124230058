import 'dart:convert';
import 'package:flutter/material.dart';
import '../../1_event/models/event_model.dart';
import '../services/friend_service.dart';

class FriendFavoritesController extends ChangeNotifier {
  final FriendService _friendService = FriendService();
  final int friendId;

  FriendFavoritesController({required this.friendId});

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<EventModel> _favoriteEvents = [];
  List<EventModel> get favoriteEvents => _favoriteEvents;

  Future<void> loadFavorites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> favoriteRows =
          await _friendService.getFavoritesForUser(friendId);

      _favoriteEvents = favoriteRows.map((row) {
        try {
          final Map<String, dynamic> eventJson = jsonDecode(row['eventJson']);
          return EventModel.fromJson(eventJson);
        } catch (e) {
          print('Error parsing event JSON: $e');
          return null;
        }
      }).whereType<EventModel>().toList();

    } catch (e) {
      _error = 'Gagal memuat favorit: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
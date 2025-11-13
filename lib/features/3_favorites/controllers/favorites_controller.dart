import 'package:flutter/material.dart';
import '../../1_event/models/event_model.dart'; // Sesuaikan path jika perlu
import '../services/favorites_service.dart'; // Sesuaikan path jika perlu

// UBAH: Gunakan 'extends ChangeNotifier'
class FavoritesController extends ChangeNotifier {
  final FavoritesService _service = FavoritesService();
  List<EventModel> _favorites = [];
  bool _isLoading = false;

  List<EventModel> get favorites => _favorites;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    _favorites = await _service.getFavorites();
    _isLoading = false;
    notifyListeners(); 
  }

  Future<void> addToFavorites(EventModel event) async {
    await _service.addFavorite(event);
    await loadFavorites();
  }

  Future<void> removeFromFavorites(dynamic eventId) async {
    await _service.removeFavorite(eventId);
    await loadFavorites();
  }
}
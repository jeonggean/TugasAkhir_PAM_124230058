import 'package:flutter/foundation.dart';
import '../../1_event/models/event_model.dart';
import '../services/favorites_service.dart';

class FavoritesController extends ChangeNotifier {
  final FavoritesService _service = FavoritesService();

  List<EventModel> _favorites = [];
  bool _isLoading = false;

  List<EventModel> get favorites => _favorites;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('DEBUG CONTROLLER: Loading favorites...');
      _favorites = await _service.getFavorites();
      print('DEBUG CONTROLLER: Loaded ${_favorites.length} favorites');
      for (var fav in _favorites) {
        print('DEBUG CONTROLLER: - ${fav.name}');
      }
    } catch (e) {
      print('DEBUG CONTROLLER: Error loading favorites: $e');
      _favorites = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> removeFromFavorites(dynamic id) async {
    try {
      await _service.removeFavorite(id);
      await loadFavorites();
    } catch (e) {
      print("Gagal menghapus favorit: $e");
    }
  }
}

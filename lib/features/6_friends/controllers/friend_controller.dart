import 'package:flutter/material.dart';
import '../../2_auth/services/auth_service.dart';
import '../services/friend_service.dart';

class FriendsController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FriendService _friendService = FriendService();

  int? _currentUserId;
  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? get currentUser => _currentUser;

  bool _isLoadingFriends = true;
  bool get isLoadingFriends => _isLoadingFriends;

  List<Map<String, dynamic>> _friendsList = [];
  List<Map<String, dynamic>> get friendsList => _friendsList;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  Map<String, dynamic>? _searchResult;
  Map<String, dynamic>? get searchResult => _searchResult;

  String? _searchMessage;
  String? get searchMessage => _searchMessage;

  Future<void> loadInitialData() async {
    final id = await _authService.getCurrentUserId();
    if (id == null) return;
    _currentUserId = id;
    await loadCurrentUser();
    await _loadFriends();
  }

  Future<void> loadCurrentUser() async {
    if (_currentUserId == null) return;
    try {
      _currentUser = await _friendService.getUserById(_currentUserId!);
      notifyListeners();
    } catch (e) {
      print('Gagal memuat data pengguna: $e');
    }
  }

  Future<void> _loadFriends() async {
    if (_currentUserId == null) return;
    _isLoadingFriends = true;
    notifyListeners();
    try {
      _friendsList = await _friendService.getFriends(_currentUserId!);
    } catch (e) {
      print('Gagal memuat teman: $e');
    } finally {
      _isLoadingFriends = false;
      notifyListeners();
    }
  }

  Future<void> onSearchUser(String username) async {
    if (username.isEmpty) return;
    _isSearching = true;
    _searchResult = null;
    _searchMessage = null;
    notifyListeners();
    try {
      final user = await _friendService.findUserByUsername(username);
      if (user != null) {
        if (user['id'] == _currentUserId) {
          _searchMessage = 'Anda tidak dapat menambahkan diri sendiri.';
        } else {
          _searchResult = user;
        }
      } else {
        _searchMessage = 'User "$username" tidak ditemukan.';
      }
    } catch (e) {
      _searchMessage = 'Terjadi error: $e';
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<String> onAddFriend() async {
    if (_currentUserId == null || _searchResult == null) {
      return 'Terjadi error: User tidak valid.';
    }
    final int friendId = _searchResult!['id'];
    final String username = _searchResult!['username'];
    try {
      await _friendService.addFriend(_currentUserId!, friendId);
      _searchResult = null;
      notifyListeners();
      await _loadFriends();
      return '$username berhasil ditambahkan!';
    } catch (e) {
      return 'Gagal: ${e.toString().replaceFirst("Exception: ", "")}';
    }
  }

  Future<String> onRemoveFriend(int friendId, String username) async {
    if (_currentUserId == null) return 'Terjadi error: User tidak valid.';
    try {
      await _friendService.removeFriend(_currentUserId!, friendId);
      await _loadFriends();
      return '$username berhasil dihapus.';
    } catch (e) {
      return 'Gagal menghapus: $e';
    }
  }
}

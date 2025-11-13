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

  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> get pendingRequests => _pendingRequests;

  List<Map<String, dynamic>> _outgoingRequests = [];
  List<Map<String, dynamic>> get outgoingRequests => _outgoingRequests;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  Map<String, dynamic>? _searchResult;
  Map<String, dynamic>? get searchResult => _searchResult;

  String? _searchMessage;
  String? get searchMessage => _searchMessage;

  String? _searchRelation; // 'none' | 'self' | 'friends' | 'pending_in' | 'pending_out'
  String? get searchRelation => _searchRelation;

  Future<void> loadInitialData() async {
    
    final id = await _authService.getCurrentUserId();
    if (id == null) return;
    _currentUserId = id;
    _isLoadingFriends = true;
    notifyListeners();
    await refreshData();
  }

  Future<void> loadCurrentUser() async {
    if (_currentUserId == null) return;
    try {
      _currentUser = await _friendService.getUserById(_currentUserId!);
    } catch (e) {
      print('Error loading current user: $e');
    }
    notifyListeners();
  }

  Future<void> _loadFriends() async {
    if (_currentUserId == null) return;
    _isLoadingFriends = true;
    notifyListeners();
    try {
      _friendsList = await _friendService.getFriends(_currentUserId!);
      print('Friends loaded: ${_friendsList.length} friends');
    } catch (e) {
      print('Error loading friends: $e');
      _friendsList = [];
    } finally {
      _isLoadingFriends = false;
      notifyListeners();
    }
  }

  Future<void> _loadPendingRequests() async {
    if (_currentUserId == null) return;
    try {
      _pendingRequests = await _friendService.getPendingRequests(_currentUserId!);
    } catch (e) {
      print('Error loading pending requests: $e');
      _pendingRequests = [];
    }
    notifyListeners();
  }

  Future<void> _loadOutgoingRequests() async {
    if (_currentUserId == null) return;
    try {
      _outgoingRequests = await _friendService.getOutgoingRequests(_currentUserId!);
    } catch (e) {
      print('Error loading outgoing requests: $e');
      _outgoingRequests = [];
    }
    notifyListeners();
  }

  // Method untuk me-refresh semua data
  Future<void> refreshData() async {
    await loadCurrentUser();
    await Future.wait([
      _loadFriends(),
      _loadPendingRequests(),
      _loadOutgoingRequests(),
    ]);
  }

  Future<void> onSearchUser(String username) async {
    if (username.isEmpty) return;
    _isSearching = true;
    _searchResult = null;
    _searchMessage = null;
    _searchRelation = null;
    notifyListeners();

    try {
      final user = await _friendService.findUserByUsername(username);
      if (user == null) {
        _searchMessage = 'User "$username" tidak ditemukan.';
      } else {
        final status = await _friendService.getRelationStatus(_currentUserId!, user['id'] as int);
        _searchRelation = status;
        if (status == 'self') {
          _searchMessage = 'Ini adalah akun Anda sendiri.';
        } else {
          _searchResult = user;
        }
      }
    } catch (e) {
      _searchMessage = 'Terjadi error: $e';
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<String> onSendFriendRequest() async {
    if (_currentUserId == null || _searchResult == null) {
      return 'Terjadi error: User tidak valid.';
    }
    final receiverId = _searchResult!['id'] as int;
    try {
      await _friendService.sendFriendRequest(_currentUserId!, receiverId);
      await _loadOutgoingRequests();
      _searchRelation = 'pending_out';
      notifyListeners();
      return 'Permintaan pertemanan dikirim.';
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String> onAcceptFriend(int requesterId) async {
    if (_currentUserId == null) return 'Terjadi error: User tidak valid.';
    try {
      await _friendService.acceptFriendRequest(requesterId, _currentUserId!);
      await _loadFriends();
      await _loadPendingRequests();
      return 'Permintaan diterima.';
    } catch (e) {
      return 'Gagal menerima: $e';
    }
  }

  Future<String> onRejectFriend(int requesterId) async {
    if (_currentUserId == null) return 'Terjadi error: User tidak valid.';
    try {
      await _friendService.rejectFriendRequest(requesterId, _currentUserId!);
      await _loadPendingRequests();
      return 'Permintaan ditolak.';
    } catch (e) {
      return 'Gagal menolak: $e';
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

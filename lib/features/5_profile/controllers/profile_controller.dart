import 'package:flutter/material.dart';
import '../../2_auth/services/auth_service.dart';
import '../../4_post/services/post_service.dart';
import '../../6_friends/services/friend_service.dart';

class ProfileController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final PostService _postService = PostService();
  final FriendService _friendService = FriendService();

  String? username;
  int points = 0;
  int postCount = 0;
  int friendCount = 0;
  bool isLoading = true;

  // Load Data User
  Future<void> loadUserProfile() async {
    isLoading = true;
    notifyListeners();

    try {
      final name = await _authService.getCurrentUsername();
      final pts = await _authService.getCurrentUserPoints();
      final userId = await _authService.getCurrentUserId();
      
      int pCount = 0;
      int fCount = 0;
      if (userId != null) {
        pCount = await _postService.getPostCount(userId);
        fCount = await _friendService.getAcceptedFriendCount(userId);
      }

      username = name;
      points = pts;
      postCount = pCount;
      friendCount = fCount;
    } catch (e) {
      print("Error loading profile: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Logic Badge Sederhana
  String getBadgeName() {
    if (points >= 500) return "Sultan Event";
    if (points >= 200) return "Event Master";
    if (points >= 50) return "Event Explorer";
    return "Newbie";
  }
  
  Color getBadgeColor() {
    if (points >= 500) return Colors.purpleAccent;
    if (points >= 200) return Colors.amber; // Gold
    if (points >= 50) return Colors.grey;   // Silver
    return Colors.brown;                    // Bronze
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}

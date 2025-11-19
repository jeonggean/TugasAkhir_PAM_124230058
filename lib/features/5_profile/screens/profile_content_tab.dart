import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/app_colors.dart';
import '../../1_event/widgets/event_card.dart';
import '../../1_event/models/event_model.dart';
import '../../2_auth/services/auth_service.dart';
import '../../3_favorites/services/favorites_service.dart';
import '../../4_post/services/post_service.dart';
import '../../6_friends/services/friend_service.dart';

class ProfileContentTab extends StatefulWidget {
  final int? userId;

  const ProfileContentTab({super.key, this.userId});

  @override
  State<ProfileContentTab> createState() => _ProfileContentTabState();
}

class _ProfileContentTabState extends State<ProfileContentTab> {
  final PostService _postService = PostService();
  final FavoritesService _favoritesService = FavoritesService();
  final AuthService _authService = AuthService();
  final FriendService _friendService = FriendService();

  List<Map<String, dynamic>> _posts = [];
  List<EventModel> _favorites = [];
  String _ownerName = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final int? targetUserId = widget.userId ?? await _authService.getCurrentUserId();
      if (targetUserId != null) {
        final posts = await _postService.getPostsByUser(targetUserId);

        String name = "";
        if (widget.userId == null) {
          name = await _authService.getCurrentUsername() ?? "Me";
        } else {
          final userMap = await _friendService.getUserById(targetUserId);
          name = userMap?['username'] ?? "User";
        }

        List<EventModel> favorites;
        if (widget.userId == null) {
          favorites = await _favoritesService.getFavorites();
        } else {
          favorites = [];
        }

        if (mounted) {
          setState(() {
            _posts = posts;
            _favorites = favorites;
            _ownerName = name;
          });
        }
      }
    } catch (_) {} 
    finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return TabBarView(
      children: [
        _posts.isEmpty
            ? const Center(child: Text("Belum ada postingan"))
            : ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: _posts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return _buildOverlayPost(post);
                },
              ),
        _favorites.isEmpty
            ? const Center(child: Text("Belum ada favorit"))
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _favorites.length,
                itemBuilder: (context, index) => EventCard(event: _favorites[index]),
              ),
      ],
    );
  }

  Widget _buildOverlayPost(Map<String, dynamic> post) {
    String dateStr = "";
    try {
      final dt = DateTime.parse(post['createdAt']);
      dateStr = DateFormat('d MMM yyyy').format(dt);
    } catch (_) {
      dateStr = post['createdAt'].toString().substring(0, 10);
    }

    return Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[300],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            if (post['imagePath'] != null)
              Positioned.fill(
                child: Image.file(
                  File(post['imagePath']),
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      dateStr,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 16, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _ownerName,
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          shadows: [
                            const Shadow(color: Colors.black, blurRadius: 8, offset: Offset(1, 1))
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.kPrimaryColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                      ],
                    ),
                    child: Text(
                      post['eventId'] ?? 'Unknown Event',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post['caption'] ?? "",
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      shadows: [
                        const Shadow(color: Colors.black, blurRadius: 10, offset: Offset(1, 1)),
                        const Shadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 2)),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

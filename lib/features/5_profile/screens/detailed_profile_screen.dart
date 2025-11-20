import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_colors.dart';
import '../../2_auth/services/auth_service.dart';
import '../../6_friends/services/friend_service.dart';
import '../../4_post/services/post_service.dart';
import '../../4_post/screens/create_post_screen.dart';
import '../models/badge_model.dart';
import 'profile_content_tab.dart';

class DetailedProfileScreen extends StatefulWidget {
  final int? userId;

  const DetailedProfileScreen({super.key, this.userId});

  @override
  State<DetailedProfileScreen> createState() => _DetailedProfileScreenState();
}

class _DetailedProfileScreenState extends State<DetailedProfileScreen>
    with SingleTickerProviderStateMixin {

  // service yang dipake buat ambil data user, teman, dan postingan
  final AuthService _authService = AuthService();
  final FriendService _friendService = FriendService();
  final PostService _postService = PostService();
  
  late TabController _tabController;

  bool _isLoading = true;
  bool _isMe = false;

  String _displayUsername = "";
  int _displayPoints = 0;
  int _friendCount = 0;
  int _postCount = 0;
  int _currentUserId = 0;

  @override
  void initState() {
    super.initState();
    // setup tab bar buat Post & Favorit
    _tabController = TabController(length: 2, vsync: this);
    // load data awal profil
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // cek id user yang login
      final myId = await _authService.getCurrentUserId();
      if (myId == null) return;

      // kalau userId null → berarti lihat profil sendiri
      final int targetId = widget.userId ?? myId;
      final bool isMe = (targetId == myId);

      String username = "";
      int points = 0;

      // ambil data user yang lagi dibuka
      if (isMe) {
        username = await _authService.getCurrentUsername() ?? "User";
        points = await _authService.getCurrentUserPoints();
      } else {
        final userInfo = await _friendService.getUserInfo(targetId);
        if (userInfo != null) {
          username = userInfo['username'];
          points = userInfo['points'];
        } else {
          username = "Unknown";
        }
      }

      // hitung teman & postingannya
      final fCount = await _friendService.getAcceptedFriendCount(targetId);
      final pCount = await _postService.getPostCount(targetId);

      if (mounted) {
        setState(() {
          _isMe = isMe;
          _currentUserId = targetId;
          _displayUsername = username;
          _displayPoints = points;
          _friendCount = fCount;
          _postCount = pCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // popup konfirmasi buat hapus temen
  Future<void> _confirmRemoveFriend() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Teman"),
        content: Text(
            "Yakin mau hapus $_displayUsername dari daftar teman kamu?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final myId = await _authService.getCurrentUserId();
        if (myId != null) {
          await _friendService.removeFriend(myId, _currentUserId);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Teman berhasil dihapus")));
            Navigator.pop(context, true);
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal menghapus teman: $e")));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // badge user berdasarkan poin terbaru
    final badge = BadgeService.getBadgeForPoints(_displayPoints);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // bagian header atas (gradasi + info user)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.kPrimaryColor,
                  Color.lerp(AppColors.kPrimaryColor, Colors.black, 0.25)!
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5)),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [

                  // tombol back + judul profil
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          _isMe ? "Profil Saya" : "Profil Teman",
                          style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // isi data profil user
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [

                        // foto profil + nama + badge kecil
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.5),
                                      width: 2)),
                              child: const CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.person,
                                      size: 35, color: Colors.grey)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                            text: _displayUsername,
                                            style: GoogleFonts.nunito(
                                                fontSize: 22,
                                                fontWeight:
                                                    FontWeight.bold,
                                                color: Colors.white)),
                                        if (_isMe)
                                          TextSpan(
                                              text: " (You)",
                                              style: GoogleFonts.nunito(
                                                  fontSize: 14,
                                                  fontWeight:
                                                      FontWeight.normal,
                                                  color: Colors.white70,
                                                  fontStyle:
                                                      FontStyle.italic)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  
                                  // badge kecil di samping nama
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Colors.white.withOpacity(0.4)),
                                    ),
                                    child: Text(
                                      badge.name,
                                      style: GoogleFonts.nunito(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // statistik: teman / postingan / poin
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statItem("Teman", _friendCount),
                            _statItem("Post", _postCount),
                            _statItem("Poin", _displayPoints),
                          ],
                        )
                      ],
                    ),
                  ),
                  
                  // tombol buat postingan atau hapus teman
                  if (_isMe)
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 20, left: 24, right: 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const CreatePostScreen()));
                            _loadData();
                          },
                          icon: const Icon(
                              Icons.add_a_photo_rounded,
                              color: AppColors.kPrimaryColor),
                          label: const Text("Buat Postingan Baru",
                              style: TextStyle(
                                  color: AppColors.kPrimaryColor,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                            padding:
                                const EdgeInsets.symmetric(
                                    vertical: 12),
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 20, left: 24, right: 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _confirmRemoveFriend,
                          icon: const Icon(
                              Icons.person_remove_rounded,
                              color: Colors.white),
                          label: const Text("Hapus Teman",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                            padding:
                                const EdgeInsets.symmetric(
                                    vertical: 12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // bagian tab (berpindah antara postingan & favorit)
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.kPrimaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.kPrimaryColor,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold),
              tabs: const [
                Tab(
                    icon: Icon(Icons.camera_alt_rounded),
                    text: "Post"),
                Tab(
                    icon: Icon(Icons.favorite_rounded),
                    text: "Favorit"),
              ],
            ),
          ),
          
          // isi dari tab yg dipilih
          Expanded(
            child: ProfileContentTab(
              userId: _isMe ? null : _currentUserId,
              tabController: _tabController,
            ),
          ),
        ],
      ),
    );
  }

  // tampilan angka statistik
  Widget _statItem(String label, int value) {
    return Column(
      children: [
        Text(value.toString(),
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white)),
        Text(label,
            style: GoogleFonts.nunito(
                color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

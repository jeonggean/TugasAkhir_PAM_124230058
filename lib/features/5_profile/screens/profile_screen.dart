import 'dart:math';
import 'package:eventfinder/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../2_auth/services/auth_service.dart';
import '../../2_auth/screens/login_screen.dart';
import '../models/badge_model.dart';
import 'about_screen.dart';
import 'developer_info_screen.dart';
import 'feedback_screen.dart';
import 'redeem_code_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  late Future<Map<String, dynamic>> _userDataFuture;
  late AnimationController _badgeController;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _loadUserData();
    _badgeController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
  }

  Future<Map<String, dynamic>> _loadUserData() async {
    final username = await _authService.getCurrentUsername();
    final points = await _authService.getCurrentUserPoints();
    return {
      'username': username,
      'points': points,
    };
  }

  Future<void> _logout() async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin keluar dari akun ini?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Keluar",
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) {
      setState(() {
        _userDataFuture = _loadUserData();
      });
    });
  }

  @override
  void dispose() {
    _badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final username = snapshot.data?['username'] as String? ?? 'Pengguna';
          final points = snapshot.data?['points'] as int? ?? 0;
          final badge = BadgeService.getBadgeForPoints(points);

          return Column(
            children: [
              _buildProfileHeader(username, points, badge),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildProfileMenu(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(String username, int points, BadgeInfo badge) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.kPrimaryColor,
            Color.lerp(AppColors.kPrimaryColor, Colors.black, 0.25)!
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 58,
                backgroundColor: Colors.white.withOpacity(0.25),
                child: CircleAvatar(
                  radius: 54,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person,
                      size: 60, color: AppColors.kPrimaryColor),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                username,
                style: GoogleFonts.nunito(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "$points Poin",
                style: GoogleFonts.nunito(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: _badgeController,
                builder: (context, child) {
                  final pulse = 1 + 0.06 * sin(_badgeController.value * 2 * pi);
                  return Transform.scale(
                    scale: pulse,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(badge.icon, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            badge.name,
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildMenuTile(
              icon: Icons.confirmation_number_outlined,
              title: "Tukar Kode Voucher",
              onTap: () => _navigateTo(const RedeemCodeScreen()),
              color: AppColors.kPrimaryColor,
            ),
            Divider(color: Colors.grey.shade300),
            _buildMenuTile(
              icon: Icons.code,
              title: "Informasi Developer",
              onTap: () => _navigateTo(const DeveloperInfoScreen()),
              color: Colors.blueAccent,
            ),
            Divider(color: Colors.grey.shade300),
            _buildMenuTile(
              icon: Icons.feedback_outlined,
              title: "Saran & Kesan",
              onTap: () => _navigateTo(const FeedbackScreen()),
              color: Colors.orangeAccent,
            ),
            Divider(color: Colors.grey.shade300),
            _buildMenuTile(
              icon: Icons.info_outline,
              title: "Tentang Aplikasi",
              onTap: () => _navigateTo(AboutScreen()),
              color: Colors.green,
            ),
            Divider(color: Colors.grey.shade300),
            _buildMenuTile(
              icon: Icons.logout,
              title: "Keluar Akun",
              onTap: _logout,
              color: Colors.redAccent,
              isLogout: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
    bool isLogout = false,
  }) {
    final tileColor = color ?? AppColors.kPrimaryColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: tileColor.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: tileColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: tileColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color:
                      isLogout ? Colors.redAccent : AppColors.kSecondaryTextColor,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: isLogout
                  ? Colors.redAccent.withOpacity(0.7)
                  : AppColors.kSecondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }
}

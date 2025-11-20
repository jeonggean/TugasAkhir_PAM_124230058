import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_colors.dart';
import '../../2_auth/services/auth_service.dart';
import '../../4_post/screens/create_post_screen.dart';
import '../models/badge_model.dart';

class BadgeInfoScreen extends StatefulWidget {
  const BadgeInfoScreen({super.key});

  @override
  State<BadgeInfoScreen> createState() => _BadgeInfoScreenState();
}

class _BadgeInfoScreenState extends State<BadgeInfoScreen> {
  final AuthService _authService = AuthService();
  late Future<int> _pointsFuture;

  @override
  void initState() {
    super.initState();
    _refreshPoints(); // refresh poin tiap kali halaman dibuka
  }

  // fungsi buat nge-refresh poin user
  void _refreshPoints() {
    setState(() {
      _pointsFuture = _authService.getCurrentUserPoints();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.kPrimaryColor,
        title: Text(
          "Badge & Poin",
          style: GoogleFonts.nunito(
            color: Colors.white, 
            fontWeight: FontWeight.bold
          ),
        ),
        elevation: 0,
        foregroundColor: Colors.white,
      ),

      // nunggu data poin siap dulu
      body: FutureBuilder<int>(
        future: _pointsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final points = snapshot.data ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                _buildBadgeCard(points), // kartu badge user
                
                const SizedBox(height: 32),
                
                _buildActionSection(), // tombol buat nambah poin
                
                const SizedBox(height: 32),
                
                _buildBadgeInfo(points), // daftar badge lengkap
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBadgeCard(int points) {
    final badge = BadgeService.getBadgeForPoints(points);
    
    // cari badge selanjutnya kalo masih ada
    final nextBadge = BadgeService.allBadges.firstWhere(
      (b) => b.minPoints > badge.minPoints, 
      orElse: () => badge,
    );
    
    // progress menuju badge berikutnya
    final progress = badge == nextBadge
        ? 1.0
        : (points / nextBadge.minPoints).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.kPrimaryColor.withOpacity(0.95),
            AppColors.kPrimaryColor.withOpacity(0.7)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.kPrimaryColor.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          
          Icon(badge.icon, size: 80, color: badge.color), // icon badge
          
          const SizedBox(height: 16),
          
          Text("Badge Saat Ini",
              style: GoogleFonts.nunito(color: Colors.white70, fontSize: 16)),

          Text(
            badge.name,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            "$points Poin",
            style: GoogleFonts.nunito(
              color: Colors.white, 
              fontSize: 20, 
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // progress bar badge
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 7,
            borderRadius: BorderRadius.circular(8),
          ),
          
          const SizedBox(height: 6),
          
          // tulisan progres
          Text(
            badge == nextBadge
                ? "Kamu telah mencapai badge tertinggi!"
                : "Menuju ${nextBadge.name} (${(progress * 100).toStringAsFixed(0)}%)",
            style: GoogleFonts.nunito(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        
        Text(
          "Tambah Poin",
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.kTextColor,
          ),
        ),

        const SizedBox(height: 8),

        // info buat user cara dapet poin
        Text(
          "Bagikan momen event kamu untuk mendapatkan +10 poin setiap postingan!",
          style: GoogleFonts.nunito(color: Colors.grey[600]),
        ),

        const SizedBox(height: 16),
        
        // tombol pergi ke halaman buat posting
        ElevatedButton.icon(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePostScreen()),
            );

            // kalau berhasil ngepost, poinnya di-refresh
            if (result == true) {
              _refreshPoints();
            }
          },
          icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
          label: Text(
            "Buat Postingan Sekarang",
            style: GoogleFonts.nunito(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.kPrimaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeInfo(int points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Text(
          "Daftar Badge",
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.kTextColor,
          ),
        ),

        const SizedBox(height: 12),

        // kotak yang nampung semua badge
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),

          child: Column(
            children: BadgeService.allBadges.map((badge) {
              final achieved = points >= badge.minPoints; // cek udah kebuka apa belum

              return ListTile(
                leading: Icon(
                  badge.icon,
                  color: achieved ? badge.color : AppColors.kSecondaryTextColor,
                  size: 32,
                ),
                title: Text(
                  badge.name,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w600,
                    color: AppColors.kTextColor,
                  ),
                ),
                subtitle: Text(
                  achieved ? "Tercapai" : "Belum tercapai",
                  style: GoogleFonts.nunito(
                    color: achieved ? Colors.green : AppColors.kSecondaryTextColor,
                    fontWeight: achieved ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: Text(
                  "${badge.minPoints} pts",
                  style: GoogleFonts.nunito(
                    color: AppColors.kSecondaryTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

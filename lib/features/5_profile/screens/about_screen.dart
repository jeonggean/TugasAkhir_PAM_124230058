import 'dart:math';
import 'package:eventfinder/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.kPrimaryColor,
        elevation: 0,
        title: Text(
          'Tentang Aplikasi',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Logo
            Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale =
                      1 + 0.05 * sin(_pulseController.value * 2 * pi);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.kPrimaryColor.withOpacity(0.1),
                      ),
                      child: Icon(Icons.event_available_rounded,
                          size: 70, color: AppColors.kPrimaryColor),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Center(
              child: Text(
                'EventFinder: Temukan Acara & Dapatkan Reward!',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kPrimaryColor,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'EventFinder adalah aplikasi mobile yang membantu pengguna menemukan berbagai acara menarik seperti konser, festival, dan pameran dari seluruh dunia. '
              'Selain menjadi platform informasi acara, EventFinder juga memberikan sistem penghargaan interaktif berupa poin dan badge untuk meningkatkan keterlibatan pengguna.',
              style: GoogleFonts.nunito(
                fontSize: 17,
                color: AppColors.kTextColor,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),

            // Fitur utama
            Text(
              '✨ Fitur Unggulan',
              style: GoogleFonts.nunito(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: AppColors.kPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildFeatureItem(
                    Icons.manage_accounts,
                    'Autentikasi Aman dengan Enkripsi (Bcrypt)',
                  ),
                  _divider(),
                  _buildFeatureItem(
                    Icons.explore,
                    'Penemuan Acara Berdasarkan Lokasi (LBS & Global)',
                  ),
                  _divider(),
                  _buildFeatureItem(
                    Icons.search_rounded,
                    'Pencarian Acara via API Ticketmaster',
                  ),
                  _divider(),
                  _buildFeatureItem(
                    Icons.favorite_rounded,
                    'Simpan & Kelola Acara Favorit (SQLite)',
                  ),
                  _divider(),
                  _buildFeatureItem(
                    Icons.currency_exchange_rounded,
                    'Konversi Multi-Mata Uang Real-Time',
                  ),
                  _divider(),
                  _buildFeatureItem(
                    Icons.access_time_filled_rounded,
                    'Penyesuaian Zona Waktu Otomatis',
                  ),
                  _divider(),
                  _buildFeatureItem(
                    Icons.notifications_active_rounded,
                    'Notifikasi Pengingat Acara Favorit',
                  ),
                  _divider(),
                  _buildFeatureItem(
                    Icons.military_tech_rounded,
                    'Gamifikasi: Poin, Badge, & Kode Redeem',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Teknologi
            Text(
              '🧠 Teknologi yang Digunakan',
              style: GoogleFonts.nunito(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: AppColors.kPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildTechTag("Flutter (Dart)"),
            _buildTechTag("SQLite Database"),
            _buildTechTag("REST API (Ticketmaster)"),
            _buildTechTag("State Management dengan Controller"),
            _buildTechTag("Google Fonts & Material Design 3"),
            const SizedBox(height: 40),

            // Footer
            Center(
              child: Column(
                children: [
                  const Divider(thickness: 1, color: Colors.grey),
                  const SizedBox(height: 14),
                  Text(
                    "Versi Aplikasi 1.0.0",
                    style: GoogleFonts.nunito(
                      color: AppColors.kSecondaryTextColor,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Dikembangkan oleh Najwa Egi Fitriyani",
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w600,
                      color: AppColors.kTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "© 2025 EventFinder. All rights reserved.",
                    style: GoogleFonts.nunito(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: Colors.grey.shade300);
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppColors.kPrimaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: AppColors.kPrimaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.kTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechTag(String tech) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.kPrimaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tech,
        style: GoogleFonts.nunito(
          color: AppColors.kPrimaryColor,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
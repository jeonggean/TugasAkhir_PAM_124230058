import 'package:eventfinder/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeveloperInfoScreen extends StatelessWidget {
  const DeveloperInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Informasi Developer"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 80,
              backgroundImage: AssetImage('assets/images/dev_profile.jpg'),
            ),
            const SizedBox(height: 24),
            Text(
              "Najwa Egi Fitriyani",
              style: GoogleFonts.nunito(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.kTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "UPN Veteran Yogyakarta",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 18,
                color: AppColors.kSecondaryTextColor,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: AppColors.kCardColor,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: [
                  _buildInfoTile(
                    icon: Icons.person_outline,
                    title: "Nama Lengkap",
                    subtitle: " Najwa Egi Fitriyani",
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),
                  _buildInfoTile(
                    icon: Icons.school_outlined,
                    title: "NIM",
                    subtitle: "124230058",
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),
                  _buildInfoTile(
                    icon: Icons.class_outlined,
                    title: "Kelas",
                    subtitle: "SI-B",
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),
                  _buildInfoTile(
                    icon: Icons.email_outlined,
                    title: "Email",
                    subtitle: "najwaegi@gmail.com",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: AppColors.kPrimaryColor,
        size: 28,
      ),
      title: Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 16,
          color: AppColors.kSecondaryTextColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.kTextColor,
        ),
      ),
    );
  }
}
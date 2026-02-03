import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo & Name
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.school,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              AppStrings.appName,
              style: AppTextStyles.heading1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.appTagline,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // App Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Tentang ETutor',
                          style: AppTextStyles.heading3,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'ETutor adalah platform mobile yang menghubungkan siswa dengan tutor profesional. '
                      'Aplikasi ini memudahkan siswa untuk mencari tutor berkualitas, membuat booking, '
                      'dan memberikan review setelah sesi pembelajaran.',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.check_circle, 'Tutor Berpengalaman'),
                    _buildInfoRow(Icons.check_circle, 'Jadwal Fleksibel'),
                    _buildInfoRow(Icons.check_circle, 'Harga Terjangkau'),
                    _buildInfoRow(Icons.check_circle, 'Review & Rating Transparan'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Team Members Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.people_outline,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Tim Pengembang',
                          style: AppTextStyles.heading3,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tugas Besar Pemrograman Mobile 2',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const Text(
                      'TIF RP 23 CID A',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    _buildMemberCard(
                      'Daniel Desmanto Nugraha',
                      '23552011055',
                      Icons.person,
                    ),
                    _buildMemberCard(
                      'SULASTIAN SETIADI',
                      '23552011342',
                      Icons.person,
                    ),
                    _buildMemberCard(
                      'Syifa Aulia Fitri',
                      '23552011013',
                      Icons.person,
                    ),
                    _buildMemberCard(
                      'Dikdik Nawa Cendekia Agung',
                      '23552011240',
                      Icons.person,
                    ),
                    _buildMemberCard(
                      'Wildam Pramudiya Alif',
                      '23552011235',
                      Icons.person,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // University Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.school_outlined,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Universitas Teknologi Bandung',
                            style: AppTextStyles.heading3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Departemen Bisnis Digital',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Copyright Card
            Card(
              color: AppColors.primaryColor.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.copyright_outlined,
                      color: AppColors.primaryColor,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Copyright © 2026 ETutor',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Made with ❤️ by\nDaniel Desmanto, Sulastian, Syifa,\nDikdik, Wildam',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ujian Akhir Semester - Pemrograman Mobile 2',
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tanggal: ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime(2026, 1, 12))}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Version
            Text(
              'Version 1.0.0',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.successColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(String name, String npm, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryColor.withOpacity(0.1),
            child: Icon(
              icon,
              color: AppColors.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  npm,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DateFormat {
  final String pattern;
  final String locale;

  DateFormat(this.pattern, this.locale);

  String format(DateTime date) {
    // Simple date formatting
    return '${date.day} Januari ${date.year}';
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../services/api_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String? _errorMessage;

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final dateFormat = DateFormat('dd MMM yyyy HH:mm', 'id_ID');

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getStatistics();

      if (response['success'] == true) {
        setState(() {
          _stats = response['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Gagal memuat laporan';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.dangerColor),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStatistics,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    final totalUsers = _stats!['total_users'] ?? 0;
    final totalTutors = _stats!['total_tutors'] ?? 0;
    final totalStudents = _stats!['total_students'] ?? 0;
    final totalBookings = _stats!['total_bookings'] ?? 0;
    final pendingTutors = _stats!['pending_tutors'] ?? 0;
    final approvedTutors = _stats!['approved_tutors'] ?? 0;
    final totalRevenue = _stats!['total_revenue'] ?? 0;
    final pendingBookings = _stats!['pending_bookings'] ?? 0;
    final completedBookings = _stats!['completed_bookings'] ?? 0;
    final recentBookings = _stats!['recent_bookings'] as List<dynamic>? ?? [];

    // Hitung persentase
    final double tutorApprovalRate =
        totalTutors > 0 ? (approvedTutors / totalTutors) * 100 : 0;
    final double bookingCompletionRate =
        totalBookings > 0 ? (completedBookings / totalBookings) * 100 : 0;

    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Revenue Hero Card ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF56ab2f), Color(0xFFa8e063)],
                ),
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.attach_money, color: Colors.white, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Total Revenue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currencyFormat.format(totalRevenue),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'dari $totalBookings total booking',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── Pengguna Overview ───
            _buildSectionTitle('Pengguna'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Pengguna',
                    totalUsers.toString(),
                    Icons.people,
                    AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Siswa',
                    totalStudents.toString(),
                    Icons.person,
                    AppColors.infoColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Tutor',
                    totalTutors.toString(),
                    Icons.school,
                    AppColors.secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ─── Tutor Stats ───
            _buildSectionTitle('Statistik Tutor'),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMiniStat('Pending', pendingTutors, AppColors.warningColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMiniStat('Approved', approvedTutors, AppColors.successColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMiniStat(
                            'Rejected',
                            totalTutors - approvedTutors - pendingTutors,
                            AppColors.dangerColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress Bar: Approval Rate
                    _buildProgressBar(
                      label: 'Tingkat Approval Tutor',
                      value: tutorApprovalRate,
                      color: AppColors.successColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ─── Booking Stats ───
            _buildSectionTitle('Statistik Booking'),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMiniStat('Total', totalBookings, AppColors.primaryColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMiniStat('Pending', pendingBookings, AppColors.warningColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMiniStat('Selesai', completedBookings, AppColors.successColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress Bar: Completion Rate
                    _buildProgressBar(
                      label: 'Tingkat Penyelesaian Booking',
                      value: bookingCompletionRate,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ─── Recent Bookings ───
            _buildSectionTitle('Booking Terbaru'),
            const SizedBox(height: 12),
            if (recentBookings.isEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Belum ada booking',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                  ),
                ),
              )
            else
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                ),
                child: Column(
                  children: recentBookings.asMap().entries.map((entry) {
                    final index = entry.key;
                    final booking = entry.value;
                    final isLast = index == recentBookings.length - 1;
                    return Column(
                      children: [
                        _buildRecentBookingTile(booking as Map<String, dynamic>),
                        if (!isLast) const Divider(height: 1),
                      ],
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── Section Title ───
  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.heading3);
  }

  // ─── Stat Card (Pengguna overview) ───
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Mini Stat (di dalam card tutor / booking) ───
  Widget _buildMiniStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  // ─── Progress Bar ───
  Widget _buildProgressBar({
    required String label,
    required double value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 10,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ─── Recent Booking Tile ───
  Widget _buildRecentBookingTile(Map<String, dynamic> booking) {
    final status = (booking['status'] ?? '').toString().toLowerCase();
    final statusColor = _getBookingStatusColor(status);
    final statusLabel = _getBookingStatusLabel(status);
    final studentName = booking['student_name'] ?? '-';
    final tutorName = booking['tutor_name'] ?? '-';
    final mataPelajaran = booking['mata_pelajaran'] ?? '-';
    final totalBiaya = booking['total_biaya'] != null
        ? double.parse(booking['total_biaya'].toString())
        : 0.0;

    String tanggalText = '-';
    if (booking['created_at'] != null) {
      try {
        final dt = DateTime.parse(booking['created_at'].toString());
        tanggalText = dateFormat.format(dt);
      } catch (_) {
        tanggalText = booking['created_at'].toString();
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nomor / Ikon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(Icons.book_outlined, size: 20, color: statusColor),
            ),
          ),
          const SizedBox(width: 14),

          // Konten
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      mataPelajaran,
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$studentName → $tutorName',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tanggalText, style: AppTextStyles.bodySmall),
                    Text(
                      currencyFormat.format(totalBiaya),
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.successColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBookingStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warningColor;
      case 'confirmed':
        return AppColors.infoColor;
      case 'selesai':
        return AppColors.successColor;
      case 'batal':
        return AppColors.dangerColor;
      default:
        return AppColors.textLight;
    }
  }

  String _getBookingStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'selesai':
        return 'Selesai';
      case 'batal':
        return 'Dibatalkan';
      default:
        return status;
    }
  }
}
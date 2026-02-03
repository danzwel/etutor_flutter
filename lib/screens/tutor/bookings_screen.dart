import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class TutorBookingsScreen extends StatefulWidget {
  const TutorBookingsScreen({super.key});

  @override
  State<TutorBookingsScreen> createState() => _TutorBookingsScreenState();
}

class _TutorBookingsScreenState extends State<TutorBookingsScreen> {
  List<Booking> _bookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final tutorId = authProvider.profileId;

    if (tutorId == null) {
      setState(() {
        _errorMessage = 'Tutor ID tidak ditemukan';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getTutorBookings(tutorId);

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        setState(() {
          _bookings = data.map((json) => Booking.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Gagal memuat data';
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

  Future<void> _updateBookingStatus(Booking booking, String newStatus) async {
    String message;
    Color color;

    switch (newStatus) {
      case 'confirmed':
        message = 'Apakah Anda yakin ingin mengkonfirmasi booking ini?';
        color = AppColors.successColor;
        break;
      case 'selesai':
        message = 'Tandai booking ini sebagai selesai?';
        color = AppColors.infoColor;
        break;
      case 'batal':
        message = 'Apakah Anda yakin ingin membatalkan booking ini?';
        color = AppColors.dangerColor;
        break;
      default:
        return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: color),
            child: const Text('Ya'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await ApiService.updateBookingStatus(
        booking.id,
        newStatus,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status booking berhasil diupdate'),
            backgroundColor: AppColors.successColor,
          ),
        );
        _loadBookings();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Gagal mengupdate status'),
            backgroundColor: AppColors.dangerColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: AppColors.dangerColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.dangerColor,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBookings,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: AppColors.textLight.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada booking masuk',
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Booking dari siswa akan muncul di sini',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          return _buildBookingCard(booking);
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    Color statusColor;
    switch (booking.status.toLowerCase()) {
      case 'confirmed':
        statusColor = AppColors.successColor;
        break;
      case 'selesai':
        statusColor = AppColors.infoColor;
        break;
      case 'batal':
        statusColor = AppColors.dangerColor;
        break;
      default:
        statusColor = AppColors.warningColor;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.studentName ?? 'Siswa',
                        style: AppTextStyles.heading3.copyWith(fontSize: 16),
                      ),
                      if (booking.studentSekolah != null)
                        Text(
                          booking.studentSekolah!,
                          style: AppTextStyles.bodySmall,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    booking.statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Details
            _buildDetailRow(
              Icons.book_outlined,
              'Mata Pelajaran',
              booking.mataPelajaran ?? '-',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.calendar_today_outlined,
              'Tanggal',
              booking.tanggalBooking != null
                  ? DateFormat('dd MMM yyyy', 'id_ID')
                      .format(DateTime.parse(booking.tanggalBooking!))
                  : '-',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.access_time_outlined,
              'Jam',
              booking.jam ?? '-',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.timer_outlined,
              'Durasi',
              '${booking.durasi} Jam',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.payments_outlined,
              'Total Biaya',
              booking.totalBiaya != null
                  ? currencyFormat.format(booking.totalBiaya)
                  : '-',
            ),

            // Actions
            if (booking.status.toLowerCase() == 'pending') ...[
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateBookingStatus(booking, 'batal'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.dangerColor,
                        side: const BorderSide(color: AppColors.dangerColor),
                      ),
                      child: const Text('Tolak'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => _updateBookingStatus(booking, 'confirmed'),
                      child: const Text('Konfirmasi'),
                    ),
                  ),
                ],
              ),
            ],

            if (booking.status.toLowerCase() == 'confirmed') ...[
              const Divider(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _updateBookingStatus(booking, 'selesai'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successColor,
                  ),
                  child: const Text('Tandai Selesai'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textLight),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textLight,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

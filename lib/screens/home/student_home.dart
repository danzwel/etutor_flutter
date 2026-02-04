import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../models/booking_model.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import '../student/find_tutor_screen.dart';
import '../student/my_bookings_screen.dart';
import '../about/about_screen.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  Widget _currentScreen = const StudentDashboard();
  String _currentTitle = 'Dashboard';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final student = authProvider.profile as Student?;
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTitle),
        elevation: 2,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Drawer Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Text(
                        student?.namaLengkap.substring(0, 1).toUpperCase() ?? 'S',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      student?.namaLengkap ?? user?.username ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (student?.sekolah != null)
                      Text(
                        student!.sekolah!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Student',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Menu Items
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              selected: _currentTitle == 'Dashboard',
              selectedTileColor: AppColors.primaryColor.withOpacity(0.1),
              onTap: () {
                setState(() {
                  _currentScreen = const StudentDashboard();
                  _currentTitle = 'Dashboard';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Cari Tutor'),
              selected: _currentTitle == 'Cari Tutor',
              selectedTileColor: AppColors.primaryColor.withOpacity(0.1),
              onTap: () {
                setState(() {
                  _currentScreen = const FindTutorScreen();
                  _currentTitle = 'Cari Tutor';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.book_outlined),
              title: const Text('Booking Saya'),
              selected: _currentTitle == 'Booking Saya',
              selectedTileColor: AppColors.primaryColor.withOpacity(0.1),
              onTap: () {
                setState(() {
                  _currentScreen = const MyBookingsScreen();
                  _currentTitle = 'Booking Saya';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Tentang'),
              selected: _currentTitle == 'Tentang',
              selectedTileColor: AppColors.primaryColor.withOpacity(0.1),
              onTap: () {
                setState(() {
                  _currentScreen = const AboutScreen();
                  _currentTitle = 'Tentang';
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.dangerColor),
              title: const Text(
                'Keluar',
                style: TextStyle(color: AppColors.dangerColor),
              ),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Konfirmasi'),
                    content: const Text('Apakah Anda yakin ingin keluar?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.dangerColor,
                        ),
                        child: const Text('Keluar'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  await authProvider.logout();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: _currentScreen,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STUDENT DASHBOARD - COMPLETE REDESIGN
// ═══════════════════════════════════════════════════════════════════════════

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  List<Booking> _bookings = [];
  List<Tutor> _recommendedTutors = [];
  bool _isLoading = true;
  String? _errorMessage;

  int _totalBookings = 0;
  int _upcomingBookings = 0;
  int _completedBookings = 0;

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final student = authProvider.profile as Student?;

    if (student == null) {
      setState(() {
        _errorMessage = 'Student profile not found';
        _isLoading = false;
      });
      return;
    }

    try {
      // Load bookings
      final bookingResponse = await ApiService.getStudentBookings(student.id);
      
      // Load recommended tutors
      final tutorResponse = await ApiService.getTutors();

      if (bookingResponse['success'] == true) {
        final List<dynamic> data = bookingResponse['data'] ?? [];
        _bookings = data.map((json) => Booking.fromJson(json)).toList();

        // Calculate stats
        _totalBookings = _bookings.length;
        _upcomingBookings = _bookings
            .where((b) => b.status == 'pending' || b.status == 'confirmed')
            .length;
        _completedBookings =
            _bookings.where((b) => b.status == 'selesai').length;
      }

      if (tutorResponse['success'] == true) {
        final List<dynamic> data = tutorResponse['data'] ?? [];
        final tutors = data.map((json) => Tutor.fromJson(json)).toList();
        
        // Filter approved tutors and take top 3 by rating
        _recommendedTutors = tutors
            .where((t) => t.status == 'approved')
            .toList()
          ..sort((a, b) => (b.ratingAvg ?? 0).compareTo(a.ratingAvg ?? 0));
        
        if (_recommendedTutors.length > 3) {
          _recommendedTutors = _recommendedTutors.sublist(0, 3);
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final student = authProvider.profile as Student?;

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
              onPressed: _loadData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Welcome Header ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Text(
                      student?.namaLengkap.substring(0, 1).toUpperCase() ?? 'S',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selamat Datang,',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          student?.namaLengkap ?? 'Student',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── Stats Cards ───
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Bookings',
                    _totalBookings.toString(),
                    Icons.book,
                    AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Upcoming',
                    _upcomingBookings.toString(),
                    Icons.pending_actions,
                    AppColors.warningColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    _completedBookings.toString(),
                    Icons.check_circle,
                    AppColors.successColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(height: 110), // Spacer
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ─── Upcoming Bookings ───
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Upcoming Bookings', style: AppTextStyles.heading3),
                if (_upcomingBookings > 0)
                  TextButton(
                    onPressed: () {
                      // Navigate to my bookings
                    },
                    child: const Text('Lihat Semua'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildUpcomingBookings(),
            const SizedBox(height: 24),

            // ─── Profil Saya ───
            const Text('Profil Saya', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProfileRow(Icons.person, 'Nama', student?.namaLengkap ?? '-'),
                    const Divider(height: 24),
                    _buildProfileRow(Icons.school, 'Sekolah', student?.sekolah ?? '-'),
                    const Divider(height: 24),
                    _buildProfileRow(Icons.class_, 'Kelas', student?.kelas ?? '-'),
                    const Divider(height: 24),
                    _buildProfileRow(
                      Icons.book_outlined,
                      'Mata Pelajaran',
                      student?.mataPelajaranDibutuhkan ?? '-',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── Recommended Tutors ───
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tutor Rekomendasi', style: AppTextStyles.heading3),
                TextButton(
                  onPressed: () {
                    // Navigate to find tutor
                  },
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRecommendedTutors(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: Container(
        constraints: const BoxConstraints(minHeight: 110),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingBookings() {
    final upcoming = _bookings
        .where((b) => b.status == 'pending' || b.status == 'confirmed')
        .toList();

    if (upcoming.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: const [
                Icon(Icons.event_busy, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'Tidak ada upcoming booking',
                  style: TextStyle(color: AppColors.textLight),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: upcoming.take(3).map((booking) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          ),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.book, color: AppColors.infoColor),
            ),
            title: Text(
              booking.mataPelajaran ?? '-',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Tutor: ${booking.tutorName ?? '-'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${booking.tanggalBooking ?? '-'} • ${booking.jam ?? '-'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _getStatusColor(booking.status).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                booking.statusText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(booking.status),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedTutors() {
    if (_recommendedTutors.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: const [
                Icon(Icons.school, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'Belum ada tutor tersedia',
                  style: TextStyle(color: AppColors.textLight),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: _recommendedTutors.map((tutor) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: tutor.fotoUrl != null && tutor.fotoUrl!.isNotEmpty
                  ? Image.asset(
                      'assets/images/${tutor.fotoUrl}',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _defaultTutorAvatar(tutor.namaLengkap),
                    )
                  : _defaultTutorAvatar(tutor.namaLengkap),
            ),
            title: Text(
              tutor.namaLengkap,
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(tutor.universitas ?? '-'),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: AppColors.warningColor),
                    const SizedBox(width: 4),
                    Text('${tutor.ratingAvg?.toStringAsFixed(1) ?? '0.0'} / 5'),
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(tutor.hargaPerJam ?? 0),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.successColor,
                  ),
                ),
                const Text('/jam', style: TextStyle(fontSize: 10)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _defaultTutorAvatar(String name) {
    return Container(
      width: 50,
      height: 50,
      color: AppColors.primaryColor.withOpacity(0.15),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'T',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
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
}

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../models/review_model.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import 'booking_screen.dart';
import 'package:intl/intl.dart';

class TutorDetailScreen extends StatefulWidget {
  final int tutorId;

  const TutorDetailScreen({super.key, required this.tutorId});

  @override
  State<TutorDetailScreen> createState() => _TutorDetailScreenState();
}

class _TutorDetailScreenState extends State<TutorDetailScreen> {
  Tutor? _tutor;
  List<Review> _reviews = [];
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
    _loadTutorDetail();
  }

  Future<void> _loadTutorDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getTutorDetail(widget.tutorId);

      if (response['success'] == true) {
        setState(() {
          _tutor = Tutor.fromJson(response['data']['tutor']);
          final List<dynamic> reviewsData = response['data']['reviews'] ?? [];
          _reviews = reviewsData.map((json) => Review.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Gagal memuat detail tutor';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tutor'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildError()
              : _buildContent(),
      bottomNavigationBar: _tutor != null
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  if (authProvider.userRole != 'siswa') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hanya siswa yang dapat membuat booking'),
                        backgroundColor: AppColors.warningColor,
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingScreen(tutor: _tutor!),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Booking Sekarang',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildError() {
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
            onPressed: _loadTutorDetail,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with Photo
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: _tutor!.fotoUrl ?? '',
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.white,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.white,
                      child: const Icon(
                        Icons.person,
                        size: 80,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _tutor!.namaLengkap,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        index < (_tutor!.ratingAvg ?? 0).floor()
                            ? Icons.star
                            : Icons.star_border,
                        size: 20,
                        color: const Color(0xFFffc107),
                      );
                    }),
                    const SizedBox(width: 8),
                    Text(
                      _tutor!.ratingAvg?.toStringAsFixed(1) ?? '0.0',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Info Cards
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Universitas & Jurusan
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pendidikan',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.school, color: AppColors.primaryColor, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _tutor!.universitas ?? '-',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    _tutor!.jurusan ?? '-',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  if (_tutor!.semester != null)
                                    Text(
                                      'Semester ${_tutor!.semester}',
                                      style: AppTextStyles.bodySmall,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Mata Pelajaran
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mata Pelajaran',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _tutor!.mataPelajaranList.map((mapel) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.primaryColor.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                mapel,
                                style: const TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Harga
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Harga Per Jam',
                          style: AppTextStyles.heading3,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.secondaryGradient,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            currencyFormat.format(_tutor!.hargaPerJam),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Reviews Section
                const Text(
                  'Review dari Siswa',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 12),

                if (_reviews.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.rate_review_outlined,
                              size: 48,
                              color: AppColors.textLight.withOpacity(0.5),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Belum ada review',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ..._reviews.map((review) => _buildReviewCard(review)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                        child: Text(
                          review.studentName?.substring(0, 1).toUpperCase() ?? 'S',
                          style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.studentName ?? 'Anonymous',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (review.mataPelajaran != null)
                              Text(
                                review.mataPelajaran!,
                                style: AppTextStyles.bodySmall,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      size: 16,
                      color: const Color(0xFFffc107),
                    );
                  }),
                ),
              ],
            ),
            if (review.komentar != null && review.komentar!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.komentar!,
                style: AppTextStyles.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              DateFormat('dd MMM yyyy', 'id_ID').format(DateTime.parse(review.tanggalReview)),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

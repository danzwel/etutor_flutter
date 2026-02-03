import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import 'tutor_detail_screen.dart';
import 'package:intl/intl.dart';

class FindTutorScreen extends StatefulWidget {
  const FindTutorScreen({super.key});

  @override
  State<FindTutorScreen> createState() => _FindTutorScreenState();
}

class _FindTutorScreenState extends State<FindTutorScreen> {
  final _searchController = TextEditingController();
  List<Tutor> _tutors = [];
  List<Tutor> _filteredTutors = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadTutors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTutors() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getTutors();
      
      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        setState(() {
          _tutors = data.map((json) => Tutor.fromJson(json)).toList();
          _filteredTutors = _tutors;
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

  void _filterTutors(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredTutors = _tutors;
      });
      return;
    }

    setState(() {
      _filteredTutors = _tutors.where((tutor) {
        final nameLower = tutor.namaLengkap.toLowerCase();
        final uniLower = tutor.universitas?.toLowerCase() ?? '';
        final jurusanLower = tutor.jurusan?.toLowerCase() ?? '';
        final mapelLower = tutor.mataPelajaran?.toLowerCase() ?? '';
        final searchLower = query.toLowerCase();

        return nameLower.contains(searchLower) ||
            uniLower.contains(searchLower) ||
            jurusanLower.contains(searchLower) ||
            mapelLower.contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Tutor'),
        elevation: 2,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: _filterTutors,
              decoration: InputDecoration(
                hintText: 'Cari tutor, universitas, atau mata pelajaran...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterTutors('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.bgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Tutor Count & Refresh
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: 8,
            ),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredTutors.length} Tutor Ditemukan',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadTutors,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
          ),

          // Tutor List
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
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
              onPressed: _loadTutors,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_filteredTutors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textLight.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada tutor ditemukan',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTutors,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        itemCount: _filteredTutors.length,
        itemBuilder: (context, index) {
          final tutor = _filteredTutors[index];
          return _buildTutorCard(tutor);
        },
      ),
    );
  }

  Widget _buildTutorCard(Tutor tutor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TutorDetailScreen(tutorId: tutor.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto Tutor
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: tutor.fotoUrl ?? '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.bgColor,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.bgColor,
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Info Tutor
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutor.namaLengkap,
                      style: AppTextStyles.heading3.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (tutor.universitas != null) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.school,
                            size: 14,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              tutor.universitas!,
                              style: AppTextStyles.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                    ],
                    if (tutor.jurusan != null) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.book,
                            size: 14,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              tutor.jurusan!,
                              style: AppTextStyles.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    // Rating
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < (tutor.ratingAvg ?? 0).floor()
                                ? Icons.star
                                : Icons.star_border,
                            size: 16,
                            color: const Color(0xFFffc107),
                          );
                        }),
                        const SizedBox(width: 4),
                        Text(
                          tutor.ratingAvg?.toStringAsFixed(1) ?? '0.0',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Harga
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${currencyFormat.format(tutor.hargaPerJam)}/jam',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              const Icon(
                Icons.chevron_right,
                color: AppColors.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

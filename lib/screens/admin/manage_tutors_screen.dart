import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';

class ManageTutorsScreen extends StatefulWidget {
  const ManageTutorsScreen({super.key});

  @override
  State<ManageTutorsScreen> createState() => _ManageTutorsScreenState();
}

class _ManageTutorsScreenState extends State<ManageTutorsScreen> {
  List<Tutor> _allTutors = [];
  List<Tutor> _filteredTutors = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedStatus = 'semua'; // semua, pending, approved, rejected
  final _searchController = TextEditingController();

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
      final response = await ApiService.getAllTutors();

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        setState(() {
          _allTutors = data.map((json) => Tutor.fromJson(json)).toList();
          _applyFilter();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Gagal memuat data tutor';
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

  void _applyFilter() {
    List<Tutor> result = _allTutors;

    // Filter by status
    if (_selectedStatus != 'semua') {
      result = result.where((t) => t.status == _selectedStatus).toList();
    }

    // Filter by search
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((t) {
        return t.namaLengkap.toLowerCase().contains(query) ||
            (t.universitas?.toLowerCase().contains(query) ?? false) ||
            (t.mataPelajaran?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    setState(() {
      _filteredTutors = result;
    });
  }

  Future<void> _updateTutorStatus(int tutorId, String newStatus, String namaLengkap) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text(
          newStatus == 'approved'
              ? 'Setuju pendaftaran tutor "$namaLengkap"?'
              : 'Tolak pendaftaran tutor "$namaLengkap"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: newStatus == 'approved'
                  ? AppColors.successColor
                  : AppColors.dangerColor,
            ),
            child: Text(newStatus == 'approved' ? 'Setuju' : 'Tolak'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final response = await ApiService.updateTutorStatus(tutorId, newStatus);

    if (response['success'] == true) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Berhasil'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
      await _loadTutors();
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Gagal memperbarui status'),
            backgroundColor: AppColors.dangerColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search & Filter Section
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                onChanged: (_) => _applyFilter(),
                decoration: InputDecoration(
                  hintText: 'Cari tutor...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.textLight),
                          onPressed: () {
                            _searchController.clear();
                            _applyFilter();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
              ),
              const SizedBox(height: 12),

              // Status Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('semua', 'Semua'),
                    const SizedBox(width: 8),
                    _buildFilterChip('pending', 'Pending'),
                    const SizedBox(width: 8),
                    _buildFilterChip('approved', 'Approved'),
                    const SizedBox(width: 8),
                    _buildFilterChip('rejected', 'Rejected'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Summary Row
        Container(
          color: AppColors.bgColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Text(
                'Menampilkan ${_filteredTutors.length} tutor',
                style: AppTextStyles.bodySmall,
              ),
              const Spacer(),
              RefreshIndicator(
                onRefresh: _loadTutors,
                child: IconButton(
                  icon: const Icon(Icons.refresh, size: 20, color: AppColors.primaryColor),
                  onPressed: _loadTutors,
                ),
              ),
            ],
          ),
        ),

        // Tutor List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? _buildErrorWidget()
                  : _filteredTutors.isEmpty
                      ? _buildEmptyWidget()
                      : RefreshIndicator(
                          onRefresh: _loadTutors,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                            itemCount: _filteredTutors.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _buildTutorCard(_filteredTutors[index]);
                            },
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedStatus == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = value;
        });
        _applyFilter();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildTutorCard(Tutor tutor) {
    final statusColor = _getStatusColor(tutor.status);
    final statusLabel = _getStatusLabel(tutor.status);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar + Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: tutor.fotoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: tutor.fotoUrl!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => SizedBox(
                            width: 64,
                            height: 64,
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                          errorWidget: (context, url, error) => _defaultAvatar(tutor.namaLengkap),
                        )
                      : _defaultAvatar(tutor.namaLengkap),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tutor.namaLengkap,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (tutor.universitas != null)
                        Text(
                          '${tutor.universitas}${tutor.jurusan != null ? ' - ${tutor.jurusan}' : ''}',
                          style: AppTextStyles.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Divider
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 10),

            // Detail Info Row
            Row(
              children: [
                if (tutor.mataPelajaran != null)
                  Expanded(
                    child: _buildInfoItem(
                      Icons.book_outlined,
                      'Mata Pelajaran',
                      tutor.mataPelajaran!,
                    ),
                  ),
                if (tutor.hargaPerJam != null)
                  Expanded(
                    child: _buildInfoItem(
                      Icons.attach_money,
                      'Harga/Jam',
                      currencyFormat.format(tutor.hargaPerJam),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                if (tutor.ratingAvg != null && tutor.ratingAvg! > 0)
                  Expanded(
                    child: _buildInfoItem(
                      Icons.star,
                      'Rating',
                      '${tutor.ratingAvg!.toStringAsFixed(1)} / 5',
                    ),
                  ),
                if (tutor.semester != null)
                  Expanded(
                    child: _buildInfoItem(
                      Icons.school_outlined,
                      'Semester',
                      'Semester ${tutor.semester}',
                    ),
                  ),
              ],
            ),

            // Action Buttons — hanya tampil jika status pending
            if (tutor.status == 'pending') ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: Colors.grey),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _updateTutorStatus(tutor.id, 'rejected', tutor.namaLengkap),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Tolak'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.dangerColor,
                        side: const BorderSide(color: AppColors.dangerColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateTutorStatus(tutor.id, 'approved', tutor.namaLengkap),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Setuju'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryColor),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              Text(
                value,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _defaultAvatar(String name) {
    return Container(
      width: 64,
      height: 64,
      color: AppColors.primaryColor.withOpacity(0.15),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'T',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.dangerColor),
          const SizedBox(height: 16),
          Text(_errorMessage!, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadTutors,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Tidak ada tutor dengan status "$_selectedStatus"',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warningColor;
      case 'approved':
        return AppColors.successColor;
      case 'rejected':
        return AppColors.dangerColor;
      default:
        return AppColors.textLight;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }
}
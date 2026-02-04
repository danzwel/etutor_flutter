import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../services/api_service.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedRole = 'semua'; // semua, siswa, tutor, admin
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getAllUsers();

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        setState(() {
          _allUsers = data.map((e) => e as Map<String, dynamic>).toList();
          _applyFilter();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Gagal memuat data pengguna';
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
    List<Map<String, dynamic>> result = _allUsers;

    // Filter by role
    if (_selectedRole != 'semua') {
      result = result.where((u) => u['role'] == _selectedRole).toList();
    }

    // Filter by search
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((u) {
        final username = (u['username'] ?? '').toString().toLowerCase();
        final namaLengkap = (u['nama_lengkap'] ?? '').toString().toLowerCase();
        final email = (u['email'] ?? '').toString().toLowerCase();
        final additionalInfo = (u['additional_info'] ?? '').toString().toLowerCase();
        return username.contains(query) ||
            namaLengkap.contains(query) ||
            email.contains(query) ||
            additionalInfo.contains(query);
      }).toList();
    }

    setState(() {
      _filteredUsers = result;
    });
  }

  // Hitung jumlah per role untuk badge
  int _countByRole(String role) {
    return _allUsers.where((u) => u['role'] == role).length;
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
                  hintText: 'Cari pengguna...',
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

              // Role Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('semua', 'Semua', null),
                    const SizedBox(width: 8),
                    _buildFilterChip('siswa', 'Siswa', _countByRole('siswa')),
                    const SizedBox(width: 8),
                    _buildFilterChip('tutor', 'Tutor', _countByRole('tutor')),
                    const SizedBox(width: 8),
                    _buildFilterChip('admin', 'Admin', _countByRole('admin')),
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
                'Menampilkan ${_filteredUsers.length} pengguna',
                style: AppTextStyles.bodySmall,
              ),
              const Spacer(),
              RefreshIndicator(
                onRefresh: _loadUsers,
                child: IconButton(
                  icon: const Icon(Icons.refresh, size: 20, color: AppColors.primaryColor),
                  onPressed: _loadUsers,
                ),
              ),
            ],
          ),
        ),

        // User List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? _buildErrorWidget()
                  : _filteredUsers.isEmpty
                      ? _buildEmptyWidget()
                      : RefreshIndicator(
                          onRefresh: _loadUsers,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                            itemCount: _filteredUsers.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              return _buildUserCard(_filteredUsers[index]);
                            },
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label, int? count) {
    final isSelected = _selectedRole == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = value;
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
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.25)
                      : AppColors.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final role = user['role'] ?? '';
    final namaLengkap = user['nama_lengkap'] ?? '';
    final username = user['username'] ?? '';
    final email = user['email'] ?? '';
    final additionalInfo = user['additional_info'];
    final statusVerifikasi = user['status_verifikasi'] ?? '';

    final roleColor = _getRoleColor(role);
    final roleLabel = _getRoleLabel(role);
    final roleIcon = _getRoleIcon(role);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar Circle
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  namaLengkap.isNotEmpty
                      ? namaLengkap[0].toUpperCase()
                      : username.isNotEmpty
                          ? username[0].toUpperCase()
                          : '?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: roleColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama + Role Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          namaLengkap.isNotEmpty ? namaLengkap : username,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(roleIcon, size: 14, color: roleColor),
                            const SizedBox(width: 5),
                            Text(
                              roleLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: roleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Username
                  Text(
                    '@$username',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Email
                  Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 15, color: AppColors.textLight),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          email,
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Additional Info (sekolah / universitas / departemen)
                  if (additionalInfo != null && additionalInfo.toString().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          role == 'siswa' ? Icons.school_outlined : Icons.business_outlined,
                          size: 15,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            additionalInfo.toString(),
                            style: AppTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Verifikasi Status
                  if (statusVerifikasi.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          statusVerifikasi == 'terverifikasi'
                              ? Icons.verified
                              : Icons.pending_outlined,
                          size: 15,
                          color: statusVerifikasi == 'terverifikasi'
                              ? AppColors.successColor
                              : AppColors.warningColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          statusVerifikasi == 'terverifikasi' ? 'Terverifikasi' : 'Belum Terverifikasi',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: statusVerifikasi == 'terverifikasi'
                                ? AppColors.successColor
                                : AppColors.warningColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Action Buttons
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, size: 20),
                  color: AppColors.infoColor,
                  onPressed: () => _showUserDetail(user),
                  tooltip: 'Lihat Detail',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  color: AppColors.dangerColor,
                  onPressed: () => _deleteUser(user),
                  tooltip: 'Hapus',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
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
            onPressed: _loadUsers,
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
          const Icon(Icons.people_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _selectedRole == 'semua'
                ? 'Belum ada pengguna'
                : 'Tidak ada pengguna dengan role "${_getRoleLabel(_selectedRole)}"',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'siswa':
        return AppColors.infoColor;
      case 'tutor':
        return AppColors.secondaryColor;
      case 'admin':
        return AppColors.primaryColor;
      default:
        return AppColors.textLight;
    }
  }

  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'siswa':
        return 'Siswa';
      case 'tutor':
        return 'Tutor';
      case 'admin':
        return 'Admin';
      default:
        return role;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'siswa':
        return Icons.person_outlined;
      case 'tutor':
        return Icons.school_outlined;
      case 'admin':
        return Icons.shield_outlined;
      default:
        return Icons.person_outlined;
    }
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Konfirmasi Hapus'),
      content: Text('Yakin ingin menghapus user "${user['nama_lengkap'] ?? user['username']}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: AppColors.dangerColor),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );

    if (confirmed != true || !context.mounted) return;

    final response = await ApiService.deleteUser(int.parse(user['id'].toString()));

    if (response['success'] == true) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User berhasil dihapus'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
      await _loadUsers();
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Gagal menghapus user'),
            backgroundColor: AppColors.dangerColor,
          ),
        );
      }
    }
  }

  void _showUserDetail(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user['nama_lengkap'] ?? user['username'] ?? ''),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Username', user['username'] ?? '-'),
              _buildDetailRow('Email', user['email'] ?? '-'),
              _buildDetailRow('Role', _getRoleLabel(user['role'] ?? '')),
              _buildDetailRow('Status', user['status_verifikasi'] ?? '-'),
              if (user['additional_info'] != null)
                _buildDetailRow(
                  user['role'] == 'siswa' ? 'Sekolah' :
                  user['role'] == 'tutor' ? 'Universitas' : 'Departemen',
                  user['additional_info'].toString(),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
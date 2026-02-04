import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../admin/admin_dashboard.dart';
import '../admin/manage_tutors_screen.dart';
import '../admin/manage_users_screen.dart';
import '../admin/reports_screen.dart';
import '../about/about_screen.dart';
import '../auth/login_screen.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  Widget _currentScreen = const AdminDashboard();
  String _currentTitle = 'Dashboard';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final admin = authProvider.profile as Admin?;
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
                        admin?.namaLengkap.substring(0, 1).toUpperCase() ?? 'A',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      admin?.namaLengkap ?? user?.username ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (admin?.departemen != null)
                      Text(
                        admin!.departemen!,
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
                        'Administrator',
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
                  _currentScreen = const AdminDashboard();
                  _currentTitle = 'Dashboard';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.school_outlined),
              title: const Text('Kelola Tutor'),
              selected: _currentTitle == 'Kelola Tutor',
              selectedTileColor: AppColors.primaryColor.withOpacity(0.1),
              onTap: () {
                setState(() {
                  _currentScreen = const ManageTutorsScreen();
                  _currentTitle = 'Kelola Tutor';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outlined),
              title: const Text('Kelola Users'),
              selected: _currentTitle == 'Kelola Users',
              selectedTileColor: AppColors.primaryColor.withOpacity(0.1),
              onTap: () {
                setState(() {
                  _currentScreen = const ManageUsersScreen();
                  _currentTitle = 'Kelola Users';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.assessment_outlined),
              title: const Text('Laporan'),
              selected: _currentTitle == 'Laporan',
              selectedTileColor: AppColors.primaryColor.withOpacity(0.1),
              onTap: () {
                setState(() {
                  _currentScreen = const ReportsScreen();
                  _currentTitle = 'Laporan';
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _namaLengkapController = TextEditingController();
  final _sekolahController = TextEditingController();
  final _kelasController = TextEditingController();
  
  // Tutor fields
  final _universitasController = TextEditingController();
  final _semesterController = TextEditingController();
  final _jurusanController = TextEditingController();
  final _mataPelajaranController = TextEditingController();
  final _hargaPerJamController = TextEditingController();
  
  String _selectedRole = 'siswa';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _namaLengkapController.dispose();
    _sekolahController.dispose();
    _kelasController.dispose();
    _universitasController.dispose();
    _semesterController.dispose();
    _jurusanController.dispose();
    _mataPelajaranController.dispose();
    _hargaPerJamController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    Map<String, dynamic> data = {
      'username': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'role': _selectedRole,
      'nama_lengkap': _namaLengkapController.text.trim(),
    };

    if (_selectedRole == 'siswa') {
      data['sekolah'] = _sekolahController.text.trim();
      data['kelas'] = _kelasController.text.trim();
    } else if (_selectedRole == 'tutor') {
      data['universitas'] = _universitasController.text.trim();
      data['semester'] = _semesterController.text.trim();
      data['jurusan'] = _jurusanController.text.trim();
      data['mata_pelajaran'] = _mataPelajaranController.text.trim();
      data['harga_per_jam'] = _hargaPerJamController.text.trim();
    }

    final success = await authProvider.register(data);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login'),
          backgroundColor: AppColors.successColor,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Registrasi gagal'),
          backgroundColor: AppColors.dangerColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Buat Akun Baru',
                  style: AppTextStyles.heading2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Lengkapi data di bawah untuk mendaftar',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Role selection
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                    border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedRole = 'siswa'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedRole == 'siswa' 
                                  ? AppColors.primaryColor 
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                            ),
                            child: Text(
                              'Siswa',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _selectedRole == 'siswa' 
                                    ? Colors.white 
                                    : AppColors.textDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedRole = 'tutor'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedRole == 'tutor' 
                                  ? AppColors.primaryColor 
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                            ),
                            child: Text(
                              'Tutor',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _selectedRole == 'tutor' 
                                    ? Colors.white 
                                    : AppColors.textDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _namaLengkapController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama lengkap tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.account_circle_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!value.contains('@')) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Conditional fields for Siswa
                if (_selectedRole == 'siswa') ...[
                  TextFormField(
                    controller: _sekolahController,
                    decoration: const InputDecoration(
                      labelText: 'Sekolah',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _kelasController,
                    decoration: const InputDecoration(
                      labelText: 'Kelas',
                      prefixIcon: Icon(Icons.class_outlined),
                    ),
                  ),
                ],

                // Conditional fields for Tutor
                if (_selectedRole == 'tutor') ...[
                  TextFormField(
                    controller: _universitasController,
                    decoration: const InputDecoration(
                      labelText: 'Universitas',
                      prefixIcon: Icon(Icons.school_outlined),
                      hintText: 'Contoh: Universitas Indonesia',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Universitas tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _semesterController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Semester',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      hintText: 'Contoh: 5',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Semester tidak boleh kosong';
                      }
                      final semester = int.tryParse(value.trim());
                      if (semester == null || semester < 1 || semester > 14) {
                        return 'Semester harus antara 1-14';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _jurusanController,
                    decoration: const InputDecoration(
                      labelText: 'Jurusan',
                      prefixIcon: Icon(Icons.book_outlined),
                      hintText: 'Contoh: Teknik Informatika',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Jurusan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _mataPelajaranController,
                    decoration: const InputDecoration(
                      labelText: 'Mata Pelajaran yang Diajarkan',
                      prefixIcon: Icon(Icons.menu_book_outlined),
                      hintText: 'Contoh: Matematika, Fisika, Kimia',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Mata pelajaran tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _hargaPerJamController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Harga per Jam (Rp)',
                      prefixIcon: Icon(Icons.attach_money_outlined),
                      hintText: 'Contoh: 75000',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Harga per jam tidak boleh kosong';
                      }
                      final harga = int.tryParse(value.trim());
                      if (harga == null || harga < 10000) {
                        return 'Harga minimal Rp 10.000';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.infoColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.infoColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline, size: 20, color: AppColors.infoColor),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Foto profil dapat diupload nanti setelah akun disetujui oleh admin',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleRegister,
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Daftar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

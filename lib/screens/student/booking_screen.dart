import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class BookingScreen extends StatefulWidget {
  final Tutor tutor;

  const BookingScreen({super.key, required this.tutor});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mataPelajaranController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _durasi = 1;
  bool _isLoading = false;

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _mataPelajaranController.dispose();
    super.dispose();
  }

  double get _totalBiaya {
    return (widget.tutor.hargaPerJam ?? 0) * _durasi;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal booking'),
          backgroundColor: AppColors.warningColor,
        ),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih jam booking'),
          backgroundColor: AppColors.warningColor,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final studentId = authProvider.profileId;

    if (studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student ID tidak ditemukan'),
          backgroundColor: AppColors.dangerColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'student_id': studentId,
        'tutor_id': widget.tutor.id,
        'mata_pelajaran': _mataPelajaranController.text.trim(),
        'tanggal_booking': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'jam': '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00',
        'durasi': _durasi,
      };

      final response = await ApiService.createBooking(data);

      if (!mounted) return;

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking berhasil dibuat!'),
            backgroundColor: AppColors.successColor,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Booking gagal'),
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Tutor'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tutor Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.tutor.fotoUrl ?? '',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: AppColors.bgColor,
                              child: const Icon(Icons.person, size: 30),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.tutor.namaLengkap,
                              style: AppTextStyles.heading3.copyWith(fontSize: 16),
                            ),
                            if (widget.tutor.universitas != null)
                              Text(
                                widget.tutor.universitas!,
                                style: AppTextStyles.bodySmall,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Form Title
              const Text(
                'Detail Booking',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 16),

              // Mata Pelajaran
              TextFormField(
                controller: _mataPelajaranController,
                decoration: const InputDecoration(
                  labelText: 'Mata Pelajaran',
                  hintText: 'Contoh: Matematika, Fisika',
                  prefixIcon: Icon(Icons.book_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mata pelajaran tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tanggal Booking
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Booking',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate != null
                            ? DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate!)
                            : 'Pilih tanggal',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: _selectedDate != null ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: AppColors.textLight),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Jam
              InkWell(
                onTap: _selectTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Jam',
                    prefixIcon: Icon(Icons.access_time_outlined),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTime != null
                            ? _selectedTime!.format(context)
                            : 'Pilih jam',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: _selectedTime != null ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: AppColors.textLight),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Durasi
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Durasi (Jam)',
                  prefixIcon: Icon(Icons.timer_outlined),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _durasi > 1
                          ? () => setState(() => _durasi--)
                          : null,
                      color: AppColors.primaryColor,
                    ),
                    Text(
                      '$_durasi Jam',
                      style: AppTextStyles.heading3,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _durasi < 10
                          ? () => setState(() => _durasi++)
                          : null,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Total Biaya
              Card(
                color: AppColors.primaryColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Harga per jam:',
                            style: AppTextStyles.bodyMedium,
                          ),
                          Text(
                            currencyFormat.format(widget.tutor.hargaPerJam),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Durasi:',
                            style: AppTextStyles.bodyMedium,
                          ),
                          Text(
                            '$_durasi Jam',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Biaya:',
                            style: AppTextStyles.heading3,
                          ),
                          Text(
                            currencyFormat.format(_totalBiaya),
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Konfirmasi Booking',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Booking {
  final int id;
  final int studentId;
  final int tutorId;
  final String? mataPelajaran;
  final String? tanggalBooking;
  final String? jam;
  final int? durasi;
  final double? totalBiaya;
  final String status;
  final String createdAt;
  
  // Additional fields from joins
  final String? tutorName;
  final String? tutorFoto;
  final String? tutorFotoUrl;
  final String? tutorUniversitas;
  final String? studentName;
  final String? studentSekolah;
  final bool? hasReview;

  Booking({
    required this.id,
    required this.studentId,
    required this.tutorId,
    this.mataPelajaran,
    this.tanggalBooking,
    this.jam,
    this.durasi,
    this.totalBiaya,
    required this.status,
    required this.createdAt,
    this.tutorName,
    this.tutorFoto,
    this.tutorFotoUrl,
    this.tutorUniversitas,
    this.studentName,
    this.studentSekolah,
    this.hasReview,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: int.parse(json['id'].toString()),
      studentId: int.parse(json['student_id'].toString()),
      tutorId: int.parse(json['tutor_id'].toString()),
      mataPelajaran: json['mata_pelajaran'],
      tanggalBooking: json['tanggal_booking'],
      jam: json['jam'],
      durasi: json['durasi'] != null ? int.parse(json['durasi'].toString()) : null,
      totalBiaya: json['total_biaya'] != null ? double.parse(json['total_biaya'].toString()) : null,
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
      tutorName: json['tutor_name'],
      tutorFoto: json['foto'],
      tutorFotoUrl: json['tutor_foto_url'],
      tutorUniversitas: json['universitas'],
      studentName: json['student_name'],
      studentSekolah: json['sekolah'],
      hasReview: json['has_review'] is bool ? json['has_review'] : (json['has_review'] == 1 || json['has_review'] == true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'tutor_id': tutorId,
      'mata_pelajaran': mataPelajaran,
      'tanggal_booking': tanggalBooking,
      'jam': jam,
      'durasi': durasi,
      'total_biaya': totalBiaya,
      'status': status,
      'created_at': createdAt,
    };
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
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

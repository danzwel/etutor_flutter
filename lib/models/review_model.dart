class Review {
  final int id;
  final int bookingId;
  final int rating;
  final String? komentar;
  final String tanggalReview;
  
  // Additional fields from joins
  final String? studentName;
  final String? mataPelajaran;
  final String? tanggalBooking;

  Review({
    required this.id,
    required this.bookingId,
    required this.rating,
    this.komentar,
    required this.tanggalReview,
    this.studentName,
    this.mataPelajaran,
    this.tanggalBooking,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: int.parse(json['id'].toString()),
      bookingId: int.parse(json['booking_id'].toString()),
      rating: int.parse(json['rating'].toString()),
      komentar: json['komentar'],
      tanggalReview: json['tanggal_review'] ?? '',
      studentName: json['student_name'],
      mataPelajaran: json['mata_pelajaran'],
      tanggalBooking: json['tanggal_booking'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'rating': rating,
      'komentar': komentar,
      'tanggal_review': tanggalReview,
    };
  }
}

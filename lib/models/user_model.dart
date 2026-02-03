class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final String statusVerifikasi;
  final String createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.statusVerifikasi,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()),
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      statusVerifikasi: json['status_verifikasi'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'status_verifikasi': statusVerifikasi,
      'created_at': createdAt,
    };
  }
}

class Student {
  final int id;
  final int userId;
  final String namaLengkap;
  final String? sekolah;
  final String? kelas;
  final String? mataPelajaranDibutuhkan;
  final String? preferensiJadwal;

  Student({
    required this.id,
    required this.userId,
    required this.namaLengkap,
    this.sekolah,
    this.kelas,
    this.mataPelajaranDibutuhkan,
    this.preferensiJadwal,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      namaLengkap: json['nama_lengkap'] ?? '',
      sekolah: json['sekolah'],
      kelas: json['kelas'],
      mataPelajaranDibutuhkan: json['mata_pelajaran_dibutuhkan'],
      preferensiJadwal: json['preferensi_jadwal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nama_lengkap': namaLengkap,
      'sekolah': sekolah,
      'kelas': kelas,
      'mata_pelajaran_dibutuhkan': mataPelajaranDibutuhkan,
      'preferensi_jadwal': preferensiJadwal,
    };
  }
}

class Tutor {
  final int id;
  final int userId;
  final String namaLengkap;
  final String? universitas;
  final String? jurusan;
  final int? semester;
  final String? mataPelajaran;
  final double? hargaPerJam;
  final String? foto;
  final String? fotoUrl;
  final String? cv;
  final double? ratingAvg;
  final String status;

  Tutor({
    required this.id,
    required this.userId,
    required this.namaLengkap,
    this.universitas,
    this.jurusan,
    this.semester,
    this.mataPelajaran,
    this.hargaPerJam,
    this.foto,
    this.fotoUrl,
    this.cv,
    this.ratingAvg,
    required this.status,
  });

  factory Tutor.fromJson(Map<String, dynamic> json) {
    return Tutor(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      namaLengkap: json['nama_lengkap'] ?? '',
      universitas: json['universitas'],
      jurusan: json['jurusan'],
      semester: json['semester'] != null ? int.parse(json['semester'].toString()) : null,
      mataPelajaran: json['mata_pelajaran'],
      hargaPerJam: json['harga_per_jam'] != null ? double.parse(json['harga_per_jam'].toString()) : null,
      foto: json['foto'],
      fotoUrl: json['foto_url'],
      cv: json['cv'],
      ratingAvg: json['rating_avg'] != null ? double.parse(json['rating_avg'].toString()) : 0.0,
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nama_lengkap': namaLengkap,
      'universitas': universitas,
      'jurusan': jurusan,
      'semester': semester,
      'mata_pelajaran': mataPelajaran,
      'harga_per_jam': hargaPerJam,
      'foto': foto,
      'foto_url': fotoUrl,
      'cv': cv,
      'rating_avg': ratingAvg,
      'status': status,
    };
  }

  List<String> get mataPelajaranList {
    if (mataPelajaran == null) return [];
    return mataPelajaran!.split(',').map((e) => e.trim()).toList();
  }
}

class Admin {
  final int id;
  final int userId;
  final String namaLengkap;
  final String? nomorTelepon;
  final String? departemen;
  final String createdAt;

  Admin({
    required this.id,
    required this.userId,
    required this.namaLengkap,
    this.nomorTelepon,
    this.departemen,
    required this.createdAt,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      namaLengkap: json['nama_lengkap'] ?? '',
      nomorTelepon: json['nomor_telepon'],
      departemen: json['departemen'],
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nama_lengkap': namaLengkap,
      'nomor_telepon': nomorTelepon,
      'departemen': departemen,
      'created_at': createdAt,
    };
  }
}

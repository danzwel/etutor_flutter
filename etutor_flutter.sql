-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 30 Jan 2026 pada 07.33
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `etutor`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `admins`
--

CREATE TABLE `admins` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `nama_lengkap` varchar(100) NOT NULL,
  `nomor_telepon` varchar(20) DEFAULT NULL,
  `departemen` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `admins`
--

INSERT INTO `admins` (`id`, `user_id`, `nama_lengkap`, `nomor_telepon`, `departemen`, `created_at`) VALUES
(2, 10, 'Daniel Mananta', '08123456789', 'IT Support', '2026-01-29 10:24:32');

-- --------------------------------------------------------

--
-- Struktur dari tabel `bookings`
--

CREATE TABLE `bookings` (
  `id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `tutor_id` int(11) NOT NULL,
  `mata_pelajaran` varchar(100) DEFAULT NULL,
  `tanggal_booking` date DEFAULT NULL,
  `jam` time DEFAULT NULL,
  `durasi` int(11) DEFAULT NULL,
  `total_biaya` decimal(10,2) DEFAULT NULL,
  `status` enum('pending','confirmed','selesai','batal') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `bookings`
--

INSERT INTO `bookings` (`id`, `student_id`, `tutor_id`, `mata_pelajaran`, `tanggal_booking`, `jam`, `durasi`, `total_biaya`, `status`, `created_at`) VALUES
(11, 4, 3, 'Bahasa Inggris', '2026-01-29', '20:00:00', 2, 140000.00, 'selesai', '2026-01-29 11:05:23'),
(12, 5, 7, 'Matematika', '2026-01-30', '15:30:00', 2, 130000.00, 'selesai', '2026-01-29 11:19:16'),
(13, 5, 2, 'Statistika', '2026-01-29', '20:00:00', 1, 85000.00, 'selesai', '2026-01-29 11:24:25'),
(14, 5, 2, 'Matematika', '2026-01-29', '19:00:00', 1, 85000.00, 'batal', '2026-01-29 11:25:07');

-- --------------------------------------------------------

--
-- Struktur dari tabel `reviews`
--

CREATE TABLE `reviews` (
  `id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `rating` int(11) DEFAULT NULL CHECK (`rating` >= 1 and `rating` <= 5),
  `komentar` text DEFAULT NULL,
  `tanggal_review` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `reviews`
--

INSERT INTO `reviews` (`id`, `booking_id`, `rating`, `komentar`, `tanggal_review`) VALUES
(6, 11, 5, 'Untuk pembekalan materinya sangat bagus', '2026-01-29 11:09:56'),
(7, 12, 5, 'bagus', '2026-01-29 11:20:54');

-- --------------------------------------------------------

--
-- Struktur dari tabel `students`
--

CREATE TABLE `students` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `nama_lengkap` varchar(100) NOT NULL,
  `sekolah` varchar(100) DEFAULT NULL,
  `kelas` varchar(20) DEFAULT NULL,
  `mata_pelajaran_dibutuhkan` text DEFAULT NULL,
  `preferensi_jadwal` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `students`
--

INSERT INTO `students` (`id`, `user_id`, `nama_lengkap`, `sekolah`, `kelas`, `mata_pelajaran_dibutuhkan`, `preferensi_jadwal`) VALUES
(4, 11, 'Adit Nugroho', 'SMK Tunas Bunga', '12 IPS', 'Kimia', NULL),
(5, 14, 'Wahyu Firmansyah', 'SMK Cicici', '10 IPA', 'Matematika', NULL);

-- --------------------------------------------------------

--
-- Struktur dari tabel `tutors`
--

CREATE TABLE `tutors` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `nama_lengkap` varchar(100) NOT NULL,
  `universitas` varchar(100) DEFAULT NULL,
  `jurusan` varchar(100) DEFAULT NULL,
  `semester` int(11) DEFAULT NULL,
  `mata_pelajaran` text DEFAULT NULL,
  `harga_per_jam` decimal(10,2) DEFAULT NULL,
  `foto` varchar(255) DEFAULT NULL,
  `cv` varchar(255) DEFAULT NULL,
  `rating_avg` decimal(3,2) DEFAULT 0.00,
  `status` enum('pending','approved','rejected') DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tutors`
--

INSERT INTO `tutors` (`id`, `user_id`, `nama_lengkap`, `universitas`, `jurusan`, `semester`, `mata_pelajaran`, `harga_per_jam`, `foto`, `cv`, `rating_avg`, `status`) VALUES
(1, 2, 'Ahmad Rizki', 'Universitas Indonesia', 'Teknik Informatika', 7, 'Matematika,Fisika,Kimia', 75000.00, 'ahmad_rizki.png', 'cv_ahmad.pdf', 4.80, 'approved'),
(2, 3, 'Siti Nurhaliza', 'Institut Teknologi Bandung', 'Matematika', 6, 'Matematika,Statistika', 85000.00, 'siti_nurhaliza.png', 'cv_siti.pdf', 4.90, 'approved'),
(3, 4, 'Budi Santoso', 'Universitas Gadjah Mada', 'Pendidikan Bahasa Inggris', 5, 'Bahasa Inggris,Bahasa Indonesia', 70000.00, 'budi_santoso.png', 'cv_budi.pdf', 5.00, 'approved'),
(7, 13, 'Reza Oktavian', 'Harvard University', 'Matematika Terapan (Applied Mathematics', 7, 'Matematika, Fisika', 150000.00, 'reza_oktavian.png', NULL, 5.00, 'approved');

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','tutor','siswa') NOT NULL,
  `status_verifikasi` enum('pending','verified','rejected') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password`, `role`, `status_verifikasi`, `created_at`) VALUES
(2, 'tutor1', 'tutor1@etutor.com', '$2y$10$Ey2RzuJ0D3akPmVyiOhvn.ErbGQ9ZtSFskpoDLigbdbxeiVDuDrVC', 'tutor', 'verified', '2026-01-29 10:19:42'),
(3, 'tutor2', 'tutor2@etutor.com', '$2y$10$Ey2RzuJ0D3akPmVyiOhvn.ErbGQ9ZtSFskpoDLigbdbxeiVDuDrVC', 'tutor', 'verified', '2026-01-29 10:19:42'),
(4, 'tutor3', 'tutor3@etutor.com', '$2y$10$Ey2RzuJ0D3akPmVyiOhvn.ErbGQ9ZtSFskpoDLigbdbxeiVDuDrVC', 'tutor', 'verified', '2026-01-29 10:19:42'),
(10, 'admin', 'admin@email.com', '$2y$10$Ey2RzuJ0D3akPmVyiOhvn.ErbGQ9ZtSFskpoDLigbdbxeiVDuDrVC', 'admin', 'verified', '2026-01-29 10:24:32'),
(11, 'adit', 'adit@gmail.com', '$2y$10$t92eCvuSraA0/wpY3w53TOYQ/tdwAMcLFwV7H4QKqk/jsUNRFiCqi', 'siswa', 'verified', '2026-01-29 11:03:54'),
(13, 'reza', 'reza@email.com', '$2y$10$7/FnO2YPlQnV1PpTIp6WHePz9pxYwmQ.6quScVcMOJWh1OITa88ZO', 'tutor', 'verified', '2026-01-29 11:15:24'),
(14, 'wahyu', 'wahyu@email.com', '$2y$10$EKp/30pNl6sbtRm0FshAhupIKhpOl3CdbCML0Qda576LqPWukFtJS', 'siswa', 'verified', '2026-01-29 11:18:38');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `student_id` (`student_id`),
  ADD KEY `tutor_id` (`tutor_id`);

--
-- Indeks untuk tabel `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `booking_id` (`booking_id`);

--
-- Indeks untuk tabel `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `tutors`
--
ALTER TABLE `tutors`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `admins`
--
ALTER TABLE `admins`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `bookings`
--
ALTER TABLE `bookings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT untuk tabel `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT untuk tabel `students`
--
ALTER TABLE `students`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `tutors`
--
ALTER TABLE `tutors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `admins`
--
ALTER TABLE `admins`
  ADD CONSTRAINT `admins_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`),
  ADD CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`tutor_id`) REFERENCES `tutors` (`id`);

--
-- Ketidakleluasaan untuk tabel `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `students`
--
ALTER TABLE `students`
  ADD CONSTRAINT `students_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `tutors`
--
ALTER TABLE `tutors`
  ADD CONSTRAINT `tutors_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

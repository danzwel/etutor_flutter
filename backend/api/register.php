<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit();
}

$data = json_decode(file_get_contents('php://input'), true);

$username = $data['username'] ?? '';
$email = $data['email'] ?? '';
$password = $data['password'] ?? '';
$role = $data['role'] ?? 'siswa';
$nama_lengkap = $data['nama_lengkap'] ?? '';

// Validation
if (empty($username) || empty($email) || empty($password) || empty($nama_lengkap)) {
    echo json_encode(['success' => false, 'message' => 'Semua field harus diisi']);
    exit();
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode(['success' => false, 'message' => 'Format email tidak valid']);
    exit();
}

if (strlen($password) < 6) {
    echo json_encode(['success' => false, 'message' => 'Password minimal 6 karakter']);
    exit();
}

try {
    // Check if username or email already exists
    $stmt = $pdo->prepare("SELECT id FROM users WHERE username = ? OR email = ?");
    $stmt->execute([$username, $email]);
    if ($stmt->fetch()) {
        echo json_encode(['success' => false, 'message' => 'Username atau email sudah terdaftar']);
        exit();
    }
    
    $pdo->beginTransaction();
    
    // Insert into users table
    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
    $stmt = $pdo->prepare("INSERT INTO users (username, email, password, role, status_verifikasi) VALUES (?, ?, ?, ?, 'verified')");
    $stmt->execute([$username, $email, $hashedPassword, $role]);
    $userId = $pdo->lastInsertId();
    
    // Insert into role-specific table
    if ($role === 'siswa') {
        $sekolah = $data['sekolah'] ?? '';
        $kelas = $data['kelas'] ?? '';
        $mata_pelajaran_dibutuhkan = $data['mata_pelajaran_dibutuhkan'] ?? '';
        
        $stmt = $pdo->prepare("INSERT INTO students (user_id, nama_lengkap, sekolah, kelas, mata_pelajaran_dibutuhkan) VALUES (?, ?, ?, ?, ?)");
        $stmt->execute([$userId, $nama_lengkap, $sekolah, $kelas, $mata_pelajaran_dibutuhkan]);
    } elseif ($role === 'tutor') {
        $universitas = $data['universitas'] ?? '';
        $jurusan = $data['jurusan'] ?? '';
        $semester = $data['semester'] ?? 1;
        $mata_pelajaran = $data['mata_pelajaran'] ?? '';
        $harga_per_jam = $data['harga_per_jam'] ?? 50000;
        
        $stmt = $pdo->prepare("INSERT INTO tutors (user_id, nama_lengkap, universitas, jurusan, semester, mata_pelajaran, harga_per_jam, status) VALUES (?, ?, ?, ?, ?, ?, ?, 'pending')");
        $stmt->execute([$userId, $nama_lengkap, $universitas, $jurusan, $semester, $mata_pelajaran, $harga_per_jam]);
    }
    
    $pdo->commit();
    
    echo json_encode([
        'success' => true,
        'message' => 'Registrasi berhasil! Silakan login',
        'data' => ['user_id' => $userId]
    ]);
    
} catch (PDOException $e) {
    $pdo->rollBack();
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}

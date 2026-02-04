<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
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

$tutor_id = $data['tutor_id'] ?? '';
$nama_lengkap = $data['nama_lengkap'] ?? '';
$universitas = $data['universitas'] ?? '';
$jurusan = $data['jurusan'] ?? '';
$semester = $data['semester'] ?? '';
$mata_pelajaran = $data['mata_pelajaran'] ?? '';
$harga_per_jam = $data['harga_per_jam'] ?? '';

if (empty($tutor_id)) {
    echo json_encode(['success' => false, 'message' => 'Tutor ID harus diisi']);
    exit();
}

try {
    $stmt = $pdo->prepare("
        UPDATE tutors 
        SET nama_lengkap = ?, 
            universitas = ?, 
            jurusan = ?, 
            semester = ?, 
            mata_pelajaran = ?, 
            harga_per_jam = ?
        WHERE id = ?
    ");
    
    $stmt->execute([
        $nama_lengkap,
        $universitas,
        $jurusan,
        $semester,
        $mata_pelajaran,
        $harga_per_jam,
        $tutor_id
    ]);
    
    if ($stmt->rowCount() > 0) {
        echo json_encode([
            'success' => true,
            'message' => 'Profil berhasil diupdate'
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Tidak ada perubahan atau tutor tidak ditemukan']);
    }
    
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}

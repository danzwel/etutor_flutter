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

$student_id = $data['student_id'] ?? '';
$tutor_id = $data['tutor_id'] ?? '';
$mata_pelajaran = $data['mata_pelajaran'] ?? '';
$tanggal_booking = $data['tanggal_booking'] ?? '';
$jam = $data['jam'] ?? '';
$durasi = $data['durasi'] ?? 1;

if (empty($student_id) || empty($tutor_id) || empty($mata_pelajaran) || empty($tanggal_booking) || empty($jam)) {
    echo json_encode(['success' => false, 'message' => 'Semua field harus diisi']);
    exit();
}

try {
    // Get tutor price
    $stmt = $pdo->prepare("SELECT harga_per_jam FROM tutors WHERE id = ?");
    $stmt->execute([$tutor_id]);
    $tutor = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$tutor) {
        echo json_encode(['success' => false, 'message' => 'Tutor not found']);
        exit();
    }
    
    $total_biaya = $tutor['harga_per_jam'] * $durasi;
    
    // Insert booking
    $stmt = $pdo->prepare("INSERT INTO bookings (student_id, tutor_id, mata_pelajaran, tanggal_booking, jam, durasi, total_biaya, status) 
                          VALUES (?, ?, ?, ?, ?, ?, ?, 'pending')");
    $stmt->execute([$student_id, $tutor_id, $mata_pelajaran, $tanggal_booking, $jam, $durasi, $total_biaya]);
    $booking_id = $pdo->lastInsertId();
    
    echo json_encode([
        'success' => true,
        'message' => 'Booking berhasil dibuat',
        'data' => [
            'booking_id' => $booking_id,
            'total_biaya' => $total_biaya
        ]
    ]);
    
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}

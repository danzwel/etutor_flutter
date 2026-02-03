<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../config/database.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$tutor_id = $_GET['tutor_id'] ?? '';

if (empty($tutor_id)) {
    echo json_encode(['success' => false, 'message' => 'Tutor ID required']);
    exit();
}

try {
    $stmt = $pdo->prepare("SELECT b.*, s.nama_lengkap as student_name, s.sekolah
                          FROM bookings b
                          JOIN students s ON b.student_id = s.id
                          WHERE b.tutor_id = ?
                          ORDER BY b.tanggal_booking DESC, b.jam DESC");
    $stmt->execute([$tutor_id]);
    $bookings = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'data' => $bookings
    ]);
    
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}

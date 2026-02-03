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

$student_id = $_GET['student_id'] ?? '';

if (empty($student_id)) {
    echo json_encode(['success' => false, 'message' => 'Student ID required']);
    exit();
}

try {
    $stmt = $pdo->prepare("SELECT b.*, t.nama_lengkap as tutor_name, t.foto, t.universitas
                          FROM bookings b
                          JOIN tutors t ON b.tutor_id = t.id
                          WHERE b.student_id = ?
                          ORDER BY b.tanggal_booking DESC, b.jam DESC");
    $stmt->execute([$student_id]);
    $bookings = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Process foto URLs
    foreach ($bookings as &$booking) {
        if (!empty($booking['foto'])) {
            $booking['tutor_foto_url'] = 'http://192.168.1.27/etutor_flutter/images/' . $booking['foto'];
        } else {
            $booking['tutor_foto_url'] = 'http://192.168.1.27/etutor_flutter/images/default-avatar.jpg';
        }
        
        // Check if review exists
        $stmt = $pdo->prepare("SELECT id FROM reviews WHERE booking_id = ?");
        $stmt->execute([$booking['id']]);
        $booking['has_review'] = $stmt->fetch() ? true : false;
    }
    
    echo json_encode([
        'success' => true,
        'data' => $bookings
    ]);
    
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}

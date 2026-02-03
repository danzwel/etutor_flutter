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

$tutor_id = $_GET['id'] ?? '';

if (empty($tutor_id)) {
    echo json_encode(['success' => false, 'message' => 'Tutor ID required']);
    exit();
}

try {
    // Get tutor details
    $stmt = $pdo->prepare("SELECT t.*, u.username, u.email 
                          FROM tutors t 
                          JOIN users u ON t.user_id = u.id 
                          WHERE t.id = ?");
    $stmt->execute([$tutor_id]);
    $tutor = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$tutor) {
        echo json_encode(['success' => false, 'message' => 'Tutor not found']);
        exit();
    }
    
    // Process foto URL
    if (!empty($tutor['foto'])) {
        $tutor['foto_url'] = 'http://192.168.1.27/etutor_flutter/assets/images/' . $tutor['foto'];
    } else {
        $tutor['foto_url'] = 'http://192.168.1.27/etutor_flutter/assets/images/default-avatar.jpg';
    }
    
    // Get reviews
    $stmt = $pdo->prepare("SELECT r.*, s.nama_lengkap as student_name, b.mata_pelajaran, b.tanggal_booking
                          FROM reviews r
                          JOIN bookings b ON r.booking_id = b.id
                          JOIN students s ON b.student_id = s.id
                          WHERE b.tutor_id = ?
                          ORDER BY r.tanggal_review DESC
                          LIMIT 10");
    $stmt->execute([$tutor_id]);
    $reviews = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'data' => [
            'tutor' => $tutor,
            'reviews' => $reviews
        ]
    ]);
    
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}

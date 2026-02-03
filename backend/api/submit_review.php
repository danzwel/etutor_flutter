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

$booking_id = $data['booking_id'] ?? '';
$rating = $data['rating'] ?? '';
$komentar = $data['komentar'] ?? '';

if (empty($booking_id) || empty($rating)) {
    echo json_encode(['success' => false, 'message' => 'Booking ID dan rating harus diisi']);
    exit();
}

if ($rating < 1 || $rating > 5) {
    echo json_encode(['success' => false, 'message' => 'Rating harus antara 1-5']);
    exit();
}

try {
    // Check if booking is completed
    $stmt = $pdo->prepare("SELECT tutor_id FROM bookings WHERE id = ? AND status = 'selesai'");
    $stmt->execute([$booking_id]);
    $booking = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$booking) {
        echo json_encode(['success' => false, 'message' => 'Booking belum selesai atau tidak ditemukan']);
        exit();
    }
    
    // Check if review already exists
    $stmt = $pdo->prepare("SELECT id FROM reviews WHERE booking_id = ?");
    $stmt->execute([$booking_id]);
    if ($stmt->fetch()) {
        echo json_encode(['success' => false, 'message' => 'Review sudah pernah diberikan']);
        exit();
    }
    
    $pdo->beginTransaction();
    
    // Insert review
    $stmt = $pdo->prepare("INSERT INTO reviews (booking_id, rating, komentar) VALUES (?, ?, ?)");
    $stmt->execute([$booking_id, $rating, $komentar]);
    
    // Update tutor average rating
    $stmt = $pdo->prepare("UPDATE tutors SET rating_avg = (
        SELECT AVG(r.rating) 
        FROM reviews r 
        JOIN bookings b ON r.booking_id = b.id 
        WHERE b.tutor_id = ?
    ) WHERE id = ?");
    $stmt->execute([$booking['tutor_id'], $booking['tutor_id']]);
    
    $pdo->commit();
    
    echo json_encode([
        'success' => true,
        'message' => 'Review berhasil dikirim'
    ]);
    
} catch (PDOException $e) {
    $pdo->rollBack();
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}

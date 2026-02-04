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
$status = $data['status'] ?? ''; // 'approved' or 'rejected'

if (empty($tutor_id) || empty($status)) {
    echo json_encode(['success' => false, 'message' => 'Tutor ID dan status harus diisi']);
    exit();
}

if (!in_array($status, ['approved', 'rejected'])) {
    echo json_encode(['success' => false, 'message' => 'Status tidak valid']);
    exit();
}

try {
    $stmt = $pdo->prepare("UPDATE tutors SET status = ? WHERE id = ?");
    $stmt->execute([$status, $tutor_id]);
    
    if ($stmt->rowCount() > 0) {
        echo json_encode([
            'success' => true,
            'message' => $status === 'approved' ? 'Tutor berhasil disetujui' : 'Tutor ditolak'
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Tutor tidak ditemukan']);
    }
    
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}

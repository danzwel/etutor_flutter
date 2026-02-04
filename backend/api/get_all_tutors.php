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

try {
    $status = $_GET['status'] ?? '';
    
    $sql = "SELECT t.*, u.username, u.email, u.status_verifikasi
            FROM tutors t
            JOIN users u ON t.user_id = u.id";
    
    if (!empty($status)) {
        $sql .= " WHERE t.status = ?";
    }
    
    $sql .= " ORDER BY u.id DESC";
    
    if (!empty($status)) {
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$status]);
    } else {
        $stmt = $pdo->query($sql);
    }
    
    $tutors = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Process foto URLs - langsung nama file untuk Flutter assets
    foreach ($tutors as &$tutor) {
        if (!empty($tutor['foto'])) {
            $tutor['foto_url'] = $tutor['foto'];
        } else {
            $tutor['foto_url'] = 'default-avatar.jpg';
        }
    }
    
    echo json_encode([
        'success' => true,
        'data' => $tutors
    ]);
    
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}

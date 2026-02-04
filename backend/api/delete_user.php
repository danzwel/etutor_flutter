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
$user_id = $data['user_id'] ?? '';

if (empty($user_id)) {
    echo json_encode(['success' => false, 'message' => 'User ID harus diisi']);
    exit();
}

try {
    $pdo->beginTransaction();
    
    // Get user role
    $stmt = $pdo->prepare("SELECT role FROM users WHERE id = ?");
    $stmt->execute([$user_id]);
    $user = $stmt->fetch();
    
    if (!$user) {
        echo json_encode(['success' => false, 'message' => 'User tidak ditemukan']);
        exit();
    }
    
    $role = $user['role'];
    
    // Delete from role-specific table first
    if ($role === 'siswa') {
        $stmt = $pdo->prepare("DELETE FROM students WHERE user_id = ?");
        $stmt->execute([$user_id]);
    } elseif ($role === 'tutor') {
        $stmt = $pdo->prepare("DELETE FROM tutors WHERE user_id = ?");
        $stmt->execute([$user_id]);
    } elseif ($role === 'admin') {
        $stmt = $pdo->prepare("DELETE FROM admins WHERE user_id = ?");
        $stmt->execute([$user_id]);
    }
    
    // Delete from users table
    $stmt = $pdo->prepare("DELETE FROM users WHERE id = ?");
    $stmt->execute([$user_id]);
    
    $pdo->commit();
    
    echo json_encode([
        'success' => true,
        'message' => 'User berhasil dihapus'
    ]);
    
} catch (PDOException $e) {
    $pdo->rollBack();
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}

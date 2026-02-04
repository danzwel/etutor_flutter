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
    $user_id = $_GET['user_id'] ?? '';
    
    if (empty($user_id)) {
        echo json_encode(['success' => false, 'message' => 'User ID harus diisi']);
        exit();
    }
    
    // Get user basic info
    $stmt = $pdo->prepare("SELECT * FROM users WHERE id = ?");
    $stmt->execute([$user_id]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        echo json_encode(['success' => false, 'message' => 'User tidak ditemukan']);
        exit();
    }
    
    $role = $user['role'];
    $roleData = null;
    
    // Get role-specific data
    if ($role === 'siswa') {
        $stmt = $pdo->prepare("SELECT * FROM students WHERE user_id = ?");
        $stmt->execute([$user_id]);
        $roleData = $stmt->fetch(PDO::FETCH_ASSOC);
    } elseif ($role === 'tutor') {
        $stmt = $pdo->prepare("SELECT * FROM tutors WHERE user_id = ?");
        $stmt->execute([$user_id]);
        $roleData = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // Add foto URL
        if ($roleData && !empty($roleData['foto'])) {
            $roleData['foto_url'] = $roleData['foto'];
        } else {
            $roleData['foto_url'] = 'default-avatar.jpg';
        }
    } elseif ($role === 'admin') {
        $stmt = $pdo->prepare("SELECT * FROM admins WHERE user_id = ?");
        $stmt->execute([$user_id]);
        $roleData = $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    echo json_encode([
        'success' => true,
        'data' => [
            'user' => $user,
            'profile' => $roleData
        ]
    ]);
    
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}

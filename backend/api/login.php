<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
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

$username = $data['username'] ?? '';
$password = $data['password'] ?? '';

if (empty($username) || empty($password)) {
    echo json_encode(['success' => false, 'message' => 'Username dan password harus diisi']);
    exit();
}

try {
    $stmt = $pdo->prepare("SELECT * FROM users WHERE username = ? OR email = ?");
    $stmt->execute([$username, $username]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user) {
        echo json_encode(['success' => false, 'message' => 'Username atau password salah']);
        exit();
    }
    
    if (!password_verify($password, $user['password'])) {
        echo json_encode(['success' => false, 'message' => 'Username atau password salah']);
        exit();
    }
    
    if ($user['status_verifikasi'] !== 'verified') {
        echo json_encode(['success' => false, 'message' => 'Akun Anda belum diverifikasi']);
        exit();
    }
    
    // Get additional info based on role
    $profileData = [];
    if ($user['role'] === 'siswa') {
        $stmt = $pdo->prepare("SELECT * FROM students WHERE user_id = ?");
        $stmt->execute([$user['id']]);
        $profileData = $stmt->fetch(PDO::FETCH_ASSOC);
    } elseif ($user['role'] === 'tutor') {
        $stmt = $pdo->prepare("SELECT * FROM tutors WHERE user_id = ?");
        $stmt->execute([$user['id']]);
        $profileData = $stmt->fetch(PDO::FETCH_ASSOC);
    } elseif ($user['role'] === 'admin') {
        $stmt = $pdo->prepare("SELECT * FROM admins WHERE user_id = ?");
        $stmt->execute([$user['id']]);
        $profileData = $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    // Remove sensitive data
    unset($user['password']);
    
    echo json_encode([
        'success' => true,
        'message' => 'Login berhasil',
        'data' => [
            'user' => $user,
            'profile' => $profileData
        ]
    ]);
    
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}

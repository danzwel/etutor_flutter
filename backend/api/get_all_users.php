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
    $role = $_GET['role'] ?? '';
    
    $sql = "SELECT u.*, 
            CASE 
                WHEN u.role = 'siswa' THEN s.nama_lengkap
                WHEN u.role = 'tutor' THEN t.nama_lengkap
                WHEN u.role = 'admin' THEN a.nama_lengkap
            END as nama_lengkap,
            CASE 
                WHEN u.role = 'siswa' THEN s.sekolah
                WHEN u.role = 'tutor' THEN t.universitas
                WHEN u.role = 'admin' THEN a.departemen
            END as additional_info
            FROM users u
            LEFT JOIN students s ON u.id = s.user_id AND u.role = 'siswa'
            LEFT JOIN tutors t ON u.id = t.user_id AND u.role = 'tutor'
            LEFT JOIN admins a ON u.id = a.user_id AND u.role = 'admin'";
    
    if (!empty($role)) {
        $sql .= " WHERE u.role = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$role]);
    } else {
        $stmt = $pdo->query($sql);
    }
    
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'data' => $users
    ]);
    
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}

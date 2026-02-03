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
    $search = $_GET['search'] ?? '';
    $mata_pelajaran = $_GET['mata_pelajaran'] ?? '';
    $max_harga = $_GET['max_harga'] ?? '';
    
    $sql = "SELECT t.*, u.username, u.email 
            FROM tutors t 
            JOIN users u ON t.user_id = u.id 
            WHERE t.status = 'approved'";
    
    $params = [];
    
    if (!empty($search)) {
        $sql .= " AND (t.nama_lengkap LIKE ? OR t.universitas LIKE ? OR t.jurusan LIKE ?)";
        $searchParam = "%$search%";
        $params[] = $searchParam;
        $params[] = $searchParam;
        $params[] = $searchParam;
    }
    
    if (!empty($mata_pelajaran)) {
        $sql .= " AND t.mata_pelajaran LIKE ?";
        $params[] = "%$mata_pelajaran%";
    }
    
    if (!empty($max_harga)) {
        $sql .= " AND t.harga_per_jam <= ?";
        $params[] = $max_harga;
    }
    
    $sql .= " ORDER BY t.rating_avg DESC, t.nama_lengkap ASC";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $tutors = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Process foto URLs
    foreach ($tutors as &$tutor) {
        if (!empty($tutor['foto'])) {
            $tutor['foto_url'] = 'http://YOUR_SERVER_IP/etutor/assets/images/' . $tutor['foto'];
        } else {
            $tutor['foto_url'] = 'http://YOUR_SERVER_IP/etutor/assets/images/default-avatar.jpg';
        }
    }
    
    echo json_encode([
        'success' => true,
        'data' => $tutors,
        'count' => count($tutors)
    ]);
    
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}

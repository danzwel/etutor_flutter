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
    // Total Users
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM users");
    $totalUsers = $stmt->fetch()['total'];
    
    // Total Tutors
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM tutors");
    $totalTutors = $stmt->fetch()['total'];
    
    // Total Students
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM students");
    $totalStudents = $stmt->fetch()['total'];
    
    // Total Bookings
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM bookings");
    $totalBookings = $stmt->fetch()['total'];
    
    // Pending Tutors
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM tutors WHERE status = 'pending'");
    $pendingTutors = $stmt->fetch()['total'];
    
    // Approved Tutors
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM tutors WHERE status = 'approved'");
    $approvedTutors = $stmt->fetch()['total'];
    
    // Total Revenue
    $stmt = $pdo->query("SELECT SUM(total_biaya) as total FROM bookings WHERE status IN ('confirmed', 'selesai')");
    $totalRevenue = $stmt->fetch()['total'] ?? 0;
    
    // Pending Bookings
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM bookings WHERE status = 'pending'");
    $pendingBookings = $stmt->fetch()['total'];
    
    // Completed Bookings
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM bookings WHERE status = 'selesai'");
    $completedBookings = $stmt->fetch()['total'];
    
    // Recent Bookings
    $stmt = $pdo->query("
        SELECT b.*, s.nama_lengkap as student_name, t.nama_lengkap as tutor_name
        FROM bookings b
        JOIN students s ON b.student_id = s.id
        JOIN tutors t ON b.tutor_id = t.id
        ORDER BY b.created_at DESC
        LIMIT 5
    ");
    $recentBookings = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'data' => [
            'total_users' => (int)$totalUsers,
            'total_tutors' => (int)$totalTutors,
            'total_students' => (int)$totalStudents,
            'total_bookings' => (int)$totalBookings,
            'pending_tutors' => (int)$pendingTutors,
            'approved_tutors' => (int)$approvedTutors,
            'total_revenue' => (float)$totalRevenue,
            'pending_bookings' => (int)$pendingBookings,
            'completed_bookings' => (int)$completedBookings,
            'recent_bookings' => $recentBookings
        ]
    ]);
    
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}
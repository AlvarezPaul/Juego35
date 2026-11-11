<?php
header('Content-Type: application/json; charset=utf-8');

// Ajustá estos datos si tu instalación de MySQL/MariaDB usa otras credenciales.
$host = 'localhost';
$database = 'juego35';
$user = 'root';
$password = '';

try {
    $raw = file_get_contents('php://input');
    $data = json_decode($raw, true);

    if (!is_array($data)) {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'El cuerpo de la petición no es un JSON válido.']);
        exit;
    }

    $nombre = trim((string)($data['nombre'] ?? ''));
    $tiempo = $data['tiempo'] ?? null;

    if ($nombre === '' || mb_strlen($nombre) > 50) {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'El nombre es obligatorio y debe tener como máximo 50 caracteres.']);
        exit;
    }

    if (!is_numeric($tiempo) || (float)$tiempo < 0) {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'El tiempo enviado no es válido.']);
        exit;
    }

    $pdo = new PDO(
        "mysql:host=$host;dbname=$database;charset=utf8mb4",
        $user,
        $password,
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );

    // Si el puntaje se guardó antes sin conexión, el juego manda la fecha original.
    $fecha = $data['fecha'] ?? null;
    $fechaValida = is_string($fecha) && preg_match('/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/', $fecha);

    if ($fechaValida) {
        $stmt = $pdo->prepare('INSERT INTO puntajes (nombre, tiempo, fecha) VALUES (:nombre, :tiempo, :fecha)');
        $stmt->execute([
            ':nombre' => $nombre,
            ':tiempo' => round((float)$tiempo, 2),
            ':fecha' => $fecha
        ]);
    } else {
        $stmt = $pdo->prepare('INSERT INTO puntajes (nombre, tiempo) VALUES (:nombre, :tiempo)');
        $stmt->execute([
            ':nombre' => $nombre,
            ':tiempo' => round((float)$tiempo, 2)
        ]);
    }

    echo json_encode([
        'status' => 'success',
        'message' => 'Puntaje guardado correctamente.',
        'id' => (int)$pdo->lastInsertId()
    ]);
} catch (Throwable $e) {
    http_response_code(500);
    error_log('Error al guardar puntaje: ' . $e->getMessage());
    echo json_encode([
        'status' => 'error',
        'message' => 'No se pudo guardar el puntaje. Revisá la base de datos y la tabla puntajes.'
    ]);
}

<?php
declare(strict_types=1);

if (basename($_SERVER['SCRIPT_FILENAME'] ?? '') === 'bootstrap.php') {
    http_response_code(404);
    exit;
}

header('Content-Type: application/json; charset=utf-8');

$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
$allowedOrigins = array_map('trim', explode(',', getenv('VELKORYX_ALLOWED_ORIGINS') ?: 'http://localhost:9000,http://127.0.0.1:9000'));
if ($origin !== '' && !in_array($origin, $allowedOrigins, true)) {
    apiRespond(403, ['message' => 'Origen no permitido']);
}
if ($origin !== '') {
    header('Access-Control-Allow-Origin: ' . $origin);
    header('Vary: Origin');
    header('Access-Control-Allow-Methods: GET, POST, PUT, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type');
}
if (($_SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS') {
    http_response_code(204);
    exit;
}

function apiRespond(int $status, array $body): never
{
    http_response_code($status);
    echo json_encode($body, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function apiDb(): PDO
{
    $host = getenv('VELKORYX_DB_HOST') ?: '127.0.0.1';
    $name = getenv('VELKORYX_DB_NAME') ?: 'velkoryx';
    $user = getenv('VELKORYX_DB_USER') ?: 'root';
    $password = getenv('VELKORYX_DB_PASSWORD') ?: '';

    return new PDO(
        "mysql:host={$host};dbname={$name};charset=utf8mb4",
        $user,
        $password,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]
    );
}

function apiConfiguredPlant(PDO $db): ?array
{
    $plants = $db->query('SELECT * FROM plantas WHERE deleted_at IS NULL ORDER BY id LIMIT 2')->fetchAll();
    if (count($plants) > 1) {
        throw new DomainException('Hay más de una planta activa; revisa los datos antes de continuar');
    }
    return $plants[0] ?? null;
}

function apiIsStoredImagePath(string $path): bool
{
    return (bool) preg_match('~^uploads/(logo|logo_oscuro|favicon)-[a-f0-9]{32}\.(png|jpg|webp|ico)$~', $path);
}

function apiDeleteStoredImage(?string $path): void
{
    if ($path !== null && apiIsStoredImagePath($path)) {
        $file = __DIR__ . '/' . $path;
        if (is_file($file) && !unlink($file)) {
            error_log('No se pudo borrar la imagen anterior: ' . $file);
        }
    }
}

function apiJsonInput(): array
{
    try {
        $data = json_decode(file_get_contents('php://input'), false, 512, JSON_THROW_ON_ERROR);
    } catch (JsonException $exception) {
        apiRespond(400, ['message' => 'El cuerpo debe contener JSON válido']);
    }
    if (!is_object($data)) {
        apiRespond(400, ['message' => 'Se esperaba un objeto JSON']);
    }
    return get_object_vars($data);
}

<?php
declare(strict_types=1);

require __DIR__ . '/bootstrap.php';

const STRING_FIELDS = [
    'codigo' => 30, 'nombre' => 150, 'nombre_corto' => 80, 'descripcion' => 500,
    'razon_social' => 200, 'rfc' => 20, 'telefono' => 30, 'telefono_secundario' => 30,
    'email' => 150, 'sitio_web' => 250, 'calle' => 150, 'numero_exterior' => 30,
    'numero_interior' => 30, 'colonia' => 150, 'municipio' => 150, 'ciudad' => 150,
    'estado' => 150, 'codigo_postal' => 20, 'pais' => 100, 'zona_horaria' => 100,
    'idioma' => 10, 'moneda' => 3, 'logo' => 500, 'logo_oscuro' => 500,
    'favicon' => 500, 'color_primario' => 20, 'color_secundario' => 20,
    'nombre_sistema' => 100, 'slogan' => 200,
];
const REQUIRED_FIELDS = ['codigo', 'nombre', 'zona_horaria', 'idioma', 'moneda', 'nombre_sistema'];

function plantInput(array $input): array
{
    $data = [];
    foreach (STRING_FIELDS as $field => $maxLength) {
        $value = $input[$field] ?? null;
        if ($value !== null && !is_string($value)) {
            apiRespond(422, ['message' => "El campo {$field} debe ser texto"]);
        }
        $value = $value === null ? null : trim($value);
        if ($value === '') {
            $value = null;
        }
        if (in_array($field, REQUIRED_FIELDS, true) && $value === null) {
            apiRespond(422, ['message' => "El campo {$field} es obligatorio"]);
        }
        if ($value !== null && mb_strlen($value) > $maxLength) {
            apiRespond(422, ['message' => "El campo {$field} supera {$maxLength} caracteres"]);
        }
        $data[$field] = $value;
    }

    $companyId = $input['id_empresa'] ?? null;
    if ($companyId !== null && $companyId !== '' && filter_var($companyId, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]) === false) {
        apiRespond(422, ['message' => 'ID de empresa inválido']);
    }
    $data['id_empresa'] = $companyId === '' ? null : $companyId;

    foreach (['latitud' => 90, 'longitud' => 180] as $field => $limit) {
        $value = $input[$field] ?? null;
        if ($value === '') {
            $value = null;
        }
        if ($value !== null && (!is_numeric($value) || abs((float) $value) > $limit)) {
            apiRespond(422, ['message' => "El campo {$field} es inválido"]);
        }
        $data[$field] = $value === null ? null : round((float) $value, 7);
    }

    if ($data['email'] !== null && !filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
        apiRespond(422, ['message' => 'Correo electrónico inválido']);
    }
    foreach (['sitio_web', 'logo', 'logo_oscuro', 'favicon'] as $field) {
        if ($data[$field] !== null && !filter_var($data[$field], FILTER_VALIDATE_URL)
            && ($field === 'sitio_web' || !apiIsStoredImagePath($data[$field]))) {
            apiRespond(422, ['message' => "La URL de {$field} es inválida"]);
        }
    }
    foreach (['color_primario', 'color_secundario'] as $field) {
        if ($data[$field] !== null && !preg_match('/^#[0-9a-fA-F]{6}$/', $data[$field])) {
            apiRespond(422, ['message' => "El campo {$field} debe tener formato #RRGGBB"]);
        }
    }
    $data['moneda'] = strtoupper($data['moneda']);
    if (!preg_match('/^[A-Z]{3}$/', $data['moneda'])) {
        apiRespond(422, ['message' => 'Moneda inválida']);
    }
    $status = $input['estatus'] ?? 1;
    if (!in_array($status, [0, 1, false, true, '0', '1'], true)) {
        apiRespond(422, ['message' => 'Estatus inválido']);
    }
    $data['estatus'] = (int) $status;
    return $data;
}

function uuidV4(): string
{
    $bytes = random_bytes(16);
    $bytes[6] = chr((ord($bytes[6]) & 0x0f) | 0x40);
    $bytes[8] = chr((ord($bytes[8]) & 0x3f) | 0x80);
    $hex = bin2hex($bytes);
    return sprintf('%s-%s-%s-%s-%s', substr($hex, 0, 8), substr($hex, 8, 4), substr($hex, 12, 4), substr($hex, 16, 4), substr($hex, 20));
}

try {
    $db = apiDb();
    $method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

    if ($method === 'GET') {
        apiRespond(200, ['data' => apiConfiguredPlant($db)]);
    }

    if ($method === 'PUT') {
        $data = plantInput(apiJsonInput());
        $lock = $db->query("SELECT GET_LOCK('velkoryx.planta_config', 5)")->fetchColumn();
        if ((int) $lock !== 1) {
            apiRespond(503, ['message' => 'La configuración está ocupada; inténtalo de nuevo']);
        }
        try {
            $plant = apiConfiguredPlant($db);
            $columns = array_keys($data);
            if ($plant === null) {
                $insert = ['uuid' => uuidV4(), ...$data];
                $placeholders = implode(', ', array_fill(0, count($insert), '?'));
                $statement = $db->prepare('INSERT INTO plantas (`' . implode('`, `', array_keys($insert)) . '`) VALUES (' . $placeholders . ')');
                $statement->execute(array_values($insert));
            } else {
                $assignments = implode(', ', array_map(static fn ($field) => "`{$field}` = ?", $columns));
                $statement = $db->prepare("UPDATE plantas SET {$assignments} WHERE id = ?");
                $statement->execute([...array_values($data), $plant['id']]);
            }
            $result = apiConfiguredPlant($db);
        } finally {
            $db->query("SELECT RELEASE_LOCK('velkoryx.planta_config')");
        }
        if ($plant !== null) {
            foreach (['logo', 'logo_oscuro', 'favicon'] as $field) {
                if ($plant[$field] !== $data[$field]) {
                    apiDeleteStoredImage($plant[$field]);
                }
            }
        }
        apiRespond($plant === null ? 201 : 200, ['data' => $result]);
    }

    header('Allow: GET, PUT, OPTIONS');
    apiRespond(405, ['message' => 'Método no permitido']);
} catch (DomainException $exception) {
    apiRespond(409, ['message' => $exception->getMessage()]);
} catch (PDOException $exception) {
    if ($exception->getCode() === '23000') {
        apiRespond(409, ['message' => 'Ya existe una planta con ese código para la empresa']);
    }
    error_log($exception->getMessage());
    apiRespond(500, ['message' => 'No se pudo completar la operación']);
} catch (Throwable $exception) {
    error_log($exception->getMessage());
    apiRespond(500, ['message' => 'Error interno del servidor']);
}

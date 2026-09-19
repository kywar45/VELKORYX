<?php
declare(strict_types=1);

require __DIR__ . '/bootstrap.php';

if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
    header('Allow: POST, OPTIONS');
    apiRespond(405, ['message' => 'Método no permitido']);
}

$fields = ['logo', 'logo_oscuro', 'favicon'];
$mimeExtensions = [
    'image/png' => 'png',
    'image/jpeg' => 'jpg',
    'image/webp' => 'webp',
    'image/vnd.microsoft.icon' => 'ico',
    'image/x-icon' => 'ico',
];
$uploads = [];
$finfo = new finfo(FILEINFO_MIME_TYPE);

foreach ($_FILES as $field => $file) {
    if (!in_array($field, $fields, true) || !is_array($file) || !is_string($file['tmp_name'] ?? null)) {
        apiRespond(422, ['message' => 'Campo de imagen inválido']);
    }
    if (($file['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) {
        apiRespond(422, ['message' => "No se pudo recibir {$field}"]);
    }
    if (($file['size'] ?? 0) > 5 * 1024 * 1024 || ($file['size'] ?? 0) <= 0) {
        apiRespond(422, ['message' => "La imagen {$field} debe pesar menos de 5 MB"]);
    }
    $temporary = $file['tmp_name'];
    $mime = $finfo->file($temporary);
    $dimensions = @getimagesize($temporary);
    if (!isset($mimeExtensions[$mime]) || ($mimeExtensions[$mime] === 'ico' && $field !== 'favicon')
        || $dimensions === false || $dimensions[0] * $dimensions[1] > 32000000) {
        apiRespond(422, ['message' => "La imagen {$field} debe ser PNG, JPG o WebP válido; el favicon también puede ser ICO"]);
    }
    $uploads[$field] = ['temporary' => $temporary, 'extension' => $mimeExtensions[$mime]];
}

if (!$uploads) {
    apiRespond(422, ['message' => 'Selecciona al menos una imagen']);
}

try {
    $db = apiDb();
    $lock = $db->query("SELECT GET_LOCK('velkoryx.planta_config', 5)")->fetchColumn();
    if ((int) $lock !== 1) {
        apiRespond(503, ['message' => 'La configuración está ocupada; inténtalo de nuevo']);
    }
    $created = [];
    try {
        $plant = apiConfiguredPlant($db);
        if ($plant === null) {
            throw new DomainException('Guarda primero los datos de la planta');
        }
        $directory = __DIR__ . '/uploads';
        if (!is_dir($directory) && !mkdir($directory, 0755, true)) {
            throw new RuntimeException('No se pudo crear el directorio de imágenes');
        }
        foreach ($uploads as $field => $upload) {
            $path = 'uploads/' . $field . '-' . bin2hex(random_bytes(16)) . '.' . $upload['extension'];
            if (!move_uploaded_file($upload['temporary'], __DIR__ . '/' . $path)) {
                throw new RuntimeException('No se pudo guardar la imagen');
            }
            $created[$field] = $path;
        }
        $assignments = implode(', ', array_map(static fn ($field) => "`{$field}` = ?", array_keys($created)));
        $db->beginTransaction();
        $statement = $db->prepare("UPDATE plantas SET {$assignments} WHERE id = ?");
        $statement->execute([...array_values($created), $plant['id']]);
        $db->commit();
        $result = apiConfiguredPlant($db);
        foreach ($created as $field => $path) {
            if ($plant[$field] !== $path) {
                apiDeleteStoredImage($plant[$field]);
            }
        }
    } catch (Throwable $exception) {
        if ($db->inTransaction()) {
            $db->rollBack();
        }
        foreach ($created as $path) {
            apiDeleteStoredImage($path);
        }
        throw $exception;
    } finally {
        $db->query("SELECT RELEASE_LOCK('velkoryx.planta_config')");
    }
    apiRespond(200, ['data' => $result]);
} catch (DomainException $exception) {
    apiRespond(409, ['message' => $exception->getMessage()]);
} catch (Throwable $exception) {
    error_log($exception->getMessage());
    apiRespond(500, ['message' => 'No se pudieron guardar las imágenes']);
}

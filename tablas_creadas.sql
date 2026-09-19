CREATE DATABASE `velkoryx`
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE `velkoryx`;

CREATE TABLE `plantas` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

    `uuid` CHAR(36) NOT NULL,
    `id_empresa` BIGINT UNSIGNED DEFAULT NULL,

    `codigo` VARCHAR(30) NOT NULL,
    `nombre` VARCHAR(150) NOT NULL,
    `nombre_corto` VARCHAR(80) DEFAULT NULL,
    `descripcion` VARCHAR(500) DEFAULT NULL,

    `razon_social` VARCHAR(200) DEFAULT NULL,
    `rfc` VARCHAR(20) DEFAULT NULL,

    `telefono` VARCHAR(30) DEFAULT NULL,
    `telefono_secundario` VARCHAR(30) DEFAULT NULL,
    `email` VARCHAR(150) DEFAULT NULL,
    `sitio_web` VARCHAR(250) DEFAULT NULL,

    `calle` VARCHAR(150) DEFAULT NULL,
    `numero_exterior` VARCHAR(30) DEFAULT NULL,
    `numero_interior` VARCHAR(30) DEFAULT NULL,
    `colonia` VARCHAR(150) DEFAULT NULL,
    `municipio` VARCHAR(150) DEFAULT NULL,
    `ciudad` VARCHAR(150) DEFAULT NULL,
    `estado` VARCHAR(150) DEFAULT NULL,
    `codigo_postal` VARCHAR(20) DEFAULT NULL,
    `pais` VARCHAR(100) DEFAULT NULL,

    `latitud` DECIMAL(10,7) DEFAULT NULL,
    `longitud` DECIMAL(10,7) DEFAULT NULL,

    `zona_horaria` VARCHAR(100) NOT NULL DEFAULT 'America/Mexico_City',
    `idioma` VARCHAR(10) NOT NULL DEFAULT 'es-MX',
    `moneda` CHAR(3) NOT NULL DEFAULT 'MXN',

    `logo` VARCHAR(500) DEFAULT NULL,
    `logo_oscuro` VARCHAR(500) DEFAULT NULL,
    `favicon` VARCHAR(500) DEFAULT NULL,

    `color_primario` VARCHAR(20) DEFAULT '#1683FF',
    `color_secundario` VARCHAR(20) DEFAULT '#0D1724',

    `nombre_sistema` VARCHAR(100) NOT NULL DEFAULT 'VELKORYX',
    `slogan` VARCHAR(200) DEFAULT 'Industrial Operating System',

    `estatus` TINYINT(1) NOT NULL DEFAULT 1,

    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` DATETIME DEFAULT NULL,

    PRIMARY KEY (`id`),

    UNIQUE KEY `uk_plantas_uuid` (`uuid`),
    UNIQUE KEY `uk_plantas_empresa_codigo` (`id_empresa`, `codigo`),

    KEY `idx_plantas_empresa` (`id_empresa`),
    KEY `idx_plantas_nombre` (`nombre`),
    KEY `idx_plantas_estatus` (`estatus`),
    KEY `idx_plantas_deleted_at` (`deleted_at`)
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;









CREATE TABLE `socios_comerciales` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `uuid` CHAR(36) NOT NULL,

    `id_empresa` BIGINT UNSIGNED NOT NULL,

    `codigo` VARCHAR(30) NOT NULL,

    `tipo_persona` ENUM(
        'fisica',
        'moral'
    ) NOT NULL DEFAULT 'moral',

    `nombre_comercial` VARCHAR(200) DEFAULT NULL,
    `razon_social` VARCHAR(250) NOT NULL,

    `rfc` VARCHAR(20) DEFAULT NULL,
    `curp` VARCHAR(20) DEFAULT NULL,

    `pais_fiscal` VARCHAR(100) DEFAULT NULL,

    `telefono` VARCHAR(30) DEFAULT NULL,
    `email` VARCHAR(150) DEFAULT NULL,
    `sitio_web` VARCHAR(250) DEFAULT NULL,

    `notas` TEXT DEFAULT NULL,

    `estatus` TINYINT(1) NOT NULL DEFAULT 1,

    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` DATETIME DEFAULT NULL,

    PRIMARY KEY (`id`),

    UNIQUE KEY `uk_socios_uuid` (`uuid`),
    UNIQUE KEY `uk_socios_empresa_codigo` (`id_empresa`,`codigo`),

    KEY `idx_socios_empresa` (`id_empresa`),
    KEY `idx_socios_rfc` (`rfc`),
    KEY `idx_socios_razon_social` (`razon_social`),
    KEY `idx_socios_estatus` (`estatus`)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;



CREATE TABLE `clientes` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `uuid` CHAR(36) NOT NULL,

    `id_socio_comercial` BIGINT UNSIGNED NOT NULL,

    `id_tipo_cliente` BIGINT UNSIGNED DEFAULT NULL,
    `id_lista_precio` BIGINT UNSIGNED DEFAULT NULL,
    `id_condicion_pago` BIGINT UNSIGNED DEFAULT NULL,

    `moneda` CHAR(3) NOT NULL DEFAULT 'MXN',

    `limite_credito` DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    `dias_credito` SMALLINT UNSIGNED NOT NULL DEFAULT 0,

    `saldo_credito` DECIMAL(18,2) NOT NULL DEFAULT 0.00,

    `bloqueado_credito` TINYINT(1) NOT NULL DEFAULT 0,

    `permite_sobrecredito` TINYINT(1) NOT NULL DEFAULT 0,

    `descuento_general` DECIMAL(8,4) NOT NULL DEFAULT 0.0000,

    `vendedor_id` BIGINT UNSIGNED DEFAULT NULL,

    `estatus` TINYINT(1) NOT NULL DEFAULT 1,

    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` DATETIME DEFAULT NULL,

    PRIMARY KEY (`id`),

    UNIQUE KEY `uk_clientes_uuid` (`uuid`),
    UNIQUE KEY `uk_clientes_socio` (`id_socio_comercial`),

    KEY `idx_clientes_tipo` (`id_tipo_cliente`),
    KEY `idx_clientes_lista_precio` (`id_lista_precio`),
    KEY `idx_clientes_condicion_pago` (`id_condicion_pago`),
    KEY `idx_clientes_estatus` (`estatus`)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `configuracion_clientes` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

    `id_empresa` BIGINT UNSIGNED NOT NULL,

    `prefijo_codigo` VARCHAR(10) NOT NULL DEFAULT 'CLI',

    `codigo_automatico` TINYINT(1) NOT NULL DEFAULT 1,

    `id_tipo_cliente_default` BIGINT UNSIGNED DEFAULT NULL,
    `id_lista_precio_default` BIGINT UNSIGNED DEFAULT NULL,
    `id_condicion_pago_default` BIGINT UNSIGNED DEFAULT NULL,

    `moneda_default` CHAR(3) NOT NULL DEFAULT 'MXN',

    `limite_credito_default`
        DECIMAL(18,2) NOT NULL DEFAULT 0.00,

    `permitir_sobrecredito`
        TINYINT(1) NOT NULL DEFAULT 0,

    `requiere_rfc`
        TINYINT(1) NOT NULL DEFAULT 0,

    `requiere_aprobacion_cliente`
        TINYINT(1) NOT NULL DEFAULT 0,

    `bloqueo_vencidos`
        TINYINT(1) NOT NULL DEFAULT 0,

    `dias_bloqueo_vencidos`
        SMALLINT UNSIGNED DEFAULT NULL,

    `created_at`
        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    `updated_at`
        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (`id`),

    UNIQUE KEY `uk_config_clientes_empresa` (`id_empresa`)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;



CREATE TABLE `socio_direcciones` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `uuid` CHAR(36) NOT NULL,

    `id_socio_comercial` BIGINT UNSIGNED NOT NULL,

    `tipo` ENUM(
        'fiscal',
        'envio',
        'facturacion',
        'almacen',
        'otro'
    ) NOT NULL,

    `nombre` VARCHAR(150) DEFAULT NULL,

    `calle` VARCHAR(150) DEFAULT NULL,
    `numero_exterior` VARCHAR(30) DEFAULT NULL,
    `numero_interior` VARCHAR(30) DEFAULT NULL,
    `colonia` VARCHAR(150) DEFAULT NULL,
    `municipio` VARCHAR(150) DEFAULT NULL,
    `ciudad` VARCHAR(150) DEFAULT NULL,
    `estado` VARCHAR(150) DEFAULT NULL,
    `codigo_postal` VARCHAR(20) DEFAULT NULL,
    `pais` VARCHAR(100) DEFAULT NULL,

    `latitud` DECIMAL(10,7) DEFAULT NULL,
    `longitud` DECIMAL(10,7) DEFAULT NULL,

    `predeterminada` TINYINT(1) NOT NULL DEFAULT 0,

    `estatus` TINYINT(1) NOT NULL DEFAULT 1,

    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (`id`),

    UNIQUE KEY `uk_socio_direccion_uuid` (`uuid`),

    KEY `idx_direccion_socio` (`id_socio_comercial`),
    KEY `idx_direccion_tipo` (`tipo`)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;


CREATE TABLE `socios_contactos` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `uuid` CHAR(36) NOT NULL,

    `id_socio_comercial` BIGINT UNSIGNED NOT NULL,

    `nombre` VARCHAR(150) NOT NULL,
    `apellido_paterno` VARCHAR(100) DEFAULT NULL,
    `apellido_materno` VARCHAR(100) DEFAULT NULL,

    `puesto` VARCHAR(150) DEFAULT NULL,
    `departamento` VARCHAR(150) DEFAULT NULL,

    `tipo_contacto` ENUM(
        'general',
        'compras',
        'pagos',
        'facturacion',
        'logistica',
        'ventas',
        'direccion',
        'administracion',
        'otro'
    ) NOT NULL DEFAULT 'general',

    `telefono` VARCHAR(30) DEFAULT NULL,
    `extension` VARCHAR(20) DEFAULT NULL,
    `celular` VARCHAR(30) DEFAULT NULL,
    `whatsapp` VARCHAR(30) DEFAULT NULL,

    `email` VARCHAR(150) DEFAULT NULL,
    `email_secundario` VARCHAR(150) DEFAULT NULL,

    `preferido` TINYINT(1) NOT NULL DEFAULT 0,
    `recibe_facturas` TINYINT(1) NOT NULL DEFAULT 0,
    `recibe_estado_cuenta` TINYINT(1) NOT NULL DEFAULT 0,
    `recibe_notificaciones` TINYINT(1) NOT NULL DEFAULT 1,

    `notas` VARCHAR(1000) DEFAULT NULL,

    `estatus` TINYINT(1) NOT NULL DEFAULT 1,

    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` DATETIME DEFAULT NULL,

    PRIMARY KEY (`id`),

    UNIQUE KEY `uk_socios_contactos_uuid` (`uuid`),

    KEY `idx_contactos_socio` (`id_socio_comercial`),
    KEY `idx_contactos_tipo` (`tipo_contacto`),
    KEY `idx_contactos_nombre` (`nombre`),
    KEY `idx_contactos_email` (`email`),
    KEY `idx_contactos_estatus` (`estatus`),
    KEY `idx_contactos_preferido` (`preferido`),

    CONSTRAINT `fk_socios_contactos_socio`
        FOREIGN KEY (`id_socio_comercial`)
        REFERENCES `socios_comerciales` (`id`)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;


CREATE TABLE `tipos_socios` (
    `id` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,

    `codigo` VARCHAR(30) NOT NULL,
    `nombre` VARCHAR(100) NOT NULL,
    `descripcion` VARCHAR(300) DEFAULT NULL,

    `es_sistema` TINYINT(1) NOT NULL DEFAULT 1,
    `estatus` TINYINT(1) NOT NULL DEFAULT 1,

    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (`id`),

    UNIQUE KEY `uk_tipos_socios_codigo` (`codigo`),

    KEY `idx_tipos_socios_estatus` (`estatus`)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;


INSERT INTO `tipos_socios`
(
    `codigo`,
    `nombre`,
    `descripcion`
)
VALUES
(
    'CLIENTE',
    'Cliente',
    'Persona o empresa que compra productos o servicios'
),
(
    'PROVEEDOR',
    'Proveedor',
    'Persona o empresa que suministra productos, materias primas o servicios'
),
(
    'TRANSPORTISTA',
    'Transportista',
    'Empresa o persona encargada del transporte de mercancías'
),
(
    'CONTRATISTA',
    'Contratista',
    'Empresa o persona que presta servicios especializados'
);


CREATE TABLE `socios_roles` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

    `uuid` CHAR(36) NOT NULL,

    `id_socio_comercial` BIGINT UNSIGNED NOT NULL,
    `id_tipo_socio` SMALLINT UNSIGNED NOT NULL,

    `estatus` TINYINT(1) NOT NULL DEFAULT 1,

    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` DATETIME DEFAULT NULL,

    PRIMARY KEY (`id`),

    UNIQUE KEY `uk_socios_roles_uuid` (`uuid`),

    UNIQUE KEY `uk_socio_tipo`
        (`id_socio_comercial`, `id_tipo_socio`),

    KEY `idx_socios_roles_socio`
        (`id_socio_comercial`),

    KEY `idx_socios_roles_tipo`
        (`id_tipo_socio`),

    KEY `idx_socios_roles_estatus`
        (`estatus`),

    CONSTRAINT `fk_socios_roles_socio`
        FOREIGN KEY (`id_socio_comercial`)
        REFERENCES `socios_comerciales` (`id`)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT `fk_socios_roles_tipo`
        FOREIGN KEY (`id_tipo_socio`)
        REFERENCES `tipos_socios` (`id`)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;
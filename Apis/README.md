# Apis

Aqui iremos creando los archivos del servidor. Esta carpeta esta fuera de `src` y no se incluye en el build de Quasar, por lo que podras mover su contenido al servidor del endpoint.

La URL base que usa el frontend se configura en `.env.local` mediante `VITE_API_BASE_URL`. El archivo `.env.example` muestra el formato. Al cambiar la variable, reinicia el servidor de desarrollo o vuelve a compilar la app.

Desde el frontend, usa `apiUrl('clientes.php')` de `src/services/api.js` para construir la URL de cada endpoint. La variable contiene solo una URL publica; nunca guardes claves privadas en variables `VITE_`.

## Plantas

`plantas.php` trabaja con la unica planta configurada en `velkoryx.plantas` y devuelve JSON:

- `GET plantas.php`: devuelve `{"data": null}` si aun no existe la configuracion, o el registro completo.
- `PUT plantas.php`: crea la configuracion inicial o actualiza el mismo registro. Requiere un objeto JSON con los campos de la planta.

No hay operaciones para crear una segunda planta ni para dar de baja la configuracion. Si la tabla ya contiene mas de una planta activa, la API responde con un conflicto hasta que se corrijan esos datos.

`POST planta-imagenes.php` recibe archivos multipart en los campos `logo`, `logo_oscuro` y `favicon`. Admite PNG, JPG y WebP de hasta 5 MB por archivo; el favicon tambien admite ICO. Hay que guardar primero la configuracion de la planta. Los archivos se almacenan en `Apis/uploads` con nombres aleatorios y la tabla guarda rutas relativas a la base de la API. Al mover `Apis` a otro servidor, conserva tambien la carpeta `uploads` y dale permisos de escritura al proceso PHP. Los archivos subidos se ignoran en Git.

La conexion PHP lee `VELKORYX_DB_HOST`, `VELKORYX_DB_NAME`, `VELKORYX_DB_USER` y `VELKORYX_DB_PASSWORD` del entorno del servidor. Para el entorno local actual usa por defecto `127.0.0.1`, `velkoryx`, `root` y contrasena vacia. `VELKORYX_ALLOWED_ORIGINS` acepta una lista de origenes separados por comas; por defecto permite el frontend local en el puerto 9000.

La API no tiene autenticacion todavia. Antes de exponerla en un servidor publico, hay que agregar control de acceso y usar un usuario de base de datos con permisos limitados.

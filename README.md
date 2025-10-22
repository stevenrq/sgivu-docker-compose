# 🧩 SGIVU - sgivu-docker-compose

## 📘 Descripción

Repositorio de infraestructura para levantar el ecosistema de microservicios de SGIVU mediante Docker Compose. Aquí se definen los contenedores, redes, dependencias y credenciales compartidas que permiten iniciar los servicios en entornos locales y productivos.

## 🧱 Rol en la Arquitectura

- Orquesta los servicios de configuración, descubrimiento, gateway, autenticación, usuarios y clientes de SGIVU.
- Expone imágenes pre construidas (`stevenrq/*`) y servicios de terceros como Zipkin y las bases de datos necesarias.
- Actúa como punto de entrada para levantar todas las piezas del backend en conjunto, reduciendo la fricción entre equipos de desarrollo y operación.

## ⚙️ Estructura del Repositorio

```
├── .env                        # Variables de entorno para despliegues en AWS (no se versiona)
├── .env.dev                    # Variables de entorno para desarrollo local (no se versiona)
├── clave.pem                   # Clave privada para acceso SSH a instancias EC2 (no se versiona)
├── docker-compose.yml          # Definición principal orientada a entornos productivos
├── docker-compose.dev.yml      # Variante local con bases de datos auto gestionadas
├── LICENSE
└── README.md
```

## 🚀 Ejecución

Uso recomendado para desarrollo local:

```bash
docker compose -f docker-compose.dev.yml --env-file .env.dev up -d
```

Para un entorno productivo (usando imágenes y endpoints remotos):

```bash
docker compose up -d
```

Para detener la plataforma completa:

```bash
docker compose down
```

Agrega `-v` si necesitas limpiar los volúmenes creados durante las pruebas.

## 🔧 Configuración

- `.env.dev`: define URLs internas, credenciales de MySQL/PostgreSQL para contenedores locales y secretos compartidos. Úsalo como base pero reemplaza los valores sensibles antes de compartirlo.
- `.env`: orientado a despliegues en AWS; contiene endpoints de RDS, contraseñas y secretos. Refuerza el versionado seguro evitando exponer credenciales reales.

## 🌐 Interacción con Otros Repositorios

- `sgivu-config` publica su configuración a través de este stack para el resto de microservicios.
- `sgivu-config-repo` provee los YAML consumidos por `sgivu-config`.
- Microservicios como `sgivu-auth`, `sgivu-user`, `sgivu-client` y `sgivu-gateway` se despliegan aquí mediante imágenes pre construidas.

## 🧮 Buenas Prácticas

- Mantén sincronizados los nombres de contenedor y puertos con los utilizados en cada microservicio.
- Evita commitear secretos reales en archivos `.env`; usa placeholders y gestores de secretos externos.
- Versiona tus imágenes con tags (`stevenrq/sgivu-auth:v1`, etc.) y documenta los cambios al actualizar.
- Revisa dependencias en `depends_on` después de agregar nuevos servicios para garantizar el orden correcto de arranque.

## ☁️ Despliegue en AWS

- Ajusta `docker-compose.yml` para apuntar a recursos administrados (RDS, S3) usando variables definidas en `.env`.
- Carga `clave.pem` en el directorio `.ssh` de la instancia y asegúrate de asignar permisos restrictivos (`chmod 400`).
- Expón únicamente los puertos necesarios mediante reglas de seguridad en el Security Group y considera colocar el Gateway detrás de un Load Balancer.

## ✨ Autor

- Steven Ricardo Quiñones
- **Año:** 2025

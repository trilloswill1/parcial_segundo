#!/bin/sh
# Punto de entrada de la imagen Docker.
# 1) Genera WEB-INF/db.properties con las credenciales que llegan por variable de entorno.
# 2) Ajusta el puerto de escucha de Tomcat al valor de PORT (Render lo define).
# 3) Arranca Tomcat.
set -e

APP_DIR="${APP_DIR:-/usr/local/tomcat/webapps/ROOT}"
PROPS_FILE="$APP_DIR/WEB-INF/db.properties"

DB_HOST="${DB_HOST:-bxqkmbn2kft1klg6vy31-mysql.services.clever-cloud.com}"
DB_PORT="${DB_PORT:-3306}"
DB_NAME="${DB_NAME:-bxqkmbn2kft1klg6vy31}"
DB_USER="${DB_USER:-uw4y08f5stqokclb}"
DB_PARAMS="${DB_PARAMS:-useUnicode=true&characterEncoding=UTF-8&useSSL=false&allowPublicKeyRetrieval=true}"

if [ -n "${DB_URL}" ]; then
  JDBC_URL="$DB_URL"
else
  JDBC_URL="jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}?${DB_PARAMS}"
fi

if [ -z "${DB_PASSWORD}" ]; then
  echo "ERROR: falta la variable de entorno DB_PASSWORD." >&2
  echo "Configurala en Render > Environment > Environment Variables." >&2
  exit 1
fi

# En un .properties de Java el backslash debe ir escapado
DB_PASSWORD_ESC=$(printf '%s' "$DB_PASSWORD" | sed 's/\\/\\\\/g')

mkdir -p "$(dirname "$PROPS_FILE")"
{
  echo "db.url=$JDBC_URL"
  echo "db.user=$DB_USER"
  echo "db.password=$DB_PASSWORD_ESC"
} > "$PROPS_FILE"

# Render asigna el puerto de escucha en la variable PORT (por defecto 10000)
if [ -n "${PORT}" ] && [ "${PORT}" != "8080" ]; then
  sed -i "s/port=\"8080\"/port=\"${PORT}\"/g" /usr/local/tomcat/conf/server.xml
fi

exec "$@"

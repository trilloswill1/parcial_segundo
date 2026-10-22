# Sistema de Trabajos de Grado UTS

Aplicación web JSP + JSTL (JavaServer Pages) sobre Apache Tomcat 8.5 con base de datos MySQL en Clever Cloud.

## Estructura

```
index.jsp              Ingreso al sistema
validar_login.jsp      Validacion de credenciales
logout.jsp             Cierre de sesion
admin/                 Panel del administrador
coordinacion/          Panel de coordinacion
director/              Panel de director
evaluador/             Panel de evaluador
estudiante/            Panel de estudiante
comun/                 Paginas compartidas
pqrs/                  Modulo de PQRS
css/, img/             Recursos estaticos
sql/                   Script de creacion de la base de datos
WEB-INF/jspf/          Fragmentos JSP incluidos (inicio.jspf = conexion a BD)
WEB-INF/lib/           Drivers y librerias (JSTL, MySQL Connector/J)
META-INF/context.xml   Contexto de la aplicacion
```

## Requisitos

- Java 8 o superior
- Apache Tomcat 8.5
- MySQL 5.7+ / 8.0

## Despliegue local (XAMPP / Tomcat)

1. Copia el driver `mysql-connector-java-5.1.49.jar` a `C:\xampp\tomcat\lib\`.
2. Crea `WEB-INF/db.properties` (NO se versiona en Git):

```properties
db.url=jdbc:mysql://HOST:3306/BASE?useUnicode=true&characterEncoding=UTF-8&useSSL=false&allowPublicKeyRetrieval=true
db.user=USUARIO
db.password=CONTRASENA
```

3. Importa el esquema: `sql/trabajos_grado.sql`.
4. Inicia Tomcat y abre `http://localhost:8080/Parcial_segundo/`.

## Despliegue en Render (Docker)

El repositorio ya incluye el `Dockerfile` necesario. En Render:

1. **New > Web Service > Connect a tu repositorio de GitHub.**
2. **Runtime: Docker** (Render lo detecta por el `Dockerfile`).
3. **Environment Variables** — agrega:

   | Clave | Valor |
   |---|---|
   | `DB_HOST` | `bxqkmbn2kft1klg6vy31-mysql.services.clever-cloud.com` |
   | `DB_PORT` | `3306` |
   | `DB_NAME` | `bxqkmbn2kft1klg6vy31` |
   | `DB_USER` | `uw4y08f5stqokclb` |
   | `DB_PASSWORD` | *(la contraseña real de Clever Cloud)* |

   Opcional: `DB_URL` completo para reemplazar la URL de conexion.
4. **Health Check Path:** `/index.jsp`.
5. **Deploy Web Service.**

El `docker-entrypoint.sh` genera `WEB-INF/db.properties` con esas variables, ajusta el puerto de Tomcat al `PORT` que asigna Render y arranca el servidor.

## Notas

- La aplicacion se despliega como contexto `ROOT`, por eso las rutas internas usan `<c:url value='/...'/>` y funcionan en cualquier subruta.
- Los archivos subidos por estudiantes se guardan en `WEB-INF/documentos/entregas/`, dentro del contenedor. En Render el disco es efimero: los archivos se pierden en cada redespliegue. Para persistencia, monta un disco o usa un almacenamiento externo.
- `.gitignore` excluye `WEB-INF/db.properties` y los temporales de Tomcat.

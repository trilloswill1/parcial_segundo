-- =====================================================================
--  Sistema de Gestión de Trabajos de Grado - UTS
--  Script único de base de datos (MySQL / MariaDB)
--  Ejecutar completo en phpMyAdmin / MySQL Workbench / consola.
--  Contraseña de TODOS los usuarios de prueba: Uts2026*
--
--  El script es IDEMPOTENTE: se puede ejecutar varias veces sobre la misma
--  base de datos sin borrar nada. Nunca usa DROP DATABASE ni DROP TABLE;
--  solo crea lo que falta (CREATE TABLE IF NOT EXISTS) y carga los datos de
--  prueba que todavía no existan.
--
--  Tablas que define (8):
--    usuarios, ideas, anteproyectos, entrega_final, sustentacion,
--    calendario_academico, formatos_grado, notificaciones
-- =====================================================================

-- ---------------------------------------------------------------------
--  BASE DE DATOS
--  - Si la base todavía no existe se crea; si ya existe NO se borra ni se
--    recrea (importante en Clever Cloud, donde el addon ya entrega la base
--    creada y el usuario no tiene permiso de CREATE DATABASE).
--  - Se trabaja sobre 'trabajos_grado', la misma base que usa la aplicación
--    (WEB-INF/jspf/inicio.jspf).
-- ---------------------------------------------------------------------
SET NAMES utf8mb4;

SET @bd_proyecto = 'trabajos_grado';
SET @bd_existe   = (SELECT COUNT(*) FROM information_schema.SCHEMATA
                     WHERE SCHEMA_NAME = @bd_proyecto);
SET @sql_bd = IF(@bd_existe = 0,
                 CONCAT('CREATE DATABASE `', @bd_proyecto, '` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci'),
                 'DO 0');
PREPARE stmt FROM @sql_bd;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

USE trabajos_grado;

-- ---------------------------------------------------------------------
--  USUARIOS (los 5 roles viven en la misma tabla)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS usuarios (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  codigo         VARCHAR(20)  NOT NULL UNIQUE,   -- código institucional (el estudiante lo usa para ser buscado)
  nombres        VARCHAR(80)  NOT NULL,
  apellido1      VARCHAR(50)  NOT NULL,
  apellido2      VARCHAR(50)  NULL,
  correo         VARCHAR(100) NOT NULL UNIQUE,
  clave          VARCHAR(64)  NOT NULL,          -- SHA2(clave,256)
  rol            ENUM('administrador','coordinacion','director','evaluador','estudiante') NOT NULL,
  estado         ENUM('activo','inactivo') NOT NULL DEFAULT 'activo',
  fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
--  IDEAS DE ANTEPROYECTO (las crea Coordinación, las selecciona el estudiante)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ideas (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  titulo         VARCHAR(150) NOT NULL,
  descripcion    TEXT         NOT NULL,
  estado         ENUM('disponible','tomada') NOT NULL DEFAULT 'disponible',
  id_coordinador INT          NOT NULL,
  fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_idea_coord FOREIGN KEY (id_coordinador) REFERENCES usuarios(id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
--  ANTEPROYECTOS
--  Flujo de estado:
--    radicado  -> (Coordinación asigna director y evaluador)
--    con_director -> (Director califica y aprueba)
--    aprobado_director -> (Evaluador aprueba)
--    aprobado
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS anteproyectos (
  id                      INT AUTO_INCREMENT PRIMARY KEY,
  id_estudiante           INT          NOT NULL UNIQUE,  -- un anteproyecto por estudiante
  id_idea                 INT          NOT NULL UNIQUE,  -- una idea la toma un solo estudiante
  titulo                  VARCHAR(150) NOT NULL,
  resumen                 TEXT         NOT NULL,
  enlace_documento        VARCHAR(255) NULL,             -- enlace al documento (no se suben archivos)
  id_director             INT          NULL,
  id_evaluador            INT          NULL,
  estado                  ENUM('radicado','con_director','aprobado_director','aprobado') NOT NULL DEFAULT 'radicado',
  nota_director           DECIMAL(3,1) NULL,             -- 0.0 a 5.0
  observaciones_director  TEXT         NULL,
  observaciones_evaluador TEXT         NULL,
  fecha_registro          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ante_est   FOREIGN KEY (id_estudiante) REFERENCES usuarios(id),
  CONSTRAINT fk_ante_idea  FOREIGN KEY (id_idea)       REFERENCES ideas(id),
  CONSTRAINT fk_ante_dir   FOREIGN KEY (id_director)   REFERENCES usuarios(id),
  CONSTRAINT fk_ante_eva   FOREIGN KEY (id_evaluador)  REFERENCES usuarios(id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
--  ENTREGAS FINALES
--  Documento final que radica el estudiante (PDF) una vez el anteproyecto
--  está en estado 'aprobado'. Coordinación revisa y cambia el estado:
--    Entregado -> En revisión -> Aprobado / Rechazado
--  Si la entrega es rechazada el estudiante puede subir una nueva versión:
--  se conservan las anteriores (el historial se consulta por id_anteproyecto).
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS entrega_final (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  id_anteproyecto INT          NOT NULL,
  id_estudiante   INT          NOT NULL,
  nombre_archivo  VARCHAR(255) NOT NULL,   -- nombre original del PDF subido
  ruta_archivo    VARCHAR(500) NOT NULL,   -- ruta relativa dentro de WEB-INF/documentos/entregas
  fecha_entrega   DATETIME     DEFAULT CURRENT_TIMESTAMP,
  estado          ENUM('Entregado','En revisión','Aprobado','Rechazado') NOT NULL DEFAULT 'Entregado',
  observaciones   TEXT         NULL,       -- observaciones de la revisión de coordinación
  CONSTRAINT fk_entrega_anteproyecto FOREIGN KEY (id_anteproyecto) REFERENCES anteproyectos(id) ON UPDATE CASCADE,
  CONSTRAINT fk_entrega_estudiante   FOREIGN KEY (id_estudiante)   REFERENCES usuarios(id)       ON UPDATE CASCADE,
  INDEX idx_entrega_anteproyecto (id_anteproyecto),
  INDEX idx_entrega_estudiante (id_estudiante)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
--  SUSTENTACIONES
--  Programada por Coordinación solo cuando el anteproyecto está 'aprobado'
--  y existe una entrega final en estado 'Aprobado'.
--    Programada -> Realizada / Cancelada
--  Los dos jurados son docentes (director y evaluador) y deben ser
--  diferentes; el estudiante confirma su sustentación desde el portal.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sustentacion (
  id                 INT AUTO_INCREMENT PRIMARY KEY,
  id_anteproyecto    INT          NOT NULL,
  fecha_sustentacion DATE         NOT NULL,
  hora_sustentacion  TIME         NOT NULL,
  lugar              VARCHAR(255) NULL,        -- lugar físico (opcional)
  enlace             VARCHAR(500) NULL,        -- enlace de la reunión virtual (opcional)
  jurado_1           INT          NULL,
  jurado_2           INT          NULL,
  estado             ENUM('Programada','Realizada','Cancelada') NOT NULL DEFAULT 'Programada',
  calificacion       DECIMAL(5,2) NULL,        -- 0.0 a 5.0
  observaciones      TEXT         NULL,
  fecha_creacion     DATETIME     DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_sustentacion_anteproyecto FOREIGN KEY (id_anteproyecto) REFERENCES anteproyectos(id) ON UPDATE CASCADE,
  CONSTRAINT fk_sustentacion_jurado1 FOREIGN KEY (jurado_1) REFERENCES usuarios(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_sustentacion_jurado2 FOREIGN KEY (jurado_2) REFERENCES usuarios(id) ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX idx_sustentacion_anteproyecto (id_anteproyecto),
  INDEX idx_sustentacion_jurado1 (jurado_1),
  INDEX idx_sustentacion_jurado2 (jurado_2)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
--  CALENDARIO ACADÉMICO y FORMATOS DE GRADO (solo consulta)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS calendario_academico (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  evento       VARCHAR(120) NOT NULL,
  descripcion  VARCHAR(255) NULL,
  fecha_inicio DATE         NOT NULL,
  fecha_fin    DATE         NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS formatos_grado (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  nombre      VARCHAR(120) NOT NULL,
  descripcion VARCHAR(255) NULL,
  enlace      VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
--  NOTIFICACIONES
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS notificaciones (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  tipo_evento     VARCHAR(50)  NOT NULL,
  titulo          VARCHAR(150) NOT NULL,
  descripcion     TEXT         NULL,
  id_usuario      INT          NULL,
  id_referencia   INT          NULL,
  tabla_referencia VARCHAR(50)  NULL,
  leida           BOOLEAN      NOT NULL DEFAULT FALSE,
  fecha_creacion  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_notif_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios(id) ON DELETE SET NULL,
  INDEX idx_notif_usuario (id_usuario),
  INDEX idx_notif_leida (leida),
  INDEX idx_notif_fecha (fecha_creacion),
  INDEX idx_notif_ref (tabla_referencia, id_referencia)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
--  PQRS (Peticiones, Quejas, Reclamos y Sugerencias)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pqrs (
  id                INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario        INT          NULL,
  codigo_usuario    VARCHAR(20)  NULL,
  nombre_usuario    VARCHAR(150) NULL,
  correo_usuario    VARCHAR(100) NULL,
  rol_usuario       ENUM('administrador','coordinacion','director','evaluador','estudiante') NULL,
  tipo              ENUM('Petición','Queja','Reclamo','Sugerencia') NOT NULL,
  asunto            VARCHAR(150) NOT NULL,
  descripcion       TEXT         NOT NULL,
  estado            ENUM('pendiente','en proceso','resuelta') NOT NULL DEFAULT 'pendiente',
  fecha_creacion    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_pqrs_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios(id) ON DELETE SET NULL,
  INDEX idx_pqrs_usuario (id_usuario),
  INDEX idx_pqrs_estado (estado),
  INDEX idx_pqrs_fecha (fecha_creacion)
) ENGINE=InnoDB;

-- =====================================================================
--  DATOS DE PRUEBA
--  Cada bloque inserta únicamente lo que todavía no existe, por lo que
--  reejecutar el script no duplica información.
-- =====================================================================

--  Usuarios: INSERT IGNORE porque 'codigo' y 'correo' son únicos.
INSERT IGNORE INTO usuarios (codigo, nombres, apellido1, apellido2, correo, clave, rol) VALUES
('ADM001','Carlos Andrés','Rojas','Pérez',      'admin@uts.edu.co',        SHA2('Uts2026*',256),'administrador'), -- id 1
('COO001','Marcela',      'Duarte','Villamizar','coordinacion@uts.edu.co', SHA2('Uts2026*',256),'coordinacion'),  -- id 2
('DIR001','Jorge Enrique','Camargo','Silva',    'director1@uts.edu.co',    SHA2('Uts2026*',256),'director'),      -- id 3
('DIR002','Diana Patricia','Ortiz','Rueda',     'director2@uts.edu.co',    SHA2('Uts2026*',256),'director'),      -- id 4
('EVA001','Hernán Darío', 'Mejía', 'Cala',      'evaluador1@uts.edu.co',   SHA2('Uts2026*',256),'evaluador'),     -- id 5
('EVA002','Sandra Milena','Quintero','Ardila',  'evaluador2@uts.edu.co',   SHA2('Uts2026*',256),'evaluador'),     -- id 6
('2026001','Laura Valentina','Gómez','Suárez',  'laura.gomez@uts.edu.co',  SHA2('Uts2026*',256),'estudiante'),    -- id 7
('2026002','Santiago Andrés','Pardo','Niño',    'santiago.pardo@uts.edu.co',SHA2('Uts2026*',256),'estudiante'),   -- id 8
('2026003','Camila Fernanda','Rey','Barrera',   'camila.rey@uts.edu.co',   SHA2('Uts2026*',256),'estudiante'),    -- id 9
('2026004','Andrés Felipe', 'Cardona','Rangel',  'andres.cardona@uts.edu.co',SHA2('Uts2026*',256),'estudiante');    -- id 10

--  Ideas del banco de proyectos.
INSERT INTO ideas (titulo, descripcion, estado, id_coordinador)
SELECT n.titulo, n.descripcion, n.estado, n.id_coordinador
FROM (
  SELECT 'Sistema de gestión de inventarios para PYMES' AS titulo,
         'Aplicación web para controlar entradas, salidas y existencias de pequeños comercios de Bucaramanga.' AS descripcion,
         'tomada' AS estado, 2 AS id_coordinador
  UNION ALL
  SELECT 'Plataforma de seguimiento académico para colegios',
         'Portal que permite a docentes registrar notas y a acudientes consultarlas en línea.',
         'tomada', 2
  UNION ALL
  SELECT 'Aplicación de reservas para canchas deportivas',
         'Sistema de reserva y pago de canchas sintéticas con calendario de disponibilidad.',
         'tomada', 2
  UNION ALL
  SELECT 'Sistema de control de acceso con códigos QR',
         'Registro de ingreso y salida de visitantes en edificios corporativos mediante QR.',
         'disponible', 2
  UNION ALL
  SELECT 'Portal de ofertas de empleo para egresados',
         'Bolsa de empleo donde empresas publican vacantes y egresados aplican a ellas.',
         'disponible', 2
  UNION ALL
  SELECT 'Sistema de predicción de demanda para pequeños comercios',
         'Aplicación web que analiza el histórico de ventas de un comercio y proyecta la demanda de cada producto.',
         'tomada', 2
) AS n
WHERE NOT EXISTS (SELECT 1 FROM ideas i WHERE i.titulo = n.titulo);

--  Anteproyectos: se referencian por código de usuario y por título de idea
--  para que el script funcione también sobre bases ya existentes.
INSERT IGNORE INTO anteproyectos
  (id_estudiante, id_idea, titulo, resumen, enlace_documento, id_director, id_evaluador, estado, nota_director, observaciones_director, observaciones_evaluador)
SELECT e.id, i.id, 'Sistema web de inventarios para tiendas de barrio',
       'Se desarrollará una aplicación web que permita registrar productos, proveedores y movimientos de inventario, generando alertas de stock mínimo.',
       'https://drive.google.com/ejemplo-anteproyecto-1',
       d.id, v.id, 'aprobado_director', 4.2,
       'Buena justificación y objetivos claros. Se recomienda detallar el cronograma.',
       NULL
FROM usuarios e
JOIN ideas i    ON i.titulo = 'Sistema de gestión de inventarios para PYMES'
JOIN usuarios d ON d.codigo = 'DIR001'
JOIN usuarios v ON v.codigo = 'EVA001'
WHERE e.codigo = '2026001'
  AND NOT EXISTS (SELECT 1 FROM anteproyectos a WHERE a.id_estudiante = e.id);

INSERT IGNORE INTO anteproyectos
  (id_estudiante, id_idea, titulo, resumen, enlace_documento, id_director, id_evaluador, estado, nota_director, observaciones_director, observaciones_evaluador)
SELECT e.id, i.id, 'Portal de notas y seguimiento para instituciones educativas',
       'Se construirá un portal web donde los docentes cargan calificaciones por periodo y los acudientes pueden consultarlas.',
       NULL,
       NULL, NULL, 'radicado', NULL, NULL, NULL
FROM usuarios e
JOIN ideas i    ON i.titulo = 'Plataforma de seguimiento académico para colegios'
WHERE e.codigo = '2026002'
  AND NOT EXISTS (SELECT 1 FROM anteproyectos a WHERE a.id_estudiante = e.id);

INSERT IGNORE INTO anteproyectos
  (id_estudiante, id_idea, titulo, resumen, enlace_documento, id_director, id_evaluador, estado, nota_director, observaciones_director, observaciones_evaluador)
SELECT e.id, i.id, 'Sistema de reservas para canchas deportivas',
       'La aplicación permitirá consultar horarios disponibles, reservar canchas y administrar los pagos de cada reserva.',
       'https://drive.google.com/ejemplo-anteproyecto-3',
       d.id, v.id, 'con_director', NULL, NULL, NULL
FROM usuarios e
JOIN ideas i    ON i.titulo = 'Aplicación de reservas para canchas deportivas'
JOIN usuarios d ON d.codigo = 'DIR002'
JOIN usuarios v ON v.codigo = 'EVA002'
WHERE e.codigo = '2026003'
  AND NOT EXISTS (SELECT 1 FROM anteproyectos a WHERE a.id_estudiante = e.id);

--  Anteproyecto que completa el flujo (estado 'aprobado') del estudiante 10:
--  es el que puede radicar la entrega final y luego tener una sustentación
--  programada.
INSERT IGNORE INTO anteproyectos
  (id_estudiante, id_idea, titulo, resumen, enlace_documento, id_director, id_evaluador, estado, nota_director, observaciones_director, observaciones_evaluador)
SELECT e.id, i.id, 'Sistema web de predicción de demanda para comercios de barrio',
       'Se desarrollará una aplicación web que analice el histórico de ventas de pequeños comercios y proyecte la demanda de cada producto, generando recomendaciones de reposición.',
       'https://drive.google.com/ejemplo-anteproyecto-4',
       d.id, v.id, 'aprobado', 4.6,
       'Metodología clara, objetivos medibles y alcance bien delimitado.',
       'Cumple con los criterios de evaluación; se aprueba el anteproyecto.'
FROM usuarios e
JOIN ideas i    ON i.titulo = 'Sistema de predicción de demanda para pequeños comercios'
JOIN usuarios d ON d.codigo = 'DIR001'
JOIN usuarios v ON v.codigo = 'EVA001'
WHERE e.codigo = '2026004'
  AND NOT EXISTS (SELECT 1 FROM anteproyectos a WHERE a.id_estudiante = e.id);

--  Entrega final ya revisada y aprobada por coordinación.
--  La ruta apunta al PDF de ejemplo que ya existe en el repositorio
--  (WEB-INF/documentos/entregas) para que la descarga funcione.
INSERT INTO entrega_final (id_anteproyecto, id_estudiante, nombre_archivo, ruta_archivo, fecha_entrega, estado, observaciones)
SELECT a.id, e.id, 'documento_final_prediccion_demanda.pdf',
       'WEB-INF/documentos/entregas/entrega_6_1792173180825_e3dac38692d84bb2a26d95f6e15b82bc.pdf',
       '2026-11-19 09:30:00', 'Aprobado',
       'El documento cumple el formato de entrega final; se aprueba la versión enviada.'
FROM anteproyectos a
JOIN usuarios e ON e.id = a.id_estudiante
WHERE e.codigo = '2026004'
  AND NOT EXISTS (SELECT 1 FROM entrega_final ef
                  WHERE ef.id_anteproyecto = a.id
                    AND ef.nombre_archivo = 'documento_final_prediccion_demanda.pdf');

--  Sustentación programada para ese mismo proyecto (jurados: director y
--  evaluador, tal como los exige el formulario de coordinación).
INSERT INTO sustentacion (id_anteproyecto, fecha_sustentacion, hora_sustentacion, lugar, enlace, jurado_1, jurado_2, estado)
SELECT a.id, '2026-11-27', '09:00:00',
       'Sala de reuniones 1 - Sede Principal UTS',
       'https://meet.google.com/uts-trabajo-grado',
       j1.id, j2.id, 'Programada'
FROM anteproyectos a
JOIN usuarios e  ON e.id = a.id_estudiante
JOIN usuarios j1 ON j1.codigo = 'DIR001'
JOIN usuarios j2 ON j2.codigo = 'EVA001'
WHERE e.codigo = '2026004'
  AND NOT EXISTS (SELECT 1 FROM sustentacion s
                  WHERE s.id_anteproyecto = a.id
                    AND s.fecha_sustentacion = '2026-11-27');

--  Calendario académico.
INSERT INTO calendario_academico (evento, descripcion, fecha_inicio, fecha_fin)
SELECT n.evento, n.descripcion, n.fecha_inicio, n.fecha_fin
FROM (
  SELECT 'Inicio de clases 2026-II' AS evento,
         'Comienzo del segundo periodo académico.' AS descripcion,
         '2026-08-03' AS fecha_inicio, NULL AS fecha_fin
  UNION ALL
  SELECT 'Radicación de anteproyectos',
         'Plazo para que los estudiantes radiquen su anteproyecto.',
         '2026-08-10', '2026-08-28'
  UNION ALL
  SELECT 'Asignación de director y evaluador',
         'Coordinación asigna director y evaluador a cada anteproyecto.',
         '2026-09-01', '2026-09-11'
  UNION ALL
  SELECT 'Revisión y calificación del director',
         'El director califica y aprueba los anteproyectos.',
         '2026-09-14', '2026-10-02'
  UNION ALL
  SELECT 'Evaluación final del anteproyecto',
         'El evaluador revisa y aprueba los anteproyectos.',
         '2026-10-05', '2026-10-23'
  UNION ALL
  SELECT 'Entrega final del documento de grado',
         'Fecha límite para la entrega del documento final.',
         '2026-11-20', NULL
) AS n
WHERE NOT EXISTS (SELECT 1 FROM calendario_academico c WHERE c.evento = n.evento);

--  Formatos de grado.
INSERT INTO formatos_grado (nombre, descripcion, enlace)
SELECT n.nombre, n.descripcion, n.enlace
FROM (
  SELECT 'Formato de idea de proyecto' AS nombre,
         'Plantilla para presentar la idea inicial del trabajo de grado.' AS descripcion,
         'https://www.uts.edu.co/' AS enlace
  UNION ALL
  SELECT 'Formato de anteproyecto',
         'Estructura requerida para radicar el anteproyecto.',
         'https://www.uts.edu.co/'
  UNION ALL
  SELECT 'Formato de evaluación del anteproyecto',
         'Rúbrica usada por director y evaluador.',
         'https://www.uts.edu.co/'
  UNION ALL
  SELECT 'Formato de entrega final del documento',
         'Lineamientos de presentación del documento de grado.',
         'https://www.uts.edu.co/'
) AS n
WHERE NOT EXISTS (SELECT 1 FROM formatos_grado f WHERE f.nombre = n.nombre);

-- =====================================================================
--  PROCEDIMIENTO DE DESPLIEGUE
--
--  1) Instalación local nueva (XAMPP), desde la consola de MySQL:
--       mysql -u root < sql/trabajos_grado.sql
--     o desde phpMyAdmin: Importar -> sql/trabajos_grado.sql
--
--  2) Actualizar una base existente (no borra datos, no duplica pruebas):
--       mysql -u root trabajos_grado < sql/trabajos_grado.sql
--
--  3) Clever Cloud (addon MySQL). El addon entrega la base ya creada y el
--     usuario solo tiene permisos sobre ella, por lo que el script se
--     ejecuta sobre la base seleccionada:
--       mysql -h "$CLEVER_DATABASE_HOST" -u "$CLEVER_DATABASE_USER" \
--             -p"$CLEVER_DATABASE_PASSWORD" "$CLEVER_DATABASE_NAME" \
--             < sql/trabajos_grado.sql
--     Si el nombre de la base del addon es distinto de 'trabajos_grado'
--     (nombre que usa la aplicación en WEB-INF/jspf/inicio.jspf), comenta
--     la línea "USE trabajos_grado;" de este archivo o ajústala al nombre
--     real de la base.
--
--  Este script NO ejecuta DROP DATABASE ni DROP TABLE: reejecutarlo sobre
--  una base con datos solo agrega lo que falte.
-- =====================================================================

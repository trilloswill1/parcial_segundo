<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="administrador"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Panel"/>
<c:set var="menuActivo"   value="panel"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<%-- Consulto los totales de usuarios por rol --%>
<sql:query var="total" dataSource="${bd}">
  SELECT COUNT(*) AS n FROM usuarios
</sql:query>
<sql:query var="estudiantes" dataSource="${bd}">
  SELECT COUNT(*) AS n FROM usuarios WHERE rol = 'estudiante'
</sql:query>
<sql:query var="directores" dataSource="${bd}">
  SELECT COUNT(*) AS n FROM usuarios WHERE rol = 'director'
</sql:query>
<sql:query var="evaluadores" dataSource="${bd}">
  SELECT COUNT(*) AS n FROM usuarios WHERE rol = 'evaluador'
</sql:query>
<sql:query var="coordinaciones" dataSource="${bd}">
  SELECT COUNT(*) AS n FROM usuarios WHERE rol = 'coordinacion'
</sql:query>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-th-large"></i>Hola, <c:out value="${sessionScope.usuarioNombre}"/></h1>
    <p class="page-subtitle">Resumen de usuarios del sistema de trabajos de grado.</p>
  </div>
  <div class="page-actions">
    <a class="btn-uts" href="<c:url value='/admin/usuario_form.jsp'/>">
      <i class="fas fa-user-plus"></i> Nuevo usuario
    </a>
  </div>
</div>

<%-- Tarjetas de estadísticas --%>
<div class="row g-3 mb-4">
  <div class="col-6 col-xl-4">
    <div class="stat-card">
      <div class="stat-icon"><i class="fas fa-users"></i></div>
      <div>
        <div class="stat-valor"><c:out value="${total.rows[0].n}"/></div>
        <div class="stat-etiqueta">Usuarios totales</div>
      </div>
    </div>
  </div>
  <div class="col-6 col-xl-4">
    <div class="stat-card">
      <div class="stat-icon azul"><i class="fas fa-user-graduate"></i></div>
      <div>
        <div class="stat-valor"><c:out value="${estudiantes.rows[0].n}"/></div>
        <div class="stat-etiqueta">Estudiantes</div>
      </div>
    </div>
  </div>
  <div class="col-6 col-xl-4">
    <div class="stat-card">
      <div class="stat-icon verde"><i class="fas fa-chalkboard-teacher"></i></div>
      <div>
        <div class="stat-valor"><c:out value="${directores.rows[0].n}"/></div>
        <div class="stat-etiqueta">Directores</div>
      </div>
    </div>
  </div>
  <div class="col-6 col-xl-4">
    <div class="stat-card">
      <div class="stat-icon ambar"><i class="fas fa-clipboard-check"></i></div>
      <div>
        <div class="stat-valor"><c:out value="${evaluadores.rows[0].n}"/></div>
        <div class="stat-etiqueta">Evaluadores</div>
      </div>
    </div>
  </div>
  <div class="col-6 col-xl-4">
    <div class="stat-card">
      <div class="stat-icon rojo"><i class="fas fa-user-tie"></i></div>
      <div>
        <div class="stat-valor"><c:out value="${coordinaciones.rows[0].n}"/></div>
        <div class="stat-etiqueta">Coordinación</div>
      </div>
    </div>
  </div>
  <div class="col-6 col-xl-4">
    <a class="acceso-rapido" href="<c:url value='/admin/usuarios.jsp'/>">
      <span class="acceso-icono"><i class="fas fa-users-cog"></i></span>
      <span>
        <strong>Gestionar usuarios</strong>
        <small>Crear, editar y eliminar</small>
      </span>
    </a>
  </div>
</div>

<%-- Accesos rápidos --%>
<div class="card-ui">
  <div class="card-ui-header">
    <h2 class="card-ui-titulo"><i class="fas fa-bolt"></i>Accesos rápidos</h2>
  </div>
  <div class="row g-3">
    <div class="col-md-6 col-xl-4">
      <a class="acceso-rapido" href="<c:url value='/admin/notificaciones.jsp'/>">
        <span class="acceso-icono"><i class="fas fa-bell"></i></span>
        <span>
          <strong>Notificaciones</strong>
          <small>Ver actividad del sistema</small>
        </span>
      </a>
    </div>
    <div class="col-md-6 col-xl-4">
      <a class="acceso-rapido" href="<c:url value='/admin/usuarios.jsp'/>">
        <span class="acceso-icono"><i class="fas fa-list"></i></span>
        <span>
          <strong>Ver listado de usuarios</strong>
          <small>Todos los roles en una tabla</small>
        </span>
      </a>
    </div>
    <div class="col-md-6 col-xl-4">
      <a class="acceso-rapido" href="<c:url value='/admin/usuario_form.jsp'/>">
        <span class="acceso-icono"><i class="fas fa-user-plus"></i></span>
        <span>
          <strong>Registrar usuario</strong>
          <small>Docentes, coordinación y alumnos</small>
        </span>
      </a>
    </div>
    <div class="col-md-6 col-xl-4">
      <a class="acceso-rapido" href="<c:url value='/comun/calendario.jsp'/>">
        <span class="acceso-icono"><i class="fas fa-calendar-alt"></i></span>
        <span>
          <strong>Calendario académico</strong>
          <small>Fechas importantes del periodo</small>
        </span>
      </a>
    </div>
<div class="col-md-6 col-xl-4">
      <a class="acceso-rapido" href="<c:url value='/coordinacion/ideas.jsp'/>">
        <span class="acceso-icono"><i class="fas fa-lightbulb"></i></span>
        <span>
          <strong>Banco de Ideas</strong>
          <small>Crear y administrar ideas</small>
        </span>
      </a>
    </div>
    <div class="col-md-6 col-xl-4">
      <a class="acceso-rapido" href="<c:url value='/coordinacion/anteproyectos.jsp'/>">
        <span class="acceso-icono"><i class="fas fa-folder-open"></i></span>
        <span>
          <strong>Anteproyectos</strong>
          <small>Buscar y asignar director y evaluador</small>
        </span>
      </a>
    </div>
    <div class="col-md-6 col-xl-4">
      <a class="acceso-rapido" href="<c:url value='/coordinacion/informe_estudiantes.jsp'/>">
        <span class="acceso-icono"><i class="fas fa-user-graduate"></i></span>
        <span>
          <strong>Informe de estudiantes</strong>
          <small>Estado del proyecto por alumno</small>
        </span>
      </a>
    </div>
    <div class="col-md-6 col-xl-4">
      <a class="acceso-rapido" href="<c:url value='/coordinacion/informe_directores.jsp'/>">
        <span class="acceso-icono"><i class="fas fa-chalkboard-teacher"></i></span>
        <span>
          <strong>Informe de directores</strong>
          <small>Carga y avance por director</small>
        </span>
      </a>
    </div>
    <div class="col-md-6 col-xl-4">
      <a class="acceso-rapido" href="<c:url value='/coordinacion/informe_evaluadores.jsp'/>">
        <span class="acceso-icono"><i class="fas fa-clipboard-check"></i></span>
        <span>
          <strong>Informe de evaluadores</strong>
          <small>Pendientes y aprobaciones</small>
        </span>
      </a>
    </div>
    <div class="col-md-6 col-xl-4">
      <a class="acceso-rapido" href="<c:url value='/comun/formatos.jsp'/>">
        <span class="acceso-icono"><i class="fas fa-file-alt"></i></span>
        <span>
          <strong>Formatos de grado</strong>
          <small>Plantillas oficiales</small>
        </span>
      </a>
    </div>
  </div>
</div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>

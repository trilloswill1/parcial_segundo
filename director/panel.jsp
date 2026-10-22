<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="director"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Panel"/>
<c:set var="menuActivo"   value="panel"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<%-- Conteo de mis anteproyectos por estado --%>
<sql:query var="asignados" dataSource="${bd}">
  SELECT COUNT(*) AS n FROM anteproyectos WHERE id_director = ?
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<sql:query var="porCalificar" dataSource="${bd}">
  SELECT COUNT(*) AS n FROM anteproyectos WHERE id_director = ? AND estado = 'con_director'
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<sql:query var="aprobados" dataSource="${bd}">
  SELECT COUNT(*) AS n FROM anteproyectos
  WHERE id_director = ? AND estado IN ('aprobado_director','aprobado')
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-th-large"></i>Hola, <c:out value="${sessionScope.usuarioNombre}"/></h1>
    <p class="page-subtitle">Anteproyectos asignados a ti como director.</p>
  </div>
</div>

<%-- Tarjetas de estadísticas --%>
<div class="row g-3 mb-4">
  <div class="col-6 col-xl-4">
    <div class="stat-card">
      <div class="stat-icon azul"><i class="fas fa-folder-open"></i></div>
      <div>
        <div class="stat-valor"><c:out value="${asignados.rows[0].n}"/></div>
        <div class="stat-etiqueta">Anteproyectos asignados</div>
      </div>
    </div>
  </div>
  <div class="col-6 col-xl-4">
    <div class="stat-card">
      <div class="stat-icon ambar"><i class="fas fa-pen"></i></div>
      <div>
        <div class="stat-valor"><c:out value="${porCalificar.rows[0].n}"/></div>
        <div class="stat-etiqueta">Por calificar</div>
      </div>
    </div>
  </div>
  <div class="col-6 col-xl-4">
    <div class="stat-card">
      <div class="stat-icon verde"><i class="fas fa-check-double"></i></div>
      <div>
        <div class="stat-valor"><c:out value="${aprobados.rows[0].n}"/></div>
        <div class="stat-etiqueta">Aprobados por mí</div>
      </div>
    </div>
  </div>
</div>

<%-- Accesos rápidos --%>
<div class="card-ui">
  <div class="card-ui-header">
    <h2 class="card-ui-titulo"><i class="fas fa-bolt"></i>Accesos rápidos</h2>
  </div>
  <div class="row g-3">
    <div class="col-md-6 col-xl-4">
      <a class="acceso-rapido" href="<c:url value='/director/notificaciones.jsp'/>">
        <span class="acceso-icono"><i class="fas fa-bell"></i></span>
        <span>
          <strong>Notificaciones</strong>
          <small>Asignaciones y aprobaciones</small>
        </span>
      </a>
    </div>
    <div class="col-md-6 col-xl-4">
      <a class="acceso-rapido" href="<c:url value='/director/anteproyectos.jsp'/>">
        <span class="acceso-icono"><i class="fas fa-folder-open"></i></span>
        <span>
          <strong>Mis anteproyectos</strong>
          <small>Calificar y aprobar</small>
        </span>
      </a>
    </div>
    <div class="col-md-6 col-xl-4">
      <a class="acceso-rapido" href="<c:url value='/comun/calendario.jsp'/>">
        <span class="acceso-icono"><i class="fas fa-calendar-alt"></i></span>
        <span>
          <strong>Calendario académico</strong>
          <small>Fechas importantes</small>
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

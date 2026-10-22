<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="estudiante"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Panel"/>
<c:set var="menuActivo"   value="panel"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<%-- Consulto si el estudiante ya tiene anteproyecto --%>
<sql:query var="ant" dataSource="${bd}">
  SELECT a.id, a.titulo, a.estado, CONCAT(i.titulo) AS idea
  FROM anteproyectos a
  JOIN ideas i ON i.id = a.id_idea
  WHERE a.id_estudiante = ?
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>

<%-- ¿El estudiante ya tiene una sustentación programada? --%>
<sql:query var="sust" dataSource="${bd}">
  SELECT s.id, s.fecha_sustentacion, s.hora_sustentacion, s.estado
  FROM sustentacion s
  JOIN anteproyectos a ON a.id = s.id_anteproyecto
  WHERE a.id_estudiante = ?
  ORDER BY s.id DESC
  LIMIT 1
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-th-large"></i>Hola, <c:out value="${sessionScope.usuarioNombre}"/></h1>
    <p class="page-subtitle">Estado de tu trabajo de grado.</p>
  </div>
</div>

<c:choose>
  <c:when test="${ant.rowCount == 0}">

    <%-- Aún no tiene anteproyecto --%>
    <div class="card-ui">
      <div class="empty-state">
        <i class="fas fa-folder-open"></i>
        <h5>Todavía no tienes anteproyecto</h5>
        <p>Selecciona una idea de proyecto disponible y radica tu anteproyecto.</p>
        <a class="btn-uts" href="<c:url value='/estudiante/ideas.jsp'/>">
          <i class="fas fa-lightbulb"></i> Ver Banco de Ideas
        </a>
      </div>
    </div>

  </c:when>
  <c:otherwise>
    <c:forEach var="a" items="${ant.rows}">

      <%-- Estado y progreso --%>
      <div class="card-ui">
        <div class="card-ui-header">
          <h2 class="card-ui-titulo"><i class="fas fa-folder-open"></i>Mi anteproyecto</h2>
          <c:set var="estadoValor" value="${a.estado}"/>
          <%@ include file="/WEB-INF/jspf/estado_badge.jspf" %>
        </div>
        <h3 style="font-size:1.1rem;"><c:out value="${a.titulo}"/></h3>
        <p class="text-muted mb-3">Idea de origen: <c:out value="${a.idea}"/></p>
        <%@ include file="/WEB-INF/jspf/estado_stepper.jspf" %>
      </div>

      <%-- Accesos rápidos --%>
      <div class="row g-3">
        <div class="col-md-6 col-xl-4">
          <a class="acceso-rapido" href="<c:url value='/estudiante/notificaciones.jsp'/>">
            <span class="acceso-icono"><i class="fas fa-bell"></i></span>
            <span>
              <strong>Notificaciones</strong>
              <small>Radicados y calificaciones</small>
            </span>
          </a>
        </div>
        <div class="col-md-6 col-xl-4">
          <a class="acceso-rapido" href="<c:url value='/estudiante/mi_anteproyecto.jsp'/>">
            <span class="acceso-icono"><i class="fas fa-file-alt"></i></span>
            <span>
              <strong>Ver mi anteproyecto</strong>
              <small>Director, evaluador y documento</small>
            </span>
          </a>
        </div>
        <div class="col-md-6 col-xl-4">
          <a class="acceso-rapido" href="<c:url value='/estudiante/entrega_final.jsp'/>">
            <span class="acceso-icono"><i class="fas fa-file-upload"></i></span>
            <span>
              <strong>Entrega final</strong>
              <small>Sube tu documento PDF</small>
            </span>
          </a>
        </div>
        <div class="col-md-6 col-xl-4">
          <c:choose>
            <c:when test="${sust.rowCount > 0}">
              <a class="acceso-rapido" href="<c:url value='/estudiante/sustentacion.jsp'/>">
                <span class="acceso-icono"><i class="fas fa-gavel"></i></span>
                <span>
                  <strong>Sustentación</strong>
                  <small>Consulta fecha, hora y estado</small>
                </span>
              </a>
            </c:when>
            <c:otherwise>
              <div class="acceso-rapido acceso-rapido-off">
                <span class="acceso-icono"><i class="fas fa-gavel"></i></span>
                <span>
                  <strong>Sustentación</strong>
                  <small>Se habilita cuando coordinación la programe</small>
                </span>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
        <div class="col-md-6 col-xl-4">
          <a class="acceso-rapido" href="<c:url value='/estudiante/calificacion.jsp'/>">
            <span class="acceso-icono"><i class="fas fa-star"></i></span>
            <span>
              <strong>Mi calificación</strong>
              <small>Nota y observaciones</small>
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
      </div>

    </c:forEach>
  </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>

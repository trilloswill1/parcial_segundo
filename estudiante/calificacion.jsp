<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="estudiante"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Mi calificación"/>
<c:set var="menuActivo"   value="calificacion"/>

<%-- El estudiante solo consulta su propia nota --%>
<sql:query var="rs" dataSource="${bd}">
  SELECT a.titulo, a.estado, a.nota_director, a.observaciones_director, a.observaciones_evaluador,
         CONCAT(d.nombres,' ',d.apellido1,' ',COALESCE(d.apellido2,'')) AS director
  FROM anteproyectos a
  LEFT JOIN usuarios d ON d.id = a.id_director
  WHERE a.id_estudiante = ?
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>

<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-star"></i>Mi calificación</h1>
    <p class="page-subtitle">Nota de tu anteproyecto y observaciones de los docentes.</p>
  </div>
</div>

<c:choose>
  <c:when test="${rs.rowCount == 0}">
    <div class="card-ui">
      <div class="empty-state">
        <i class="fas fa-star"></i>
        <h5>Aún no has radicado un anteproyecto</h5>
        <p>Radica tu anteproyecto para que puedas ver la calificación del director.</p>
        <a class="btn-uts" href="<c:url value='/estudiante/ideas.jsp'/>"><i class="fas fa-lightbulb"></i> Ver ideas</a>
      </div>
    </div>
  </c:when>
  <c:otherwise>
    <c:forEach var="a" items="${rs.rows}">

      <%-- Tarjeta grande con la nota del director --%>
      <div class="stat-card">
        <span class="stat-icon ${not empty a.nota_director ? 'verde' : 'ambar'}">
          <i class="fas ${not empty a.nota_director ? 'fa-star' : 'fa-clock'}"></i>
        </span>
        <div>
          <span class="stat-valor">
            <c:choose>
              <c:when test="${not empty a.nota_director}">
                <fmt:formatNumber value="${a.nota_director}" pattern="0.0"/><small>/5.0</small>
              </c:when>
              <c:otherwise>Pendiente</c:otherwise>
            </c:choose>
          </span>
          <span class="stat-etiqueta">Nota del director</span>
        </div>
      </div>

      <div class="row g-4 mt-1">
        <div class="col-lg-7">
          <div class="card-ui">
            <div class="card-ui-header">
              <h2 class="card-ui-titulo"><i class="fas fa-tasks"></i>Estado del anteproyecto</h2>
              <c:set var="estadoValor" value="${a.estado}"/>
              <%@ include file="/WEB-INF/jspf/estado_badge.jspf" %>
            </div>
            <c:set var="estadoValor" value="${a.estado}"/>
            <%@ include file="/WEB-INF/jspf/estado_stepper.jspf" %>
          </div>
        </div>

        <div class="col-lg-5">
          <div class="card-ui">
            <div class="card-ui-header">
              <h2 class="card-ui-titulo"><i class="fas fa-user-tie"></i>Evaluado por</h2>
            </div>
            <div class="info-grid">
              <div class="info-par">
                <span class="info-etiqueta">Anteproyecto</span><span class="info-valor"><c:out value="${a.titulo}"/></span>
              </div>
              <div class="info-par">
                <span class="info-etiqueta">Director</span><span class="info-valor"><c:out value="${a.director}"/></span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <%-- Observaciones de director y evaluador --%>
      <div class="card-ui">
        <div class="card-ui-header">
          <h2 class="card-ui-titulo"><i class="fas fa-comments"></i>Observaciones</h2>
        </div>
        <div class="info-grid">
          <div class="info-par">
            <span class="info-etiqueta">Del director</span>
            <span class="info-valor">
              <c:choose>
                <c:when test="${not empty a.observaciones_director}"><c:out value="${a.observaciones_director}"/></c:when>
                <c:otherwise><span class="texto-resumen">Aún no hay observaciones del director.</span></c:otherwise>
              </c:choose>
            </span>
          </div>
          <div class="info-par">
            <span class="info-etiqueta">Del evaluador</span>
            <span class="info-valor">
              <c:choose>
                <c:when test="${not empty a.observaciones_evaluador}"><c:out value="${a.observaciones_evaluador}"/></c:when>
                <c:otherwise><span class="texto-resumen">Aún no hay observaciones del evaluador.</span></c:otherwise>
              </c:choose>
            </span>
          </div>
        </div>
      </div>

    </c:forEach>
  </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
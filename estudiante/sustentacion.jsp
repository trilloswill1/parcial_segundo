<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="estudiante"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Sustentación"/>
<c:set var="menuActivo"   value="sustentacion"/>

<%-- El estudiante solo consulta su propia sustentación --%>
<sql:query var="rs" dataSource="${bd}">
  SELECT s.id, s.fecha_sustentacion, s.hora_sustentacion, s.lugar, s.enlace, s.estado,
         s.calificacion, s.observaciones, s.fecha_creacion,
         CONCAT(a.titulo) AS titulo,
         CONCAT(j1.nombres,' ',j1.apellido1) AS jurado1,
         CONCAT(j2.nombres,' ',j2.apellido1) AS jurado2
  FROM sustentacion s
  JOIN anteproyectos a ON a.id = s.id_anteproyecto
  LEFT JOIN usuarios j1 ON j1.id = s.jurado_1
  LEFT JOIN usuarios j2 ON j2.id = s.jurado_2
  WHERE a.id_estudiante = ?
  ORDER BY s.id DESC
  LIMIT 1
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>

<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-gavel"></i>Mi sustentación</h1>
    <p class="page-subtitle">Información de la sustentación programada por coordinación.</p>
  </div>
</div>

<c:choose>
  <c:when test="${rs.rowCount == 0}">
    <div class="card-ui">
      <div class="empty-state">
        <i class="fas fa-calendar-times"></i>
        <h5>Aún no tienes una sustentación programada</h5>
        <p>Cuando coordinación programe tu sustentación, aquí verás la fecha, la hora y el lugar o enlace.</p>
      </div>
    </div>
  </c:when>

  <c:otherwise>
    <c:set var="s" value="${rs.rows[0]}"/>

    <div class="card-ui">
      <div class="card-ui-header">
        <h2 class="card-ui-titulo"><i class="fas fa-calendar-alt"></i>Programación</h2>
        <c:set var="sustEstado" value="${s.estado}"/>
        <%@ include file="/WEB-INF/jspf/sustentacion_badge.jspf" %>
      </div>
      <p class="text-muted mb-3">Proyecto: <c:out value="${s.titulo}"/></p>

      <div class="info-grid">
        <div class="info-par"><span class="info-etiqueta">Fecha</span><span class="info-valor"><fmt:formatDate value="${s.fecha_sustentacion}" pattern="dd/MM/yyyy"/></span></div>
        <div class="info-par"><span class="info-etiqueta">Hora</span><span class="info-valor"><fmt:formatDate value="${s.hora_sustentacion}" pattern="HH:mm"/></span></div>
        <div class="info-par">
          <span class="info-etiqueta">Lugar</span>
          <span class="info-valor">
            <c:choose>
              <c:when test="${not empty s.lugar}"><c:out value="${s.lugar}"/></c:when>
              <c:otherwise><span class="texto-resumen">Sin lugar físico</span></c:otherwise>
            </c:choose>
          </span>
        </div>
        <div class="info-par">
          <span class="info-etiqueta">Enlace</span>
          <span class="info-valor">
            <c:choose>
              <c:when test="${not empty s.enlace}"><c:out value="${s.enlace}"/></c:when>
              <c:otherwise><span class="texto-resumen">—</span></c:otherwise>
            </c:choose>
          </span>
        </div>
        <div class="info-par"><span class="info-etiqueta">Jurado 1</span><span class="info-valor"><c:out value="${s.jurado1}"/></span></div>
        <div class="info-par"><span class="info-etiqueta">Jurado 2</span><span class="info-valor"><c:out value="${s.jurado2}"/></span></div>
      </div>
    </div>

    <%-- Acción del estudiante: confirmar su sustentación programada --%>
    <c:choose>
      <c:when test="${s.estado == 'Programada'}">
        <div class="card-ui mt-4">
          <div class="card-ui-header">
            <h2 class="card-ui-titulo"><i class="fas fa-gavel"></i>Confirmar mi sustentación</h2>
          </div>
          <p class="text-muted mb-3">Cuando hayas sustentado, márcala como realizada.</p>
          <form method="post" action="<c:url value='/estudiante/sustentacion_confirmar.jsp'/>"
                onsubmit="return confirm('¿Confirmas que deseas marcar tu sustentación como realizada?');">
            <input type="hidden" name="id" value="${s.id}">
            <button type="submit" class="btn-exito"><i class="fas fa-check-circle"></i> Sustentar</button>
          </form>
        </div>
      </c:when>
      <c:when test="${s.estado == 'Realizada'}">
        <div class="mt-4">
          <button type="button" class="btn-exito" disabled><i class="fas fa-check-circle"></i> Sustentación realizada</button>
        </div>
      </c:when>
    </c:choose>

    <c:if test="${s.estado == 'Realizada' || not empty s.calificacion || not empty s.observaciones}">
      <div class="card-ui mt-4">
        <div class="card-ui-header">
          <h2 class="card-ui-titulo"><i class="fas fa-clipboard-check"></i>Resultado</h2>
        </div>
        <div class="info-grid">
          <div class="info-par">
            <span class="info-etiqueta">Calificación</span>
            <span class="info-valor">
              <c:choose>
                <c:when test="${not empty s.calificacion}">
                  <strong><fmt:formatNumber value="${s.calificacion}" pattern="0.0"/></strong><small>/5.0</small>
                </c:when>
                <c:otherwise><span class="texto-resumen">Sin calificación registrada.</span></c:otherwise>
              </c:choose>
            </span>
          </div>
          <div class="info-par">
            <span class="info-etiqueta">Observaciones</span>
            <span class="info-valor">
              <c:choose>
                <c:when test="${not empty s.observaciones}"><c:out value="${s.observaciones}"/></c:when>
                <c:otherwise><span class="texto-resumen">Sin observaciones.</span></c:otherwise>
              </c:choose>
            </span>
          </div>
        </div>
      </div>
    </c:if>
  </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>

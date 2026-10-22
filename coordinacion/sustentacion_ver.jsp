<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="coordinacion"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Sustentación"/>
<c:set var="menuActivo"   value="panel"/>

<%-- Detalle de la sustentación seleccionada --%>
<sql:query var="rs" dataSource="${bd}">
  SELECT s.id, s.id_anteproyecto, s.fecha_sustentacion, s.hora_sustentacion, s.lugar, s.enlace,
         s.estado, s.calificacion, s.observaciones, s.fecha_creacion,
         CONCAT(e.nombres,' ',e.apellido1,' ',COALESCE(e.apellido2,'')) AS estudiante,
         CONCAT(e.codigo) AS codigo_estudiante, CONCAT(e.correo) AS correo_estudiante,
         CONCAT(a.titulo) AS titulo,
         CONCAT(j1.nombres,' ',j1.apellido1) AS jurado1,
         CONCAT(j2.nombres,' ',j2.apellido1) AS jurado2
  FROM sustentacion s
  JOIN anteproyectos a ON a.id = s.id_anteproyecto
  JOIN usuarios e ON e.id = a.id_estudiante
  LEFT JOIN usuarios j1 ON j1.id = s.jurado_1
  LEFT JOIN usuarios j2 ON j2.id = s.jurado_2
  WHERE s.id = ?
  <sql:param value="${param.id}"/>
</sql:query>

<c:if test="${rs.rowCount == 0}">
  <c:redirect url="/coordinacion/panel.jsp">
    <c:param name="error" value="La sustentación no existe"/>
  </c:redirect>
</c:if>

<c:set var="s" value="${rs.rows[0]}"/>

<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-gavel"></i>Sustentación</h1>
    <p class="page-subtitle"><c:out value="${s.titulo}"/></p>
  </div>
  <div class="page-actions">
    <a class="btn-uts-outline gris" href="<c:url value='/coordinacion/panel.jsp'/>"><i class="fas fa-arrow-left"></i> Volver</a>
  </div>
</div>

<div class="row g-4">
  <div class="col-lg-6">
    <div class="card-ui">
      <div class="card-ui-header">
        <h2 class="card-ui-titulo"><i class="fas fa-user-graduate"></i>Estudiante</h2>
        <c:set var="sustEstado" value="${s.estado}"/>
        <%@ include file="/WEB-INF/jspf/sustentacion_badge.jspf" %>
      </div>
      <div class="info-grid">
        <div class="info-par"><span class="info-etiqueta">Código</span><span class="info-valor"><c:out value="${s.codigo_estudiante}"/></span></div>
        <div class="info-par"><span class="info-etiqueta">Nombre</span><span class="info-valor"><c:out value="${s.estudiante}"/></span></div>
        <div class="info-par"><span class="info-etiqueta">Correo</span><span class="info-valor"><c:out value="${s.correo_estudiante}"/></span></div>
      </div>
    </div>
  </div>

  <div class="col-lg-6">
    <div class="card-ui">
      <div class="card-ui-header">
        <h2 class="card-ui-titulo"><i class="fas fa-calendar-alt"></i>Programación</h2>
      </div>
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
        <c:if test="${not empty s.calificacion}">
          <div class="info-par"><span class="info-etiqueta">Calificación</span><span class="info-valor"><fmt:formatNumber value="${s.calificacion}" pattern="0.0"/><small>/5.0</small></span></div>
        </c:if>
      </div>
    </div>
  </div>
</div>

<div class="card-ui mt-4">
  <div class="card-ui-header">
    <h2 class="card-ui-titulo"><i class="fas fa-clipboard-check"></i>Registro de la sustentación</h2>
  </div>

  <form class="form-ui" method="post" action="<c:url value='/coordinacion/sustentacion_estado_guardar.jsp'/>" novalidate>
    <input type="hidden" name="id" value="${s.id}">
    <div class="row g-3">
      <div class="col-md-4">
        <div class="form-floating">
          <select class="form-select" id="estado" name="estado">
            <option value="Programada" ${s.estado == 'Programada' ? 'selected' : ''}>Programada</option>
            <option value="Realizada"  ${s.estado == 'Realizada'  ? 'selected' : ''}>Realizada</option>
            <option value="Cancelada"  ${s.estado == 'Cancelada'  ? 'selected' : ''}>Cancelada</option>
          </select>
          <label for="estado">Estado</label>
        </div>
      </div>
      <div class="col-md-4">
        <div class="form-floating">
          <input type="number" class="form-control" id="calificacion" name="calificacion" step="0.1" min="0" max="5"
                 value="<c:out value='${s.calificacion}'/>" placeholder="Calificación">
          <label for="calificacion">Calificación (0.0 a 5.0, opcional)</label>
        </div>
      </div>
      <div class="col-md-4 d-flex align-items-center">
        <p class="form-help mb-0">Marca la sustentación como <strong>Realizada</strong> cuando ya se haya llevado a cabo y registra la calificación u observaciones si corresponde.</p>
      </div>
      <div class="col-12">
        <div class="form-floating">
          <textarea class="form-control" id="observaciones" name="observaciones" placeholder="Observaciones"
                    style="height:120px"><c:out value="${s.observaciones}"/></textarea>
          <label for="observaciones">Observaciones de la sustentación</label>
        </div>
      </div>
    </div>
    <div class="d-flex gap-2 mt-4">
      <button type="submit" class="btn-uts"><i class="fas fa-save"></i> Guardar</button>
    </div>
  </form>
</div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>

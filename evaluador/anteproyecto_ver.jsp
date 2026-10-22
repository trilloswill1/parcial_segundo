<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="evaluador"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Evaluar anteproyecto"/>
<c:set var="menuActivo"   value="anteproyectos"/>

<%-- El evaluador solo ve los anteproyectos asignados a él --%>
<sql:query var="rs" dataSource="${bd}">
  SELECT a.id, a.titulo, a.resumen, a.enlace_documento, a.estado, a.fecha_registro,
         a.nota_director, a.observaciones_director, a.observaciones_evaluador,
         CONCAT(e.nombres,' ',e.apellido1,' ',COALESCE(e.apellido2,'')) AS estudiante,
         CONCAT(e.codigo) AS codigo_estudiante, CONCAT(e.correo) AS correo_estudiante,
         CONCAT(d.nombres,' ',d.apellido1) AS director,
         CONCAT(i.titulo) AS idea
  FROM anteproyectos a
  JOIN usuarios e ON e.id = a.id_estudiante
  LEFT JOIN usuarios d ON d.id = a.id_director
  JOIN ideas i ON i.id = a.id_idea
  WHERE a.id = ? AND a.id_evaluador = ?
  <sql:param value="${param.id}"/>
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>

<c:if test="${rs.rowCount == 0}">
  <c:redirect url="/evaluador/anteproyectos.jsp">
    <c:param name="error" value="El anteproyecto no existe o no está asignado a ti"/>
  </c:redirect>
</c:if>

<c:set var="a" value="${rs.rows[0]}"/>

<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-clipboard-check"></i>Evaluar anteproyecto</h1>
    <p class="page-subtitle"><c:out value="${a.titulo}"/></p>
  </div>
  <div class="page-actions">
    <a class="btn-uts-outline gris" href="<c:url value='/evaluador/anteproyectos.jsp'/>">
      <i class="fas fa-arrow-left"></i> Volver
    </a>
  </div>
</div>

<div class="row g-4">
  <div class="col-lg-6">
    <div class="card-ui">
      <div class="card-ui-header">
        <h2 class="card-ui-titulo"><i class="fas fa-user-graduate"></i>Información del alumno</h2>
      </div>
      <div class="info-grid">
        <div class="info-par">
          <span class="info-etiqueta">Código</span><span class="info-valor"><c:out value="${a.codigo_estudiante}"/></span>
        </div>
        <div class="info-par">
          <span class="info-etiqueta">Nombre completo</span><span class="info-valor"><c:out value="${a.estudiante}"/></span>
        </div>
        <div class="info-par">
          <span class="info-etiqueta">Correo</span><span class="info-valor"><c:out value="${a.correo_estudiante}"/></span>
        </div>
        <div class="info-par">
          <span class="info-etiqueta">Fecha de radicación</span><span class="info-valor"><fmt:formatDate value="${a.fecha_registro}" pattern="dd/MM/yyyy"/></span>
        </div>
        <div class="info-par">
          <span class="info-etiqueta">Director</span><span class="info-valor"><c:out value="${a.director}"/></span>
        </div>
      </div>
      <c:if test="${not empty a.enlace_documento}">
        <a class="btn-uts-outline mt-3" href="<c:out value='${a.enlace_documento}'/>" target="_blank" rel="noopener">
          <i class="fas fa-external-link-alt"></i> Ver documento
        </a>
      </c:if>
    </div>
  </div>

  <div class="col-lg-6">
    <div class="card-ui">
      <div class="card-ui-header">
        <h2 class="card-ui-titulo"><i class="fas fa-star"></i>Nota y observaciones del director</h2>
      </div>
      <div class="info-grid">
        <div class="info-par">
          <span class="info-etiqueta">Nota del director</span>
          <span class="info-valor">
            <span class="nota-grande">
              <c:choose>
                <c:when test="${not empty a.nota_director}"><fmt:formatNumber value="${a.nota_director}" pattern="0.0"/></c:when>
                <c:otherwise>—</c:otherwise>
              </c:choose>
            </span> / 5.0
          </span>
        </div>
        <div class="info-par">
          <span class="info-etiqueta">Observaciones del director</span>
          <span class="info-valor">
            <c:choose>
              <c:when test="${not empty a.observaciones_director}"><c:out value="${a.observaciones_director}"/></c:when>
              <c:otherwise><span class="texto-resumen">Sin observaciones.</span></c:otherwise>
            </c:choose>
          </span>
        </div>
      </div>
    </div>
  </div>
</div>

<div class="card-ui mt-4">
  <div class="card-ui-header">
    <h2 class="card-ui-titulo"><i class="fas fa-comments"></i>Mi evaluación</h2>
    <c:set var="estadoValor" value="${a.estado}"/>
    <%@ include file="/WEB-INF/jspf/estado_badge.jspf" %>
  </div>

  <c:choose>
    <%-- Anteproyecto aprobado por el director: permite observar y aprobar --%>
    <c:when test="${a.estado == 'aprobado_director'}">

      <c:if test="${not empty a.observaciones_evaluador}">
        <div class="info-grid mb-3">
          <div class="info-par">
            <span class="info-etiqueta">Tus observaciones</span>
            <span class="info-valor"><c:out value="${a.observaciones_evaluador}"/></span>
          </div>
        </div>
      </c:if>

      <form class="form-ui" method="post" action="<c:url value='/evaluador/observaciones_guardar.jsp'/>" novalidate>
        <input type="hidden" name="id" value="${a.id}">
        <div class="row g-3">
          <div class="col-md-12">
            <div class="form-floating">
              <textarea class="form-control" id="observaciones" name="observaciones"
                        placeholder="Observaciones del evaluador" style="height:110px"><c:out value="${a.observaciones_evaluador}"/></textarea>
              <label for="observaciones">Observaciones</label>
            </div>
            <p class="form-help">Recomendaciones y comentarios al estudiante sobre el anteproyecto.</p>
          </div>
        </div>
        <div class="d-flex gap-2 mt-4">
          <button type="submit" class="btn-uts"><i class="fas fa-save"></i> Guardar observaciones</button>
        </div>
      </form>

      <hr class="my-4">
      <div class="d-flex flex-wrap align-items-center gap-3">
        <div>
          <h6 class="fw-semibold mb-1"><i class="fas fa-check-circle"></i> Aprobación final</h6>
          <span class="texto-resumen">Al aprobar, el anteproyecto queda dispuesto para el estudiante y la coordinación.</span>
        </div>
        <form method="post" action="<c:url value='/evaluador/aprobar.jsp'/>" class="ms-auto">
          <input type="hidden" name="id" value="${a.id}">
          <button type="submit" class="btn-uts"><i class="fas fa-check-circle"></i> Aprobar anteproyecto</button>
        </form>
      </div>

    </c:when>

    <c:when test="${a.estado == 'aprobado'}">
      <div class="aviso-tarjeta">
        <i class="fas fa-check-circle"></i>
        <span>Ya aprobaste este anteproyecto. Quedó <strong>aprobado</strong> para el estudiante y la coordinación.</span>
      </div>
    </c:when>

    <c:otherwise>
      <div class="aviso-tarjeta">
        <i class="fas fa-info-circle"></i>
        <span>Este anteproyecto aún no ha sido aprobado por el director. No puede ser evaluado todavía.</span>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>



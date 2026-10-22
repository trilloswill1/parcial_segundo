<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="coordinacion"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Detalle del anteproyecto"/>
<c:set var="menuActivo"   value="anteproyectos"/>

<%-- Detalle completo del anteproyecto con datos del estudiante y docentes --%>
<sql:query var="rs" dataSource="${bd}">
  SELECT a.id, a.titulo, a.resumen, a.enlace_documento, a.estado, a.fecha_registro,
         a.nota_director, a.observaciones_director, a.observaciones_evaluador,
         CONCAT(e.nombres,' ',e.apellido1,' ',COALESCE(e.apellido2,'')) AS estudiante,
         CONCAT(e.codigo) AS codigo_estudiante, CONCAT(e.correo) AS correo_estudiante,
         CONCAT(i.descripcion) AS idea_descripcion, CONCAT(i.estado) AS idea_estado,
         CONCAT(d.nombres,' ',d.apellido1) AS director, CONCAT(d.codigo) AS codigo_director,
         CONCAT(v.nombres,' ',v.apellido1) AS evaluador, CONCAT(v.codigo) AS codigo_evaluador
  FROM anteproyectos a
  JOIN usuarios e ON e.id = a.id_estudiante
  JOIN ideas i ON i.id = a.id_idea
  LEFT JOIN usuarios d ON d.id = a.id_director
  LEFT JOIN usuarios v ON v.id = a.id_evaluador
  WHERE a.id = ?
  <sql:param value="${param.id}"/>
</sql:query>

<c:if test="${rs.rowCount == 0}">
  <c:redirect url="/coordinacion/anteproyectos.jsp">
    <c:param name="error" value="El anteproyecto no existe"/>
  </c:redirect>
</c:if>

<%@ include file="/WEB-INF/jspf/header.jspf" %>

<c:forEach var="a" items="${rs.rows}">

  <div class="page-header">
    <div>
      <h1 class="page-title"><i class="fas fa-folder-open"></i><c:out value="${a.titulo}"/></h1>
      <p class="page-subtitle">Radicado por <c:out value="${a.estudiante}"/> · <fmt:formatDate value="${a.fecha_registro}" pattern="dd/MM/yyyy"/></p>
    </div>
    <div class="page-actions">
      <c:if test="${a.estado == 'radicado'}">
        <a class="btn-uts" href="<c:url value='/coordinacion/asignar_form.jsp?id=${a.id}'/>">
          <i class="fas fa-user-cog"></i> Asignar director y evaluador
        </a>
      </c:if>
      <a class="btn-uts-outline gris" href="<c:url value='/coordinacion/anteproyectos.jsp'/>">
        <i class="fas fa-arrow-left"></i> Volver
      </a>
    </div>
  </div>

  <div class="card-ui">
    <div class="card-ui-header">
      <h2 class="card-ui-titulo"><i class="fas fa-tasks"></i>Estado del anteproyecto</h2>
      <c:set var="estadoValor" value="${a.estado}"/>
      <%@ include file="/WEB-INF/jspf/estado_badge.jspf" %>
    </div>
    <c:set var="estadoValor" value="${a.estado}"/>
    <%@ include file="/WEB-INF/jspf/estado_stepper.jspf" %>
  </div>

  <div class="row g-4">
    <div class="col-lg-7">
      <div class="card-ui">
        <div class="card-ui-header">
          <h2 class="card-ui-titulo"><i class="fas fa-user-graduate"></i>Información del estudiante</h2>
        </div>
        <div class="info-grid">
          <div class="info-par">
            <span class="info-etiqueta">Código</span><span class="info-valor"><c:out value="${a.codigo_estudiante}"/></span>
          </div>
          <div class="info-par">
            <span class="info-etiqueta">Nombre</span><span class="info-valor"><c:out value="${a.estudiante}"/></span>
          </div>
          <div class="info-par">
            <span class="info-etiqueta">Correo</span><span class="info-valor"><c:out value="${a.correo_estudiante}"/></span>
          </div>
          <div class="info-par">
            <span class="info-etiqueta">Resumen del anteproyecto</span>
            <span class="info-valor"><c:out value="${a.resumen}"/></span>
          </div>
        </div>
      </div>
    </div>

    <div class="col-lg-5">
      <div class="card-ui">
        <div class="card-ui-header">
          <h2 class="card-ui-titulo"><i class="fas fa-user-tie"></i>Docentes</h2>
        </div>
        <div class="info-grid">
          <div class="info-par">
            <span class="info-etiqueta">Director</span>
            <span class="info-valor">
              <c:choose>
                <c:when test="${not empty a.director}"><c:out value="${a.director}"/> (<c:out value="${a.codigo_director}"/>)</c:when>
                <c:otherwise><span class="texto-resumen">Sin asignar</span></c:otherwise>
              </c:choose>
            </span>
          </div>
          <div class="info-par">
            <span class="info-etiqueta">Evaluador</span>
            <span class="info-valor">
              <c:choose>
                <c:when test="${not empty a.evaluador}"><c:out value="${a.evaluador}"/> (<c:out value="${a.codigo_evaluador}"/>)</c:when>
                <c:otherwise><span class="texto-resumen">Sin asignar</span></c:otherwise>
              </c:choose>
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div class="card-ui">
    <div class="card-ui-header">
      <h2 class="card-ui-titulo"><i class="fas fa-file-signature"></i>Calificación y observaciones</h2>
    </div>

    <div class="info-grid">
      <div class="info-par">
        <span class="info-etiqueta">Nota del director</span>
        <span class="info-valor">
          <c:choose>
            <c:when test="${not empty a.nota_director}">
              <strong><fmt:formatNumber value="${a.nota_director}" pattern="0.0"/></strong> / 5.0
            </c:when>
            <c:otherwise><span class="texto-resumen">Pendiente</span></c:otherwise>
          </c:choose>
        </span>
      </div>
      <div class="info-par">
        <span class="info-etiqueta">Observaciones del director</span>
        <span class="info-valor">
          <c:choose>
            <c:when test="${not empty a.observaciones_director}"><c:out value="${a.observaciones_director}"/></c:when>
            <c:otherwise><span class="texto-resumen">Sin observaciones</span></c:otherwise>
          </c:choose>
        </span>
      </div>
      <div class="info-par">
        <span class="info-etiqueta">Observaciones del evaluador</span>
        <span class="info-valor">
          <c:choose>
            <c:when test="${not empty a.observaciones_evaluador}"><c:out value="${a.observaciones_evaluador}"/></c:when>
            <c:otherwise><span class="texto-resumen">Sin observaciones</span></c:otherwise>
          </c:choose>
        </span>
      </div>
    </div>

    <c:if test="${not empty a.enlace_documento}">
      <a class="btn-uts-outline mt-3" href="<c:out value='${a.enlace_documento}'/>" target="_blank" rel="noopener">
        <i class="fas fa-external-link-alt"></i> Ver documento
      </a>
    </c:if>
  </div>

</c:forEach>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>

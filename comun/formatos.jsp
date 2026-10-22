<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="cualquiera"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Formatos de Grado"/>
<c:set var="menuActivo"   value="formatos"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<%-- Lista de formatos oficiales publicados por la UTS --%>
<sql:query var="formatos" dataSource="${bd}">
  SELECT id, nombre, descripcion, enlace
  FROM formatos_grado
  ORDER BY nombre
</sql:query>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-file-alt"></i>Formatos de Grado</h1>
    <p class="page-subtitle">Plantillas y lineamientos oficiales para tu trabajo de grado.</p>
  </div>
</div>

<c:choose>
  <c:when test="${formatos.rowCount == 0}">
    <div class="card-ui">
      <div class="empty-state">
        <i class="fas fa-file"></i>
        <h5>No hay formatos disponibles</h5>
        <p>Pronto se publicarán aquí las plantillas oficiales.</p>
      </div>
    </div>
  </c:when>
  <c:otherwise>
    <div class="row g-3">
      <c:forEach var="f" items="${formatos.rows}">
        <div class="col-sm-6 col-xl-4">
          <div class="formato-tarjeta">
            <span class="formato-icono"><i class="fas fa-file-pdf"></i></span>
            <h5><c:out value="${f.nombre}"/></h5>
            <p><c:out value="${f.descripcion}"/></p>
            <a class="btn-uts-outline" href="https://drive.google.com/drive/folders/1pREtUJNj41N_WTmh1FGbPqEj3k4sSqRJ?usp=sharing" target="_blank" rel="noopener">
              <i class="fas fa-external-link-alt"></i> Abrir formato
            </a>
          </div>
        </div>
      </c:forEach>
    </div>
  </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
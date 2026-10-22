<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="coordinacion"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Nueva idea"/>
<c:set var="menuActivo"   value="ideas"/>

<%-- Modo edición: precargo la idea solicitada; si no existe, vuelvo al listado --%>
<c:if test="${not empty param.id}">
  <sql:query var="rs" dataSource="${bd}">
    SELECT id, titulo, descripcion, estado FROM ideas WHERE id = ?
    <sql:param value="${param.id}"/>
  </sql:query>
  <c:if test="${rs.rowCount == 0}">
    <c:redirect url="/coordinacion/ideas.jsp">
      <c:param name="error" value="La idea no existe"/>
    </c:redirect>
  </c:if>
  <c:set var="i" value="${rs.rows[0]}"/>
  <c:set var="tituloPagina" value="Editar idea"/>
</c:if>

<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div class="page-header">
  <div>
    <h1 class="page-title">
      <i class="fas ${not empty param.id ? 'fa-edit' : 'fa-lightbulb'}"></i>
      <c:choose>
        <c:when test="${not empty param.id}">Editar idea</c:when>
        <c:otherwise>Nueva idea</c:otherwise>
      </c:choose>
    </h1>
    <p class="page-subtitle">Una idea disponible puede ser tomada por un estudiante para radicar su anteproyecto.</p>
  </div>
</div>

<div class="card-ui" style="max-width:820px;">
  <div class="card-ui-header">
    <h2 class="card-ui-titulo"><i class="fas fa-file-signature"></i>Datos de la idea</h2>
  </div>

  <form class="form-ui" method="post" action="<c:url value='/coordinacion/idea_guardar.jsp'/>" novalidate>
    <c:if test="${not empty param.id}">
      <input type="hidden" name="id" value="<c:out value='${i.id}'/>">
    </c:if>

    <div class="row g-3">
      <div class="col-md-12">
        <div class="form-floating">
          <input type="text" class="form-control" id="titulo" name="titulo"
                 value="<c:out value='${i.titulo}'/>" placeholder="Título de la idea" required>
          <label for="titulo">Título</label>
        </div>
      </div>
      <div class="col-md-12">
        <div class="form-floating">
          <textarea class="form-control" id="descripcion" name="descripcion"
                    placeholder="Descripción" style="height:140px" required><c:out value="${i.descripcion}"/></textarea>
          <label for="descripcion">Descripción de la idea</label>
        </div>
        <p class="form-help">Describe en qué consiste el proyecto y qué problema resuelve.</p>
      </div>
    </div>

    <div class="d-flex gap-2 mt-4">
      <button type="submit" class="btn-uts"><i class="fas fa-save"></i> Guardar</button>
      <a class="btn-uts-outline gris" href="<c:url value='/coordinacion/ideas.jsp'/>"><i class="fas fa-times"></i> Cancelar</a>
    </div>
  </form>
</div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
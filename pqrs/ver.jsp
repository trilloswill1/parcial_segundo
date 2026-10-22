<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="administrador"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Detalle PQRS"/>
<c:set var="menuActivo"   value="pqrs"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<c:if test="${empty param.id}">
  <c:redirect url="/pqrs/lista.jsp"/>
</c:if>

<sql:query var="pqrs" dataSource="${bd}">
  SELECT id, id_usuario, codigo_usuario, nombre_usuario, correo_usuario, rol_usuario, tipo, asunto, descripcion, estado, fecha_creacion
  FROM pqrs
  WHERE id = ?
  <sql:param value="${param.id}"/>
</sql:query>

<c:if test="${pqrs.rowCount == 0}">
  <c:redirect url="/pqrs/lista.jsp"/>
</c:if>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-comment-dots"></i>Detalle PQRS #<c:out value="${pqrs.rows[0].id}"/></h1>
    <p class="page-subtitle">Revisar y cambiar estado de la solicitud</p>
  </div>
  <div class="page-actions">
    <a class="btn-uts-outline gris" href="<c:url value='/pqrs/lista.jsp'/>"><i class="fas fa-arrow-left"></i> Volver al listado</a>
  </div>
</div>

<div class="row g-3">
  <div class="col-lg-8">
    <div class="card-ui">
      <div class="card-ui-header">
        <h2 class="card-ui-titulo"><i class="fas fa-info-circle"></i>Información de la solicitud</h2>
        <c:choose>
          <c:when test="${pqrs.rows[0].estado == 'resuelta'}">
            <span class="badge-simple activo"><i class="fas fa-check-circle"></i> Resuelta</span>
          </c:when>
          <c:when test="${pqrs.rows[0].estado == 'en proceso'}">
            <span class="badge-simple ambar"><i class="fas fa-spinner"></i> En proceso</span>
          </c:when>
          <c:otherwise>
            <span class="badge-simple alerta"><i class="fas fa-clock"></i> Pendiente</span>
          </c:otherwise>
        </c:choose>
      </div>
      <div class="p-3">
        <div class="row g-2 mb-2">
          <div class="col-md-6"><strong>Tipo:</strong> <c:out value="${pqrs.rows[0].tipo}"/></div>
          <div class="col-md-6"><strong>Fecha de registro:</strong> <fmt:formatDate value="${pqrs.rows[0].fecha_creacion}" pattern="dd/MM/yyyy HH:mm"/></div>
          <div class="col-12"><strong>Asunto:</strong> <c:out value="${pqrs.rows[0].asunto}"/></div>
        </div>
        <hr>
        <div>
          <strong>Descripción:</strong>
          <p class="mt-2" style="white-space: pre-wrap;"><c:out value="${pqrs.rows[0].descripcion}"/></p>
        </div>
      </div>
    </div>
  </div>
  <div class="col-lg-4">
    <div class="card-ui mb-3">
      <div class="card-ui-header">
        <h2 class="card-ui-titulo"><i class="fas fa-user"></i>Datos del solicitante</h2>
      </div>
      <div class="p-3">
        <p class="mb-1"><strong>Nombre:</strong> <c:out value="${pqrs.rows[0].nombre_usuario}"/></p>
        <p class="mb-1"><strong>Código/ID:</strong> <c:out value="${pqrs.rows[0].codigo_usuario}"/></p>
        <p class="mb-1"><strong>Correo:</strong> <c:out value="${pqrs.rows[0].correo_usuario}"/></p>
        <p class="mb-0"><strong>Rol:</strong> <span class="badge-rol"><c:out value="${pqrs.rows[0].rol_usuario}"/></span></p>
      </div>
    </div>
    <div class="card-ui">
      <div class="card-ui-header">
        <h2 class="card-ui-titulo"><i class="fas fa-cog"></i>Gestionar estado</h2>
      </div>
      <div class="p-3">
        <form method="get" action="<c:url value='/pqrs/lista.jsp'/>">
          <input type="hidden" name="marcar_estado" value="<c:out value='${pqrs.rows[0].id}'/>">
          <div class="form-floating mb-3">
            <select class="form-select" id="estado" name="estado" required>
              <option value="pendiente" ${pqrs.rows[0].estado == 'pendiente' ? 'selected' : ''}>Pendiente</option>
              <option value="en proceso" ${pqrs.rows[0].estado == 'en proceso' ? 'selected' : ''}>En proceso</option>
              <option value="resuelta" ${pqrs.rows[0].estado == 'resuelta' ? 'selected' : ''}>Resuelta</option>
            </select>
            <label for="estado">Cambiar estado</label>
          </div>
          <button type="submit" class="btn-uts w-100"><i class="fas fa-save"></i> Guardar cambio</button>
        </form>
      </div>
    </div>
  </div>
</div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>

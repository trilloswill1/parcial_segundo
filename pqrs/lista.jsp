<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="administrador"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="PQRS Recibidas"/>
<c:set var="menuActivo"   value="pqrs"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<c:if test="${not empty param.ok}">
  <div class="alert alert-success alert-dismissible fade show" role="alert">
    <i class="fas fa-check-circle"></i> <c:out value="${param.ok}"/>
    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
  </div>
</c:if>

<c:if test="${not empty param.marcar_estado && not empty param.estado}">
  <c:catch var="err">
    <sql:update dataSource="${bd}">
      UPDATE pqrs SET estado = ? WHERE id = ?
      <sql:param value="${param.estado}"/>
      <sql:param value="${param.marcar_estado}"/>
    </sql:update>
  </c:catch>
  <c:choose>
    <c:when test="${not empty err}">
      <c:redirect url="/pqrs/lista.jsp">
        <c:param name="error" value="No fue posible actualizar el estado"/>
      </c:redirect>
    </c:when>
    <c:otherwise>
      <c:redirect url="/pqrs/lista.jsp">
        <c:param name="ok" value="Estado actualizado correctamente"/>
      </c:redirect>
    </c:otherwise>
  </c:choose>
</c:if>

<sql:query var="rs" dataSource="${bd}">
  SELECT id, id_usuario, codigo_usuario, nombre_usuario, correo_usuario, rol_usuario, tipo, asunto, descripcion, estado, fecha_creacion
  FROM pqrs
  ORDER BY fecha_creacion DESC
</sql:query>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-comment-dots"></i>PQRS Recibidas</h1>
    <p class="page-subtitle">Consulta y gestión de peticiones, quejas, reclamos y sugerencias</p>
  </div>
</div>

<div class="card-ui">
  <div class="card-ui-header">
    <h2 class="card-ui-titulo"><i class="fas fa-list"></i>Listado</h2>
    <span class="badge-simple neutro"><c:out value="${rs.rowCount}"/> registros</span>
  </div>
  <c:choose>
    <c:when test="${rs.rowCount == 0}">
      <div class="empty-state">
        <i class="fas fa-inbox"></i>
        <h5>No hay PQRS registradas</h5>
        <p>Aún no se han recibido peticiones, quejas, reclamos o sugerencias.</p>
      </div>
    </c:when>
    <c:otherwise>
      <div class="tabla-contenedor">
        <table class="table table-hover align-middle table-ui">
          <thead>
            <tr>
              <th>ID</th>
              <th>Fecha</th>
              <th>Tipo</th>
              <th>Asunto</th>
              <th>Usuario</th>
              <th>Rol</th>
              <th>Correo</th>
              <th>Estado</th>
              <th class="text-end">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="p" items="${rs.rows}">
              <tr>
                <td><strong>#<c:out value="${p.id}"/></strong></td>
                <td><fmt:formatDate value="${p.fecha_creacion}" pattern="dd/MM/yyyy HH:mm"/></td>
                <td><span class="badge-simple neutro"><c:out value="${p.tipo}"/></span></td>
                <td><strong><c:out value="${p.asunto}"/></strong></td>
                <td><c:out value="${p.nombre_usuario}"/> <c:if test="${not empty p.codigo_usuario}">(<c:out value="${p.codigo_usuario}"/>)</c:if></td>
                <td><span class="badge-rol"><c:out value="${p.rol_usuario}"/></span></td>
                <td><c:out value="${p.correo_usuario}"/></td>
                <td>
                  <c:choose>
                    <c:when test="${p.estado == 'resuelta'}">
                      <span class="badge-simple activo"><i class="fas fa-check-circle"></i> Resuelta</span>
                    </c:when>
                    <c:when test="${p.estado == 'en proceso'}">
                      <span class="badge-simple ambar"><i class="fas fa-spinner"></i> En proceso</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge-simple alerta"><i class="fas fa-clock"></i> Pendiente</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <div class="acciones-tabla">
                    <a class="btn-icono" href="<c:url value='/pqrs/ver.jsp?id=${p.id}'/>" title="Ver detalles">
                      <i class="fas fa-eye"></i>
                    </a>
                  </div>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>

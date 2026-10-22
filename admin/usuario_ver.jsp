<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="administrador"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Detalle de usuario"/>
<c:set var="menuActivo"   value="usuarios"/>

<%-- Busco el usuario por su id; si no existe, vuelvo al listado --%>
<sql:query var="rs" dataSource="${bd}">
  SELECT id, codigo, nombres, apellido1, apellido2, correo, rol, estado, fecha_registro
  FROM usuarios WHERE id = ?
  <sql:param value="${param.id}"/>
</sql:query>

<c:if test="${rs.rowCount == 0}">
  <c:redirect url="/admin/usuarios.jsp">
    <c:param name="error" value="El usuario no existe"/>
  </c:redirect>
</c:if>

<%@ include file="/WEB-INF/jspf/header.jspf" %>

<c:forEach var="u" items="${rs.rows}">

  <div class="page-header">
    <div>
      <h1 class="page-title"><i class="fas fa-user"></i><c:out value="${u.nombres} ${u.apellido1} ${u.apellido2}"/></h1>
      <p class="page-subtitle">Código <c:out value="${u.codigo}"/> · <c:out value="${u.rol}"/></p>
    </div>
    <div class="page-actions">
      <a class="btn-uts" href="<c:url value='/admin/usuario_form.jsp?id=${u.id}'/>">
        <i class="fas fa-pen"></i> Editar
      </a>
      <a class="btn-uts-outline gris" href="<c:url value='/admin/usuarios.jsp'/>">
        <i class="fas fa-arrow-left"></i> Volver
      </a>
    </div>
  </div>

  <div class="card-ui">
    <div class="card-ui-header">
      <h2 class="card-ui-titulo"><i class="fas fa-id-card"></i>Datos del usuario</h2>
      <span class="badge-rol"><c:out value="${u.rol}"/></span>
    </div>

    <div class="info-grid">
      <div class="info-par">
        <span class="info-etiqueta">Código</span>
        <span class="info-valor"><c:out value="${u.codigo}"/></span>
      </div>
      <div class="info-par">
        <span class="info-etiqueta">Nombres</span>
        <span class="info-valor"><c:out value="${u.nombres}"/></span>
      </div>
      <div class="info-par">
        <span class="info-etiqueta">Primer apellido</span>
        <span class="info-valor"><c:out value="${u.apellido1}"/></span>
      </div>
      <c:if test="${not empty u.apellido2}">
        <div class="info-par">
          <span class="info-etiqueta">Segundo apellido</span>
          <span class="info-valor"><c:out value="${u.apellido2}"/></span>
        </div>
      </c:if>
      <div class="info-par">
        <span class="info-etiqueta">Correo</span>
        <span class="info-valor"><c:out value="${u.correo}"/></span>
      </div>
      <div class="info-par">
        <span class="info-etiqueta">Rol</span>
        <span class="info-valor"><c:out value="${u.rol}"/></span>
      </div>
      <div class="info-par">
        <span class="info-etiqueta">Estado</span>
        <span class="info-valor">
          <span class="badge-simple ${u.estado == 'activo' ? 'activo' : 'inactivo'}">
            <c:out value="${u.estado}"/>
          </span>
        </span>
      </div>
      <div class="info-par">
        <span class="info-etiqueta">Fecha de registro</span>
        <span class="info-valor"><fmt:formatDate value="${u.fecha_registro}" pattern="dd/MM/yyyy"/></span>
      </div>
    </div>
  </div>

</c:forEach>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
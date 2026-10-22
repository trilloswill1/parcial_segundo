<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="administrador"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Nuevo usuario"/>
<c:set var="menuActivo"   value="usuarios"/>

<%-- En modo edición (param.id) precargo los datos del usuario --%>
<c:if test="${not empty param.id}">
  <sql:query var="rs" dataSource="${bd}">
    SELECT id, codigo, nombres, apellido1, apellido2, correo, rol, estado
    FROM usuarios WHERE id = ?
    <sql:param value="${param.id}"/>
  </sql:query>
  <c:if test="${rs.rowCount == 0}">
    <c:redirect url="/admin/usuarios.jsp">
      <c:param name="error" value="El usuario no existe"/>
    </c:redirect>
  </c:if>
  <c:set var="u" value="${rs.rows[0]}"/>
  <c:set var="tituloPagina" value="Editar usuario"/>
</c:if>

<%@ include file="/WEB-INF/jspf/header.jspf" %>

<%-- Título según el modo de la página --%>
<div class="page-header">
  <div>
    <h1 class="page-title">
      <i class="fas ${not empty param.id ? 'fa-user-edit' : 'fa-user-plus'}"></i>
      <c:choose>
        <c:when test="${not empty param.id}">Editar usuario</c:when>
        <c:otherwise>Nuevo usuario</c:otherwise>
      </c:choose>
    </h1>
    <p class="page-subtitle">
      <c:choose>
        <c:when test="${not empty param.id}">Actualiza los datos del usuario existente.</c:when>
        <c:otherwise>Registra docentes, coordinación o alumnos en el sistema.</c:otherwise>
      </c:choose>
    </p>
  </div>
</div>

<div class="card-ui" style="max-width:820px;">
  <div class="card-ui-header">
    <h2 class="card-ui-titulo"><i class="fas fa-id-card"></i>Datos personales</h2>
  </div>

  <form class="form-ui" method="post" action="<c:url value='/admin/usuario_guardar.jsp'/>" novalidate>
    <c:if test="${not empty param.id}">
      <input type="hidden" name="id" value="<c:out value='${u.id}'/>">
    </c:if>

    <div class="row g-3">
      <div class="col-md-4">
        <div class="form-floating">
          <input type="text" class="form-control" id="codigo" name="codigo"
                 value="<c:out value='${u.codigo}'/>" placeholder="Código" required>
          <label for="codigo">Código</label>
        </div>
      </div>
      <div class="col-md-8">
        <div class="form-floating">
          <input type="text" class="form-control" id="nombres" name="nombres"
                 value="<c:out value='${u.nombres}'/>" placeholder="Nombres" required>
          <label for="nombres">Nombres</label>
        </div>
      </div>
      <div class="col-md-6">
        <div class="form-floating">
          <input type="text" class="form-control" id="apellido1" name="apellido1"
                 value="<c:out value='${u.apellido1}'/>" placeholder="Primer apellido" required>
          <label for="apellido1">Primer apellido</label>
        </div>
      </div>
      <div class="col-md-6">
        <div class="form-floating">
          <input type="text" class="form-control" id="apellido2" name="apellido2"
                 value="<c:out value='${u.apellido2}'/>" placeholder="Segundo apellido">
          <label for="apellido2">Segundo apellido</label>
        </div>
      </div>
      <div class="col-md-12">
        <div class="form-floating">
          <input type="email" class="form-control" id="correo" name="correo"
                 value="<c:out value='${u.correo}'/>" placeholder="correo@uts.edu.co" required>
          <label for="correo">Correo</label>
        </div>
      </div>
      <div class="col-md-6">
        <div class="form-floating">
          <select class="form-select" id="rol" name="rol" required>
            <option value="">Selecciona...</option>
            <c:forEach var="r" items="${['administrador','coordinacion','director','evaluador','estudiante']}">
              <option value="${r}" ${u.rol == r || (empty u.rol && param.nuevoRol == r) ? 'selected' : ''}>
                <c:out value="${r}"/>
              </option>
            </c:forEach>
          </select>
          <label for="rol">Rol</label>
        </div>
      </div>
      <div class="col-md-6">
        <div class="form-floating">
          <select class="form-select" id="estado" name="estado">
            <option value="activo" ${u.estado == 'activo' || empty u.estado ? 'selected' : ''}>Activo</option>
            <option value="inactivo" ${u.estado == 'inactivo' ? 'selected' : ''}>Inactivo</option>
          </select>
          <label for="estado">Estado</label>
        </div>
      </div>
      <div class="col-md-12">
        <div class="form-floating">
          <input type="password" class="form-control" id="clave" name="clave"
                 placeholder="Contraseña" minlength="8" ${empty param.id ? 'required' : ''}>
          <label for="clave">
            <c:choose>
              <c:when test="${not empty param.id}">Contraseña (dejar vacío para no cambiarla)</c:when>
              <c:otherwise>Contraseña</c:otherwise>
            </c:choose>
          </label>
        </div>
        <p class="form-help">Mínimo 8 caracteres. Se guarda cifrada con SHA-256.</p>
      </div>
    </div>

    <div class="d-flex gap-2 mt-4">
      <button type="submit" class="btn-uts"><i class="fas fa-save"></i> Guardar</button>
      <a class="btn-uts-outline gris" href="<c:url value='/admin/usuarios.jsp'/>"><i class="fas fa-times"></i> Cancelar</a>
    </div>
  </form>
</div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
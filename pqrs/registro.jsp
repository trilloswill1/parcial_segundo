<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="cualquiera"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Registrar PQRS"/>
<c:set var="menuActivo"   value="pqrs"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<sql:query var="usuario" dataSource="${bd}">
  SELECT id, codigo, nombres, apellido1, apellido2, correo, rol
  FROM usuarios
  WHERE id = ?
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>

<c:if test="${not empty param.ok}">
  <div class="alert alert-success alert-dismissible fade show" role="alert">
    <i class="fas fa-check-circle"></i> <c:out value="${param.ok}"/>
    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
  </div>
</c:if>
<c:if test="${not empty param.error}">
  <div class="alert alert-danger alert-dismissible fade show" role="alert">
    <i class="fas fa-exclamation-circle"></i> <c:out value="${param.error}"/>
    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
  </div>
</c:if>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-comment-dots"></i>Registrar PQRS</h1>
    <p class="page-subtitle">Peticiones, Quejas, Reclamos y Sugerencias</p>
  </div>
</div>

<div class="card-ui">
  <div class="card-ui-header">
    <h2 class="card-ui-titulo"><i class="fas fa-edit"></i>Formulario de registro</h2>
  </div>
  <form class="form-ui" method="post" action="<c:url value='/pqrs/registro_guardar.jsp'/>">
    <div class="row g-3">
      <div class="col-md-6">
        <div class="form-floating">
          <input type="text" class="form-control" id="codigo" value="<c:forEach var='u' items='${usuario.rows}'>${u.codigo}</c:forEach>" readonly>
          <label for="codigo">Código / Identificación</label>
        </div>
      </div>
      <div class="col-md-6">
        <div class="form-floating">
          <input type="text" class="form-control" id="nombre" value="<c:forEach var='u' items='${usuario.rows}'>${u.nombres} ${u.apellido1} ${u.apellido2}</c:forEach>" readonly>
          <label for="nombre">Nombre completo</label>
        </div>
      </div>
      <div class="col-md-6">
        <div class="form-floating">
          <input type="email" class="form-control" id="correo" value="<c:forEach var='u' items='${usuario.rows}'>${u.correo}</c:forEach>" readonly>
          <label for="correo">Correo electrónico</label>
        </div>
      </div>
      <div class="col-md-6">
        <div class="form-floating">
          <input type="text" class="form-control" id="rol" value="<c:forEach var='u' items='${usuario.rows}'>${u.rol}</c:forEach>" readonly>
          <label for="rol">Rol</label>
        </div>
      </div>
      <div class="col-md-6">
        <div class="form-floating">
          <select class="form-select" id="tipo" name="tipo" required>
            <option value="">Seleccione...</option>
            <option value="Petición">Petición</option>
            <option value="Queja">Queja</option>
            <option value="Reclamo">Reclamo</option>
            <option value="Sugerencia">Sugerencia</option>
          </select>
          <label for="tipo">Tipo de solicitud *</label>
        </div>
      </div>
      <div class="col-md-6">
        <div class="form-floating">
          <input type="text" class="form-control" id="asunto" name="asunto" maxlength="150" required placeholder="Asunto">
          <label for="asunto">Asunto *</label>
        </div>
      </div>
      <div class="col-12">
        <div class="form-floating">
          <textarea class="form-control" id="descripcion" name="descripcion" style="height: 150px" required placeholder="Descripción"></textarea>
          <label for="descripcion">Descripción de la solicitud *</label>
        </div>
      </div>
    </div>
    <div class="d-flex gap-2 mt-4">
      <button type="submit" class="btn-uts"><i class="fas fa-paper-plane"></i> Enviar PQRS</button>
      <button type="reset" class="btn-uts-outline gris"><i class="fas fa-undo"></i> Limpiar</button>
    </div>
  </form>
</div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="administrador"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Usuarios"/>
<c:set var="menuActivo"   value="usuarios"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<%-- Patrón de búsqueda por código, nombre o correo (EL no concatena en sql:param, se arma antes) --%>
<c:set var="patron" value="%${param.q}%"/>

<%-- Consulta con búsqueda y filtro por rol; ambos opcionales y combinables --%>
<sql:query var="rs" dataSource="${bd}">
  SELECT id, codigo, nombres, apellido1, apellido2, correo, rol, estado, fecha_registro
  FROM usuarios
  WHERE (codigo LIKE ? OR nombres LIKE ? OR apellido1 LIKE ? OR correo LIKE ?)
  <c:if test="${not empty param.rol}">
    AND rol = ?
  </c:if>
  ORDER BY rol, nombres
  <c:forEach begin="1" end="4"><sql:param value="${patron}"/></c:forEach>
  <c:if test="${not empty param.rol}"><sql:param value="${param.rol}"/></c:if>
</sql:query>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-users"></i>Usuarios</h1>
    <p class="page-subtitle">Registra, edita, consulta y elimina los usuarios del sistema.</p>
  </div>
  <div class="page-actions">
    <a class="btn-uts" href="<c:url value='/admin/usuario_form.jsp'/>">
      <i class="fas fa-user-plus"></i> Nuevo usuario
    </a>
  </div>
</div>

<%-- Buscador y filtro por rol --%>
<div class="card-ui">
  <form class="form-ui" method="get" action="<c:url value='/admin/usuarios.jsp'/>">
    <div class="row g-3 align-items-end">
      <div class="col-md-6 col-lg-5">
        <div class="form-floating">
          <input type="text" class="form-control" id="q" name="q" value="<c:out value='${param.q}'/>"
                 placeholder="Buscar por código, nombre o correo">
          <label for="q">Buscar usuario</label>
        </div>
      </div>
      <div class="col-md-3 col-lg-3">
        <div class="form-floating">
          <select class="form-select" id="rol" name="rol">
            <option value="">Todos los roles</option>
            <c:forEach var="r" items="${['administrador','coordinacion','director','evaluador','estudiante']}">
              <option value="${r}" ${param.rol == r ? 'selected' : ''}><c:out value="${r}"/></option>
            </c:forEach>
          </select>
          <label for="rol">Filtrar por rol</label>
        </div>
      </div>
      <div class="col-md-3 col-lg-4">
        <div class="d-flex gap-2">
          <button type="submit" class="btn-uts"><i class="fas fa-search"></i> Buscar</button>
          <a class="btn-uts-outline gris" href="<c:url value='/admin/usuarios.jsp'/>"><i class="fas fa-times"></i> Limpiar</a>
        </div>
      </div>
    </div>
  </form>
</div>

<%-- Listado de usuarios --%>
<div class="card-ui">
  <div class="card-ui-header">
    <h2 class="card-ui-titulo"><i class="fas fa-list"></i>Listado de usuarios</h2>
    <span class="badge-simple neutro"><c:out value="${rs.rowCount}"/> encontrados</span>
  </div>

  <c:choose>
    <c:when test="${rs.rowCount == 0}">
      <div class="empty-state">
        <i class="fas fa-user-slash"></i>
        <h5>No hay usuarios que coincidan</h5>
        <p>Prueba con otro término de búsqueda o crea un nuevo usuario.</p>
        <a class="btn-uts" href="<c:url value='/admin/usuario_form.jsp'/>"><i class="fas fa-user-plus"></i> Nuevo usuario</a>
      </div>
    </c:when>
    <c:otherwise>
      <div class="tabla-contenedor">
        <table class="table table-hover align-middle table-ui">
          <thead>
            <tr>
              <th>Código</th>
              <th>Nombre completo</th>
              <th>Correo</th>
              <th>Rol</th>
              <th>Estado</th>
              <th class="text-end">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="u" items="${rs.rows}">
              <tr>
                <td><c:out value="${u.codigo}"/></td>
                <td>
                  <strong><c:out value="${u.nombres} ${u.apellido1}"/></strong>
                  <c:if test="${not empty u.apellido2}">
                    <c:out value=" ${u.apellido2}"/>
                  </c:if>
                </td>
                <td><c:out value="${u.correo}"/></td>
                <td><span class="badge-rol"><c:out value="${u.rol}"/></span></td>
                <td>
                  <span class="badge-simple ${u.estado == 'activo' ? 'activo' : 'inactivo'}">
                    <i class="fas fa-circle"></i> <c:out value="${u.estado}"/>
                  </span>
                </td>
                <td>
                  <div class="acciones-tabla">
                    <a class="btn-icono" href="<c:url value='/admin/usuario_ver.jsp?id=${u.id}'/>" title="Ver">
                      <i class="fas fa-eye"></i>
                    </a>
                    <a class="btn-icono" href="<c:url value='/admin/usuario_form.jsp?id=${u.id}'/>" title="Editar">
                      <i class="fas fa-pen"></i>
                    </a>
                    <c:if test="${u.id != sessionScope.usuarioId}">
                      <button type="button" class="btn-icono peligro" data-bs-toggle="modal"
                              data-bs-target="#modalEliminar${u.id}" title="Eliminar">
                        <i class="fas fa-trash-alt"></i>
                      </button>
                    </c:if>
                  </div>
                </td>
              </tr>

            </c:forEach>
          </tbody>
        </table>
      </div>

      <%-- Los modales de confirmación van fuera de la tabla (HTML válido) --%>
      <c:forEach var="u" items="${rs.rows}">
      <%-- Modal de confirmación para eliminar (Bootstrap, sin JavaScript propio) --%>
      <c:if test="${u.id != sessionScope.usuarioId}">
      <div class="modal fade" id="modalEliminar${u.id}" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title"><i class="fas fa-trash-alt me-2 text-danger"></i>Eliminar usuario</h5>
              <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body">
              ¿Estás seguro de eliminar a <strong><c:out value="${u.nombres} ${u.apellido1} ${u.apellido2}"/></strong>
              (código <c:out value="${u.codigo}"/>)? Esta acción no se puede deshacer.
            </div>
            <div class="modal-footer">
              <button type="button" class="btn-uts-outline gris" data-bs-dismiss="modal">
                <i class="fas fa-times"></i> Cancelar
              </button>
              <form method="post" action="<c:url value='/admin/usuario_eliminar.jsp'/>">
                <input type="hidden" name="id" value="${u.id}">
                <button type="submit" class="btn-peligro"><i class="fas fa-trash-alt"></i> Sí, eliminar</button>
              </form>
            </div>
          </div>
        </div>
      </div>
        </c:if>
      </c:forEach>
    </c:otherwise>
  </c:choose>
</div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
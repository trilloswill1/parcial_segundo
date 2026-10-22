<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="administrador"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Notificaciones"/>
<c:set var="menuActivo"   value="notificaciones"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<%-- Marcar como leída --%>
<c:if test="${not empty param.marcar_leida}">
  <sql:update var="marcar" dataSource="${bd}">
    UPDATE notificaciones SET leida = TRUE WHERE id = ?
    <sql:param value="${param.marcar_leida}"/>
  </sql:update>
  <c:redirect url="/admin/notificaciones.jsp">
    <c:param name="ok" value="Notificación marcada como leída"/>
  </c:redirect>
</c:if>

<%-- Marcar todas como leídas --%>
<c:if test="${not empty param.marcar_todas}">
  <sql:update var="marcarTodas" dataSource="${bd}">
    UPDATE notificaciones SET leida = TRUE WHERE leida = FALSE
  </sql:update>
  <c:redirect url="/admin/notificaciones.jsp">
    <c:param name="ok" value="Todas las notificaciones marcadas como leídas"/>
  </c:redirect>
</c:if>

<%-- Búsqueda y filtro --%>
<c:set var="patron" value="%${param.q}%"/>
<c:set var="filtroLeida" value="${param.leida}"/>

<c:choose>
  <c:when test="${empty filtroLeida}">
    <sql:query var="rs" dataSource="${bd}">
      SELECT n.id, n.tipo_evento, n.titulo, n.descripcion, n.leida, n.fecha_creacion,
             n.id_usuario, n.id_referencia, n.tabla_referencia,
             CONCAT(u.nombres, ' ', u.apellido1) AS usuario_nombre,
             u.rol AS usuario_rol
      FROM notificaciones n
      LEFT JOIN usuarios u ON u.id = n.id_usuario
      WHERE (n.titulo LIKE ? OR n.descripcion LIKE ? OR n.tipo_evento LIKE ?)
      ORDER BY n.fecha_creacion DESC
      <sql:param value="${patron}"/><sql:param value="${patron}"/><sql:param value="${patron}"/>
      LIMIT 100
    </sql:query>
  </c:when>
  <c:otherwise>
    <sql:query var="rs" dataSource="${bd}">
      SELECT n.id, n.tipo_evento, n.titulo, n.descripcion, n.leida, n.fecha_creacion,
             n.id_usuario, n.id_referencia, n.tabla_referencia,
             CONCAT(u.nombres, ' ', u.apellido1) AS usuario_nombre,
             u.rol AS usuario_rol
      FROM notificaciones n
      LEFT JOIN usuarios u ON u.id = n.id_usuario
      WHERE (n.titulo LIKE ? OR n.descripcion LIKE ? OR n.tipo_evento LIKE ?)
        AND n.leida = ?
      ORDER BY n.fecha_creacion DESC
      <sql:param value="${patron}"/><sql:param value="${patron}"/><sql:param value="${patron}"/>
      <sql:param value="${filtroLeida}"/>
      LIMIT 100
    </sql:query>
  </c:otherwise>
</c:choose>

<sql:query var="noLeidas" dataSource="${bd}">
  SELECT COUNT(*) AS n FROM notificaciones WHERE leida = FALSE
</sql:query>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-bell"></i>Notificaciones del sistema</h1>
    <p class="page-subtitle">Actividad registrada en el sistema de trabajos de grado.</p>
  </div>
  <div class="page-actions">
    <c:if test="${noLeidas.rows[0].n > 0}">
      <a class="btn-uts" href="<c:url value='/admin/notificaciones.jsp?marcar_todas=1'/>">
        <i class="fas fa-check-double"></i> Marcar todas como leídas (<c:out value="${noLeidas.rows[0].n}"/>)
      </a>
    </c:if>
  </div>
</div>

<%-- Buscador y filtro --%>
<div class="card-ui">
  <form class="form-ui" method="get" action="<c:url value='/admin/notificaciones.jsp'/>">
    <div class="row g-3 align-items-end">
      <div class="col-md-6 col-lg-5">
        <div class="form-floating">
          <input type="text" class="form-control" id="q" name="q" value="<c:out value='${param.q}'/>"
                 placeholder="Buscar por título, descripción o tipo">
          <label for="q">Buscar notificación</label>
        </div>
      </div>
      <div class="col-md-3 col-lg-3">
        <div class="form-floating">
          <select class="form-select" id="leida" name="leida">
            <option value="">Todas</option>
            <option value="0" ${param.leida == '0' ? 'selected' : ''}>No leídas</option>
            <option value="1" ${param.leida == '1' ? 'selected' : ''}>Leídas</option>
          </select>
          <label for="leida">Filtrar por estado</label>
        </div>
      </div>
      <div class="col-md-3 col-lg-4">
        <div class="d-flex gap-2">
          <button type="submit" class="btn-uts"><i class="fas fa-search"></i> Buscar</button>
          <a class="btn-uts-outline gris" href="<c:url value='/admin/notificaciones.jsp'/>"><i class="fas fa-times"></i> Limpiar</a>
        </div>
      </div>
    </div>
  </form>
</div>

<%-- Listado de notificaciones --%>
<div class="card-ui mt-4">
  <div class="card-ui-header">
    <h2 class="card-ui-titulo"><i class="fas fa-list"></i>Listado de notificaciones</h2>
    <span class="badge-simple neutro"><c:out value="${rs.rowCount}"/> encontradas</span>
  </div>

  <c:choose>
    <c:when test="${rs.rowCount == 0}">
      <div class="empty-state">
        <i class="fas fa-bell-slash"></i>
        <h5>No hay notificaciones</h5>
        <p>No se encontraron notificaciones con los criterios actuales.</p>
      </div>
    </c:when>
    <c:otherwise>
      <div class="tabla-contenedor">
        <table class="table table-hover align-middle table-ui">
          <thead>
            <tr>
              <th>Tipo</th>
              <th>Título</th>
              <th>Descripción</th>
              <th>Usuario</th>
              <th>Referencia</th>
              <th>Fecha</th>
              <th class="text-center">Estado</th>
              <th class="text-end">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="n" items="${rs.rows}">
              <tr class="${n.leida ? '' : 'table-active fw-bold'}">
                <td>
                  <span class="badge-simple ${n.tipo_evento == 'usuario_nuevo' ? 'azul' : (n.tipo_evento == 'idea_nueva' ? 'verde' : (n.tipo_evento == 'anteproyecto_nuevo' ? 'ambar' : (n.tipo_evento == 'asignacion' ? 'morado' : (n.tipo_evento == 'aprobacion' ? 'exito' : (n.tipo_evento == 'calificacion' ? 'info' : 'neutro')))))}">
                    <c:out value="${n.tipo_evento}"/>
                  </span>
                </td>
                <td><strong><c:out value="${n.titulo}"/></strong></td>
                <td>
                  <c:choose>
                    <c:when test="${not empty n.descripcion}">
                      <span class="texto-resumen"><c:out value="${fn:substring(n.descripcion, 0, 100)}"/></span>
                    </c:when>
                    <c:otherwise><span class="texto-resumen">—</span></c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${not empty n.usuario_nombre}">
                      <c:out value="${n.usuario_nombre}"/>
                      <br><span class="badge-rol"><c:out value="${n.usuario_rol}"/></span>
                    </c:when>
                    <c:otherwise><span class="texto-resumen">Sistema</span></c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${not empty n.tabla_referencia && not empty n.id_referencia}">
                      <span class="badge-simple neutro"><c:out value="${n.tabla_referencia}"/> #<c:out value="${n.id_referencia}"/></span>
                    </c:when>
                    <c:otherwise><span class="texto-resumen">—</span></c:otherwise>
                  </c:choose>
                </td>
                <td><fmt:formatDate value="${n.fecha_creacion}" pattern="dd/MM/yyyy HH:mm"/></td>
                <td class="text-center">
                  <c:choose>
                    <c:when test="${n.leida}">
                      <span class="badge-simple activo"><i class="fas fa-check"></i> Leída</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge-simple alerta"><i class="fas fa-circle"></i> Pendiente</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <div class="acciones-tabla">
                    <c:if test="${not n.leida}">
                      <a class="btn-icono" href="<c:url value='/admin/notificaciones.jsp?marcar_leida=${n.id}'/>" title="Marcar como leída">
                        <i class="fas fa-check"></i>
                      </a>
                    </c:if>
                    <c:if test="${n.tabla_referencia == 'anteproyectos' && not empty n.id_referencia}">
                      <a class="btn-icono" href="<c:url value='/coordinacion/anteproyecto_ver.jsp?id=${n.id_referencia}'/>" title="Ver anteproyecto">
                        <i class="fas fa-eye"></i>
                      </a>
                    </c:if>
                    <c:if test="${n.tabla_referencia == 'ideas' && not empty n.id_referencia}">
                      <a class="btn-icono" href="<c:url value='/coordinacion/idea_form.jsp?id=${n.id_referencia}'/>" title="Ver idea">
                        <i class="fas fa-eye"></i>
                      </a>
                    </c:if>
                    <c:if test="${n.tabla_referencia == 'usuarios' && not empty n.id_referencia}">
                      <a class="btn-icono" href="<c:url value='/admin/usuario_ver.jsp?id=${n.id_referencia}'/>" title="Ver usuario">
                        <i class="fas fa-eye"></i>
                      </a>
                    </c:if>
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
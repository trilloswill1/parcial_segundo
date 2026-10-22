<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="evaluador"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Entregas finales"/>
<c:set var="menuActivo"   value="entregas_finales"/>

<%-- Filtro por estado --%>
<c:set var="patron" value="%${param.q}%"/>
<c:set var="filtroEstado" value="${param.estado}"/>
<c:choose>
  <c:when test="${filtroEstado == 'revision'}"><c:set var="estadoDb" value="En revisión"/></c:when>
  <c:when test="${filtroEstado == 'Entregado'}"><c:set var="estadoDb" value="Entregado"/></c:when>
  <c:when test="${filtroEstado == 'Aprobado'}"><c:set var="estadoDb" value="Aprobado"/></c:when>
  <c:when test="${filtroEstado == 'Rechazado'}"><c:set var="estadoDb" value="Rechazado"/></c:when>
  <c:otherwise><c:set var="estadoDb" value=""/></c:otherwise>
</c:choose>

<c:choose>
  <c:when test="${empty estadoDb}">
    <sql:query var="rs" dataSource="${bd}">
      SELECT ef.id, ef.nombre_archivo, ef.fecha_entrega, ef.estado,
             CONCAT(e.nombres,' ',e.apellido1,' ',COALESCE(e.apellido2,'')) AS estudiante,
             CONCAT(e.codigo) AS codigo_estudiante,
             CONCAT(a.titulo) AS titulo
      FROM entrega_final ef
      JOIN anteproyectos a ON a.id = ef.id_anteproyecto
      JOIN usuarios e ON e.id = ef.id_estudiante
      WHERE a.id_evaluador = ?
        AND (e.nombres LIKE ? OR e.apellido1 LIKE ? OR e.codigo LIKE ? OR a.titulo LIKE ?)
      ORDER BY ef.fecha_entrega DESC, ef.id DESC
      <sql:param value="${sessionScope.usuarioId}"/>
      <sql:param value="${patron}"/><sql:param value="${patron}"/><sql:param value="${patron}"/><sql:param value="${patron}"/>
      LIMIT 100
    </sql:query>
  </c:when>
  <c:otherwise>
    <sql:query var="rs" dataSource="${bd}">
      SELECT ef.id, ef.nombre_archivo, ef.fecha_entrega, ef.estado,
             CONCAT(e.nombres,' ',e.apellido1,' ',COALESCE(e.apellido2,'')) AS estudiante,
             CONCAT(e.codigo) AS codigo_estudiante,
             CONCAT(a.titulo) AS titulo
      FROM entrega_final ef
      JOIN anteproyectos a ON a.id = ef.id_anteproyecto
      JOIN usuarios e ON e.id = ef.id_estudiante
      WHERE a.id_evaluador = ?
        AND (e.nombres LIKE ? OR e.apellido1 LIKE ? OR e.codigo LIKE ? OR a.titulo LIKE ?)
        AND ef.estado = ?
      ORDER BY ef.fecha_entrega DESC, ef.id DESC
      <sql:param value="${sessionScope.usuarioId}"/>
      <sql:param value="${patron}"/><sql:param value="${patron}"/><sql:param value="${patron}"/><sql:param value="${patron}"/>
      <sql:param value="${estadoDb}"/>
      LIMIT 100
    </sql:query>
  </c:otherwise>
</c:choose>

<%-- Conteos por estado para el encabezado --%>
<sql:query var="resumen" dataSource="${bd}">
  SELECT
    COUNT(*) AS total,
    SUM(ef.estado = 'Entregado')    AS entregado,
    SUM(ef.estado = 'En revisión')  AS revision,
    SUM(ef.estado = 'Aprobado')     AS aprobado,
    SUM(ef.estado = 'Rechazado')    AS rechazado
  FROM entrega_final ef
  JOIN anteproyectos a ON a.id = ef.id_anteproyecto
  WHERE a.id_evaluador = ?
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>

<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-file-upload"></i>Entregas finales</h1>
    <p class="page-subtitle">Revisa y aprueba los documentos finales de tus anteproyectos asignados.</p>
  </div>
</div>

<div class="row g-3 mb-4">
  <div class="col-6 col-xl-3">
    <div class="stat-card">
      <div class="stat-icon azul"><i class="fas fa-file-alt"></i></div>
      <div>
        <div class="stat-valor"><c:out value="${resumen.rows[0].total}"/></div>
        <div class="stat-etiqueta">Entregas totales</div>
      </div>
    </div>
  </div>
  <div class="col-6 col-xl-3">
    <div class="stat-card">
      <div class="stat-icon ambar"><i class="fas fa-hourglass-half"></i></div>
      <div>
        <div class="stat-valor"><c:out value="${resumen.rows[0].revision}"/></div>
        <div class="stat-etiqueta">En revisión</div>
      </div>
    </div>
  </div>
  <div class="col-6 col-xl-3">
    <div class="stat-card">
      <div class="stat-icon verde"><i class="fas fa-check-circle"></i></div>
      <div>
        <div class="stat-valor"><c:out value="${resumen.rows[0].aprobado}"/></div>
        <div class="stat-etiqueta">Aprobadas</div>
      </div>
    </div>
  </div>
  <div class="col-6 col-xl-3">
    <div class="stat-card">
      <div class="stat-icon rojo"><i class="fas fa-times-circle"></i></div>
      <div>
        <div class="stat-valor"><c:out value="${resumen.rows[0].rechazado}"/></div>
        <div class="stat-etiqueta">Rechazadas</div>
      </div>
    </div>
  </div>
</div>

<%-- Buscador y filtro --%>
<div class="card-ui">
  <form class="form-ui" method="get" action="<c:url value='/evaluador/entregas_finales.jsp'/>">
    <div class="row g-3 align-items-end">
      <div class="col-md-6 col-lg-5">
        <div class="form-floating">
          <input type="text" class="form-control" id="q" name="q" value="<c:out value='${param.q}'/>"
                 placeholder="Buscar por estudiante o título">
          <label for="q">Buscar entrega</label>
        </div>
      </div>
      <div class="col-md-3 col-lg-3">
        <div class="form-floating">
          <select class="form-select" id="estado" name="estado">
            <option value="">Todas</option>
            <option value="Entregado" ${filtroEstado == 'Entregado' ? 'selected' : ''}>Entregado</option>
            <option value="revision"  ${filtroEstado == 'revision'  ? 'selected' : ''}>En revisión</option>
            <option value="Aprobado"  ${filtroEstado == 'Aprobado'  ? 'selected' : ''}>Aprobado</option>
            <option value="Rechazado" ${filtroEstado == 'Rechazado' ? 'selected' : ''}>Rechazado</option>
          </select>
          <label for="estado">Filtrar por estado</label>
        </div>
      </div>
      <div class="col-md-3 col-lg-4">
        <div class="d-flex gap-2">
          <button type="submit" class="btn-uts"><i class="fas fa-search"></i> Buscar</button>
          <a class="btn-uts-outline gris" href="<c:url value='/evaluador/entregas_finales.jsp'/>"><i class="fas fa-times"></i> Limpiar</a>
        </div>
      </div>
    </div>
  </form>
</div>

<%-- Listado --%>
<div class="card-ui mt-4">
  <div class="card-ui-header">
    <h2 class="card-ui-titulo"><i class="fas fa-list"></i>Listado de entregas</h2>
    <span class="badge-simple neutro"><c:out value="${rs.rowCount}"/> encontradas</span>
  </div>

  <c:choose>
    <c:when test="${rs.rowCount == 0}">
      <div class="empty-state">
        <i class="fas fa-file-slash"></i>
        <h5>No hay entregas finales</h5>
        <p>No se encontraron entregas con los criterios actuales.</p>
      </div>
    </c:when>
    <c:otherwise>
      <div class="tabla-contenedor">
        <table class="table table-hover align-middle table-ui">
          <thead>
            <tr>
              <th>Estudiante</th>
              <th>Anteproyecto</th>
              <th>Archivo</th>
              <th>Fecha de entrega</th>
              <th class="text-center">Estado</th>
              <th class="text-end">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="e" items="${rs.rows}">
              <tr>
                <td>
                  <strong><c:out value="${e.estudiante}"/></strong>
                  <br><span class="texto-resumen">Código <c:out value="${e.codigo_estudiante}"/></span>
                </td>
                <td><span class="texto-resumen"><c:out value="${e.titulo}"/></span></td>
                <td><i class="fas fa-file-pdf"></i> <c:out value="${e.nombre_archivo}"/></td>
                <td><fmt:formatDate value="${e.fecha_entrega}" pattern="dd/MM/yyyy HH:mm"/></td>
                <td class="text-center">
                  <c:set var="entregaEstado" value="${e.estado}"/>
                  <%@ include file="/WEB-INF/jspf/entrega_badge.jspf" %>
                </td>
                <td class="text-end">
                  <div class="acciones-tabla">
                    <a class="btn-icono" href="<c:url value='/comun/entrega_descargar.jsp?id=${e.id}'/>" title="Descargar PDF">
                      <i class="fas fa-download"></i>
                    </a>
                    <a class="btn-icono" href="<c:url value='/evaluador/entrega_revisar.jsp?id=${e.id}'/>" title="Revisar">
                      <i class="fas fa-clipboard-check"></i>
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

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="coordinacion"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Anteproyectos"/>
<c:set var="menuActivo"   value="anteproyectos"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<%-- Búsqueda por código o nombre del estudiante (patrón LIKE armado antes del sql:param) --%>
<c:set var="patron" value="%${param.q}%"/>

<sql:query var="rs" dataSource="${bd}">
  SELECT a.id, a.titulo, a.estado, a.fecha_registro, a.nota_director,
         CONCAT(e.nombres,' ',e.apellido1,' ',COALESCE(e.apellido2,'')) AS estudiante,
         CONCAT(e.codigo) AS codigo_estudiante,
         CONCAT(d.nombres,' ',d.apellido1) AS director,
         CONCAT(v.nombres,' ',v.apellido1) AS evaluador
  FROM anteproyectos a
  JOIN usuarios e ON e.id = a.id_estudiante
  LEFT JOIN usuarios d ON d.id = a.id_director
  LEFT JOIN usuarios v ON v.id = a.id_evaluador
  WHERE e.codigo LIKE ? OR e.nombres LIKE ? OR e.apellido1 LIKE ?
    OR CONCAT(e.nombres,' ',e.apellido1) LIKE ? OR a.titulo LIKE ?
  ORDER BY a.estado, a.fecha_registro DESC
  <sql:param value="${patron}"/><sql:param value="${patron}"/>
  <sql:param value="${patron}"/><sql:param value="${patron}"/>
  <sql:param value="${patron}"/>
</sql:query>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-folder-open"></i>Anteproyectos</h1>
    <p class="page-subtitle">Consulta el estado de los anteproyectos y asigna director y evaluador.</p>
  </div>
</div>

<div class="card-ui">
  <form class="form-ui" method="get" action="<c:url value='/coordinacion/anteproyectos.jsp'/>">
    <div class="row g-3 align-items-end">
      <div class="col-md-8 col-lg-9">
        <div class="form-floating">
          <input type="text" class="form-control" id="q" name="q" value="<c:out value='${param.q}'/>"
                 placeholder="Buscar por código o nombre del estudiante, o título">
          <label for="q">Buscar anteproyecto</label>
        </div>
        <c:if test="${empty param.q}">
          <p class="form-help">Ejemplo: escribe 2026001 o Laura para filtrar.</p>
        </c:if>
      </div>
      <div class="col-md-4 col-lg-3">
        <div class="d-flex gap-2">
          <button type="submit" class="btn-uts"><i class="fas fa-search"></i> Buscar</button>
          <a class="btn-uts-outline gris" href="<c:url value='/coordinacion/anteproyectos.jsp'/>"><i class="fas fa-times"></i> Limpiar</a>
        </div>
      </div>
    </div>
  </form>
</div>

<div class="card-ui">
  <div class="card-ui-header">
    <h2 class="card-ui-titulo"><i class="fas fa-list"></i>Listado de anteproyectos</h2>
    <span class="badge-simple neutro"><c:out value="${rs.rowCount}"/> encontrados</span>
  </div>

  <c:choose>
    <c:when test="${rs.rowCount == 0}">
      <div class="empty-state">
        <i class="fas fa-folder-open"></i>
        <h5>No hay anteproyectos que coincidan</h5>
        <p>Modifica la búsqueda para encontrar lo que necesitas.</p>
      </div>
    </c:when>
    <c:otherwise>
      <div class="tabla-contenedor">
        <table class="table table-hover align-middle table-ui">
          <thead>
            <tr>
              <th>Estudiante</th>
              <th>Título</th>
              <th>Director</th>
              <th>Evaluador</th>
              <th>Nota</th>
              <th>Estado</th>
              <th class="text-end">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="a" items="${rs.rows}">
              <tr>
                <td>
                  <strong><c:out value="${a.estudiante}"/></strong>
                  <br><span class="texto-resumen">Código <c:out value="${a.codigo_estudiante}"/></span>
                </td>
                <td><c:out value="${a.titulo}"/></td>
                <td>
                  <c:choose>
                    <c:when test="${not empty a.director}"><c:out value="${a.director}"/></c:when>
                    <c:otherwise><span class="texto-resumen">Sin asignar</span></c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${not empty a.evaluador}"><c:out value="${a.evaluador}"/></c:when>
                    <c:otherwise><span class="texto-resumen">Sin asignar</span></c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${not empty a.nota_director}">
                      <strong><fmt:formatNumber value="${a.nota_director}" pattern="0.0"/></strong>
                    </c:when>
                    <c:otherwise><span class="texto-resumen">—</span></c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:set var="estadoValor" value="${a.estado}"/>
                  <%@ include file="/WEB-INF/jspf/estado_badge.jspf" %>
                </td>
                <td>
                  <div class="acciones-tabla">
                    <a class="btn-icono" href="<c:url value='/coordinacion/anteproyecto_ver.jsp?id=${a.id}'/>" title="Ver">
                      <i class="fas fa-eye"></i>
                    </a>
                    <c:if test="${a.estado == 'radicado'}">
                      <a class="btn-icono" href="<c:url value='/coordinacion/asignar_form.jsp?id=${a.id}'/>" title="Asignar director y evaluador">
                        <i class="fas fa-user-cog"></i>
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

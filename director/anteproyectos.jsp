<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="director"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Anteproyectos asignados"/>
<c:set var="menuActivo"   value="anteproyectos"/>

<%-- El director solo ve los anteproyectos que Coordinación le asignó (filtro por su id) --%>
<c:set var="patron" value="%${param.q}%"/>
<sql:query var="rs" dataSource="${bd}">
  SELECT a.id, a.titulo, a.estado, a.nota_director, a.observaciones_director,
         a.fecha_registro, CONCAT(a.id_estudiante,'') AS id_estudiante,
         CONCAT(e.nombres,' ',e.apellido1,' ',COALESCE(e.apellido2,'')) AS estudiante,
         CONCAT(e.codigo) AS codigo_estudiante,
         CONCAT(v.nombres,' ',v.apellido1) AS evaluador,
         CONCAT(i.titulo) AS idea
  FROM anteproyectos a
  JOIN usuarios e ON e.id = a.id_estudiante
  LEFT JOIN usuarios v ON v.id = a.id_evaluador
  JOIN ideas i ON i.id = a.id_idea
  WHERE a.id_director = ?
    AND (e.codigo LIKE ? OR e.nombres LIKE ? OR e.apellido1 LIKE ?
         OR CONCAT(e.nombres,' ',e.apellido1) LIKE ? OR a.titulo LIKE ?)
  ORDER BY a.estado, a.fecha_registro DESC
  <sql:param value="${sessionScope.usuarioId}"/>
  <sql:param value="${patron}"/><sql:param value="${patron}"/>
  <sql:param value="${patron}"/><sql:param value="${patron}"/>
  <sql:param value="${patron}"/>
</sql:query>

<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-folder-open"></i>Anteproyectos asignados</h1>
    <p class="page-subtitle">Califica y aprueba los anteproyectos de los alumnos que tienes a cargo.</p>
  </div>
</div>

<div class="card-ui">
  <form class="form-ui" method="get" action="<c:url value='/director/anteproyectos.jsp'/>">
    <div class="row g-3 align-items-end">
      <div class="col-md-8 col-lg-9">
        <div class="form-floating">
          <input type="text" class="form-control" id="q" name="q" value="<c:out value='${param.q}'/>"
                 placeholder="Buscar por código o nombre del alumno, o título">
          <label for="q">Buscar anteproyecto</label>
        </div>
      </div>
      <div class="col-md-4 col-lg-3">
        <div class="d-flex gap-2">
          <button type="submit" class="btn-uts"><i class="fas fa-search"></i> Buscar</button>
          <a class="btn-uts-outline gris" href="<c:url value='/director/anteproyectos.jsp'/>"><i class="fas fa-times"></i> Limpiar</a>
        </div>
      </div>
    </div>
  </form>
</div>

<div class="card-ui mt-4">
  <div class="card-ui-header">
    <h2 class="card-ui-titulo"><i class="fas fa-list"></i>Mis anteproyectos</h2>
    <span class="badge-simple neutro"><c:out value="${rs.rowCount}"/> asignados</span>
  </div>

  <c:choose>
    <c:when test="${rs.rowCount == 0}">
      <div class="empty-state">
        <i class="fas fa-folder-open"></i>
        <h5>No tienes anteproyectos asignados</h5>
        <p>Cuando la coordinación te asigne anteproyectos aparecerán aquí.</p>
      </div>
    </c:when>
    <c:otherwise>
      <div class="tabla-contenedor">
        <table class="table table-hover align-middle table-ui">
          <thead>
            <tr>
              <th>Alumno</th>
              <th>Título</th>
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
                    <a class="btn-icono" href="<c:url value='/director/anteproyecto_ver.jsp?id=${a.id}'/>" title="Calificar">
                      <i class="fas fa-pen"></i>
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

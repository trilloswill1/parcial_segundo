<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="coordinacion"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Informe de estudiantes"/>
<c:set var="menuActivo"   value="inf_estudiantes"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<%-- Conteos generales del estado de los anteproyectos --%>
<sql:query var="resumen" dataSource="${bd}">
  SELECT
    COUNT(*) AS total,
    COALESCE(SUM(estado='radicado'),0) AS radicado,
    COALESCE(SUM(estado='con_director'),0) AS con_director,
    COALESCE(SUM(estado='aprobado_director'),0) AS aprobado_director,
    COALESCE(SUM(estado='aprobado'),0) AS aprobado
  FROM anteproyectos
</sql:query>
<c:set var="res" value="${resumen.rows[0]}"/>

<%-- Todos los estudiantes (con o sin anteproyecto), con búsqueda por código o nombre --%>
<c:set var="patron" value="%${param.q}%"/>
<sql:query var="rs" dataSource="${bd}">
  SELECT a.titulo, a.estado, a.nota_director, a.fecha_registro,
         CONCAT(e.nombres,' ',e.apellido1,' ',COALESCE(e.apellido2,'')) AS estudiante,
         e.codigo AS codigo, e.correo AS correo,
         CONCAT(COALESCE(d.nombres,''),' ',COALESCE(d.apellido1,'')) AS director,
         CONCAT(COALESCE(v.nombres,''),' ',COALESCE(v.apellido1,'')) AS evaluador
  FROM usuarios e
  LEFT JOIN anteproyectos a ON a.id_estudiante = e.id
  LEFT JOIN usuarios d ON d.id = a.id_director
  LEFT JOIN usuarios v ON v.id = a.id_evaluador
  WHERE e.rol = 'estudiante'
    AND (e.codigo LIKE ? OR e.nombres LIKE ? OR e.apellido1 LIKE ?
         OR CONCAT(e.nombres,' ',e.apellido1) LIKE ?)
  ORDER BY e.codigo
  <sql:param value="${patron}"/><sql:param value="${patron}"/>
  <sql:param value="${patron}"/><sql:param value="${patron}"/>
</sql:query>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-user-graduate"></i>Informe de estudiantes</h1>
    <p class="page-subtitle">Estado del proyecto en los alumnos. Busca por código o nombre del estudiante.</p>
  </div>
</div>

<%-- Tarjetas de resumen por estado --%>
<div class="row g-4">
  <div class="col-6 col-lg">
    <div class="stat-card">
      <span class="stat-icon" style="background:var(--color-borde);color:var(--color-tinta)"><i class="fas fa-folder-open"></i></span>
      <div><span class="stat-valor"><c:out value="${res.total}"/></span><span class="stat-etiqueta">Total anteproyectos</span></div>
    </div>
  </div>
  <div class="col-6 col-lg">
    <div class="stat-card">
      <span class="stat-icon estado-radicado"><i class="fas fa-file-import"></i></span>
      <div><span class="stat-valor"><c:out value="${res.radicado}"/></span><span class="stat-etiqueta">Radicados</span></div>
    </div>
  </div>
  <div class="col-6 col-lg">
    <div class="stat-card">
      <span class="stat-icon estado-con_director"><i class="fas fa-user-cog"></i></span>
      <div><span class="stat-valor"><c:out value="${res.con_director}"/></span><span class="stat-etiqueta">Con director</span></div>
    </div>
  </div>
  <div class="col-6 col-lg">
    <div class="stat-card">
      <span class="stat-icon estado-aprobado_director"><i class="fas fa-user-check"></i></span>
      <div><span class="stat-valor"><c:out value="${res.aprobado_director}"/></span><span class="stat-etiqueta">Aprobados por director</span></div>
    </div>
  </div>
  <div class="col-6 col-lg">
    <div class="stat-card">
      <span class="stat-icon estado-aprobado"><i class="fas fa-check-circle"></i></span>
      <div><span class="stat-valor"><c:out value="${res.aprobado}"/></span><span class="stat-etiqueta">Aprobados</span></div>
    </div>
  </div>
</div>

<div class="card-ui mt-4">
  <form class="form-ui" method="get" action="<c:url value='/coordinacion/informe_estudiantes.jsp'/>">
    <div class="row g-3 align-items-end">
      <div class="col-md-8 col-lg-9">
        <div class="form-floating">
          <input type="text" class="form-control" id="q" name="q" value="<c:out value='${param.q}'/>"
                 placeholder="Buscar por código o nombre del estudiante">
          <label for="q">Código o nombre del estudiante</label>
        </div>
      </div>
      <div class="col-md-4 col-lg-3">
        <div class="d-flex gap-2">
          <button type="submit" class="btn-uts"><i class="fas fa-search"></i> Buscar</button>
          <a class="btn-uts-outline gris" href="<c:url value='/coordinacion/informe_estudiantes.jsp'/>"><i class="fas fa-times"></i> Limpiar</a>
        </div>
      </div>
    </div>
  </form>
</div>

<div class="card-ui mt-4">
  <div class="card-ui-header">
    <h2 class="card-ui-titulo"><i class="fas fa-list"></i>Proyectos de los estudiantes</h2>
    <span class="badge-simple neutro"><c:out value="${rs.rowCount}"/> encontrados</span>
  </div>

  <c:choose>
    <c:when test="${rs.rowCount == 0}">
      <div class="empty-state">
        <i class="fas fa-user-graduate"></i>
        <h5>No hay estudiantes que coincidan</h5>
        <p>Prueba con otro código o nombre del estudiante.</p>
      </div>
    </c:when>
    <c:otherwise>
      <div class="tabla-contenedor">
        <table class="table table-hover align-middle table-ui">
          <thead>
            <tr>
              <th>Código</th>
              <th>Estudiante</th>
              <th>Anteproyecto</th>
              <th>Director</th>
              <th>Evaluador</th>
              <th>Nota</th>
              <th>Estado</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="f" items="${rs.rows}">
              <tr>
                <td><c:out value="${f.codigo}"/></td>
                <td><strong><c:out value="${f.estudiante}"/></strong><br><span class="texto-resumen"><c:out value="${f.correo}"/></span></td>
                <td>
                  <c:choose>
                    <c:when test="${not empty f.titulo}"><c:out value="${f.titulo}"/></c:when>
                    <c:otherwise><span class="texto-resumen">Aún no radica</span></c:otherwise>
                  </c:choose>
                </td>
                <td><c:choose><c:when test="${not empty f.director}"><c:out value="${f.director}"/></c:when><c:otherwise><span class="texto-resumen">Sin asignar</span></c:otherwise></c:choose></td>
                <td><c:choose><c:when test="${not empty f.evaluador}"><c:out value="${f.evaluador}"/></c:when><c:otherwise><span class="texto-resumen">Sin asignar</span></c:otherwise></c:choose></td>
                <td><c:choose><c:when test="${not empty f.nota_director}"><strong><fmt:formatNumber value="${f.nota_director}" pattern="0.0"/></strong></c:when><c:otherwise><span class="texto-resumen">—</span></c:otherwise></c:choose></td>
                <td>
                  <c:choose>
                    <c:when test="${not empty f.estado}">
                      <c:set var="estadoValor" value="${f.estado}"/>
                      <%@ include file="/WEB-INF/jspf/estado_badge.jspf" %>
                    </c:when>
                    <c:otherwise><span class="badge-simple neutro">sin anteproyecto</span></c:otherwise>
                  </c:choose>
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

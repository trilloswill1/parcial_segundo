<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="coordinacion"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Informe de directores"/>
<c:set var="menuActivo"   value="inf_directores"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<%-- Conteo de anteproyectos asignados, calificados y nota promedio por director --%>
<sql:query var="rs" dataSource="${bd}">
  SELECT CONCAT(d.nombres,' ',d.apellido1,' ',COALESCE(d.apellido2,'')) AS director,
         CONCAT(d.codigo) AS codigo_director,
         COUNT(a.id) AS asignados,
         COALESCE(SUM(a.nota_director IS NOT NULL),0) AS calificados,
         ROUND(COALESCE(AVG(a.nota_director),0),2) AS nota_promedio
  FROM usuarios d
  LEFT JOIN anteproyectos a ON a.id_director = d.id
  WHERE d.rol = 'director' AND d.estado = 'activo'
  GROUP BY d.id, d.nombres, d.apellido1, d.apellido2, d.codigo
  ORDER BY d.nombres
</sql:query>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-chalkboard-teacher"></i>Informe de directores</h1>
    <p class="page-subtitle">Anteproyectos asignados, calificados y nota promedio por director.</p>
  </div>
</div>

<div class="card-ui">
  <div class="card-ui-header">
    <h2 class="card-ui-titulo"><i class="fas fa-list"></i>Resumen por director</h2>
  </div>

  <c:choose>
    <c:when test="${rs.rowCount == 0}">
      <div class="empty-state">
        <i class="fas fa-chalkboard-teacher"></i>
        <h5>No hay directores registrados</h5>
        <p>Registra docentes con rol director desde el módulo de administración.</p>
      </div>
    </c:when>
    <c:otherwise>
      <div class="tabla-contenedor">
        <table class="table table-hover align-middle table-ui">
          <thead>
            <tr>
              <th>Director</th>
              <th class="text-center">Anteproyectos asignados</th>
              <th class="text-center">Calificados</th>
              <th class="text-center">Nota promedio</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="d" items="${rs.rows}">
              <tr>
                <td><strong><c:out value="${d.director}"/></strong><br><span class="texto-resumen"><c:out value="${d.codigo_director}"/></span></td>
                <td class="text-center"><span class="badge-simple neutro fs-6"><c:out value="${d.asignados}"/></span></td>
                <td class="text-center"><c:out value="${d.calificados}"/></td>
                <td class="text-center">
                  <strong>
                    <c:choose>
                      <c:when test="${d.calificados > 0}"><fmt:formatNumber value="${d.nota_promedio}" pattern="0.00"/></c:when>
                      <c:otherwise><span class="texto-resumen">—</span></c:otherwise>
                    </c:choose>
                  </strong>
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
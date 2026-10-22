<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="coordinacion"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Informe de evaluadores"/>
<c:set var="menuActivo"   value="inf_evaluadores"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<%-- Conteo de anteproyectos asignados, en observación y aprobados por evaluador --%>
<sql:query var="rs" dataSource="${bd}">
  SELECT CONCAT(v.nombres,' ',v.apellido1,' ',COALESCE(v.apellido2,'')) AS evaluador,
         CONCAT(v.codigo) AS codigo_evaluador,
         COUNT(a.id) AS asignados,
         COALESCE(SUM(a.estado = 'aprobado_director'),0) AS en_observacion,
         COALESCE(SUM(a.estado = 'aprobado'),0) AS aprobados
  FROM usuarios v
  LEFT JOIN anteproyectos a ON a.id_evaluador = v.id
  WHERE v.rol = 'evaluador' AND v.estado = 'activo'
  GROUP BY v.id, v.nombres, v.apellido1, v.apellido2, v.codigo
  ORDER BY v.nombres
</sql:query>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-clipboard-check"></i>Informe de evaluadores</h1>
    <p class="page-subtitle">Anteproyectos asignados, pendientes de aprobación y aprobados por evaluador.</p>
  </div>
</div>

<div class="card-ui">
  <div class="card-ui-header">
    <h2 class="card-ui-titulo"><i class="fas fa-list"></i>Resumen por evaluador</h2>
  </div>

  <c:choose>
    <c:when test="${rs.rowCount == 0}">
      <div class="empty-state">
        <i class="fas fa-clipboard-check"></i>
        <h5>No hay evaluadores registrados</h5>
        <p>Registra docentes con rol evaluador desde el módulo de administración.</p>
      </div>
    </c:when>
    <c:otherwise>
      <div class="tabla-contenedor">
        <table class="table table-hover align-middle table-ui">
          <thead>
            <tr>
              <th>Evaluador</th>
              <th class="text-center">Asignados</th>
              <th class="text-center">Pendientes de aprobación</th>
              <th class="text-center">Aprobados</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="e" items="${rs.rows}">
              <tr>
                <td><strong><c:out value="${e.evaluador}"/></strong><br><span class="texto-resumen"><c:out value="${e.codigo_evaluador}"/></span></td>
                <td class="text-center"><span class="badge-simple neutro fs-6"><c:out value="${e.asignados}"/></span></td>
                <td class="text-center">
                  <span class="badge-estado estado-aprobado_director"><c:out value="${e.en_observacion}"/></span>
                </td>
                <td class="text-center">
                  <span class="badge-estado estado-aprobado"><c:out value="${e.aprobados}"/></span>
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
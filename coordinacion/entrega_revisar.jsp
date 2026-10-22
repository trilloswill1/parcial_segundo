<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="coordinacion"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Revisar entrega final"/>
<c:set var="menuActivo"   value="entregas_finales"/>

<%-- Detalle de la entrega seleccionada --%>
<sql:query var="rs" dataSource="${bd}">
  SELECT ef.id, ef.nombre_archivo, ef.fecha_entrega, ef.estado, ef.observaciones,
         ef.id_anteproyecto,
         CONCAT(e.nombres,' ',e.apellido1,' ',COALESCE(e.apellido2,'')) AS estudiante,
         CONCAT(e.codigo) AS codigo_estudiante, CONCAT(e.correo) AS correo_estudiante,
         CONCAT(a.titulo) AS titulo
  FROM entrega_final ef
  JOIN usuarios e ON e.id = ef.id_estudiante
  JOIN anteproyectos a ON a.id = ef.id_anteproyecto
  WHERE ef.id = ?
  <sql:param value="${param.id}"/>
</sql:query>

<c:if test="${rs.rowCount == 0}">
  <c:redirect url="/coordinacion/entregas_finales.jsp">
    <c:param name="error" value="La entrega no existe"/>
  </c:redirect>
</c:if>

<c:set var="e" value="${rs.rows[0]}"/>

<%-- Historial de versiones del mismo anteproyecto --%>
<sql:query var="historial" dataSource="${bd}">
  SELECT id, nombre_archivo, fecha_entrega, estado, observaciones
  FROM entrega_final
  WHERE id_anteproyecto = ?
  ORDER BY fecha_entrega DESC, id DESC
  <sql:param value="${e.id_anteproyecto}"/>
</sql:query>

<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-clipboard-check"></i>Revisar entrega final</h1>
    <p class="page-subtitle"><c:out value="${e.titulo}"/></p>
  </div>
  <div class="page-actions">
    <a class="btn-uts-outline gris" href="<c:url value='/coordinacion/entregas_finales.jsp'/>">
      <i class="fas fa-arrow-left"></i> Volver
    </a>
  </div>
</div>

<div class="row g-4">
  <div class="col-lg-6">
    <div class="card-ui">
      <div class="card-ui-header">
        <h2 class="card-ui-titulo"><i class="fas fa-user-graduate"></i>Estudiante</h2>
      </div>
      <div class="info-grid">
        <div class="info-par">
          <span class="info-etiqueta">Código</span><span class="info-valor"><c:out value="${e.codigo_estudiante}"/></span>
        </div>
        <div class="info-par">
          <span class="info-etiqueta">Nombre</span><span class="info-valor"><c:out value="${e.estudiante}"/></span>
        </div>
        <div class="info-par">
          <span class="info-etiqueta">Correo</span><span class="info-valor"><c:out value="${e.correo_estudiante}"/></span>
        </div>
      </div>
    </div>
  </div>

  <div class="col-lg-6">
    <div class="card-ui">
      <div class="card-ui-header">
        <h2 class="card-ui-titulo"><i class="fas fa-file-pdf"></i>Documento entregado</h2>
        <c:set var="entregaEstado" value="${e.estado}"/>
        <%@ include file="/WEB-INF/jspf/entrega_badge.jspf" %>
      </div>
      <div class="info-grid">
        <div class="info-par">
          <span class="info-etiqueta">Archivo</span>
          <span class="info-valor"><i class="fas fa-file-pdf"></i> <c:out value="${e.nombre_archivo}"/></span>
        </div>
        <div class="info-par">
          <span class="info-etiqueta">Fecha de entrega</span>
          <span class="info-valor"><fmt:formatDate value="${e.fecha_entrega}" pattern="dd/MM/yyyy HH:mm"/></span>
        </div>
      </div>
      <a class="btn-uts-outline mt-3" href="<c:url value='/comun/entrega_descargar.jsp?id=${e.id}'/>" target="_blank" rel="noopener">
        <i class="fas fa-download"></i> Descargar PDF
      </a>
    </div>
  </div>
</div>

<div class="card-ui mt-4">
  <div class="card-ui-header">
    <h2 class="card-ui-titulo"><i class="fas fa-comments"></i>Revisión</h2>
  </div>

  <form class="form-ui" method="post" action="<c:url value='/coordinacion/entrega_estado_guardar.jsp'/>" novalidate>
    <input type="hidden" name="id" value="${e.id}">
    <div class="row g-3">
      <div class="col-md-4">
        <div class="form-floating">
          <select class="form-select" id="estado" name="estado">
            <option value="Entregado" ${e.estado == 'Entregado' ? 'selected' : ''}>Entregado</option>
            <option value="revision"  ${e.estado == 'En revisión' ? 'selected' : ''}>En revisión</option>
            <option value="Aprobado"  ${e.estado == 'Aprobado' ? 'selected' : ''}>Aprobado</option>
            <option value="Rechazado" ${e.estado == 'Rechazado' ? 'selected' : ''}>Rechazado</option>
          </select>
          <label for="estado">Estado de la entrega</label>
        </div>
      </div>
      <div class="col-md-8">
        <div class="form-floating">
          <textarea class="form-control" id="observaciones" name="observaciones" placeholder="Observaciones"
                    style="height:110px"><c:out value="${e.observaciones}"/></textarea>
          <label for="observaciones">Observaciones de revisión</label>
        </div>
        <p class="form-help">Las observaciones se mostrarán al estudiante y quedarán asociadas a esta versión.</p>
      </div>
    </div>
    <div class="d-flex gap-2 mt-4">
      <button type="submit" class="btn-uts"><i class="fas fa-save"></i> Guardar revisión</button>
    </div>
  </form>
</div>

<c:if test="${historial.rowCount > 1}">
  <div class="card-ui mt-4">
    <div class="card-ui-header">
      <h2 class="card-ui-titulo"><i class="fas fa-history"></i>Historial de versiones</h2>
      <span class="badge-simple neutro"><c:out value="${historial.rowCount}"/> versiones</span>
    </div>
    <div class="tabla-contenedor">
      <table class="table table-hover align-middle table-ui">
        <thead>
          <tr>
            <th>Archivo</th>
            <th>Fecha</th>
            <th>Estado</th>
            <th>Observaciones</th>
            <th class="text-end">Acciones</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="h" items="${historial.rows}">
            <tr class="${h.id == e.id ? 'table-active fw-bold' : ''}">
              <td><i class="fas fa-file-pdf"></i> <c:out value="${h.nombre_archivo}"/></td>
              <td><fmt:formatDate value="${h.fecha_entrega}" pattern="dd/MM/yyyy HH:mm"/></td>
              <td>
                <c:set var="entregaEstado" value="${h.estado}"/>
                <%@ include file="/WEB-INF/jspf/entrega_badge.jspf" %>
              </td>
              <td>
                <c:choose>
                  <c:when test="${not empty h.observaciones}"><span class="texto-resumen"><c:out value="${h.observaciones}"/></span></c:when>
                  <c:otherwise><span class="texto-resumen">—</span></c:otherwise>
                </c:choose>
              </td>
              <td class="text-end">
                <div class="acciones-tabla">
                  <a class="btn-icono" href="<c:url value='/comun/entrega_descargar.jsp?id=${h.id}'/>" title="Descargar">
                    <i class="fas fa-download"></i>
                  </a>
                  <a class="btn-icono" href="<c:url value='/coordinacion/entrega_revisar.jsp?id=${h.id}'/>" title="Revisar">
                    <i class="fas fa-clipboard-check"></i>
                  </a>
                </div>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </div>
</c:if>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>

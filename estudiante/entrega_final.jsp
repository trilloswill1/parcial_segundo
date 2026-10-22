<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="estudiante"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Entrega final"/>
<c:set var="menuActivo"   value="entrega_final"/>

<%-- El estudiante solo ve su propio anteproyecto --%>
<sql:query var="ant" dataSource="${bd}">
  SELECT id, titulo, estado
  FROM anteproyectos
  WHERE id_estudiante = ?
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>

<%-- Historial de entregas del estudiante (más reciente primero) --%>
<sql:query var="entregas" dataSource="${bd}">
  SELECT id, nombre_archivo, ruta_archivo, fecha_entrega, estado, observaciones
  FROM entrega_final
  WHERE id_estudiante = ?
  ORDER BY fecha_entrega DESC, id DESC
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>

<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-file-upload"></i>Entrega final</h1>
    <p class="page-subtitle">Radica el documento final de tu trabajo de grado en formato PDF.</p>
  </div>
</div>

<c:choose>
  <c:when test="${ant.rowCount == 0}">
    <div class="card-ui">
      <div class="empty-state">
        <i class="fas fa-folder-open"></i>
        <h5>Aún no tienes un anteproyecto</h5>
        <p>Para realizar la entrega final primero debes radicar y aprobar tu anteproyecto.</p>
        <a class="btn-uts" href="<c:url value='/estudiante/ideas.jsp'/>"><i class="fas fa-lightbulb"></i> Ver ideas</a>
      </div>
    </div>
  </c:when>

  <c:otherwise>
    <c:set var="antId"     value="${ant.rows[0].id}"/>
    <c:set var="antEstado" value="${ant.rows[0].estado}"/>

    <%-- Solo se puede entregar cuando el anteproyecto está aprobado --%>
    <c:choose>
      <c:when test="${antEstado != 'aprobado'}">
        <div class="card-ui">
          <div class="card-ui-header">
            <h2 class="card-ui-titulo"><i class="fas fa-folder-open"></i><c:out value="${ant.rows[0].titulo}"/></h2>
            <c:set var="estadoValor" value="${antEstado}"/>
            <%@ include file="/WEB-INF/jspf/estado_badge.jspf" %>
          </div>
          <div class="aviso-tarjeta alerta">
            <i class="fas fa-info-circle"></i>
            <span>Tu anteproyecto todavía <strong>no está aprobado</strong>. Podrás realizar la entrega final cuando el proceso de anteproyecto haya finalizado.</span>
          </div>
        </div>
      </c:when>

      <c:otherwise>
        <div class="card-ui">
          <div class="card-ui-header">
            <h2 class="card-ui-titulo"><i class="fas fa-folder-open"></i>Anteproyecto aprobado</h2>
            <c:set var="estadoValor" value="${antEstado}"/>
            <%@ include file="/WEB-INF/jspf/estado_badge.jspf" %>
          </div>
          <div class="info-grid">
            <div class="info-par">
              <span class="info-etiqueta">Título</span>
              <span class="info-valor"><c:out value="${ant.rows[0].titulo}"/></span>
            </div>
          </div>
        </div>

        <%-- Entrega más reciente --%>
        <c:if test="${entregas.rowCount > 0}">
          <c:set var="ultima" value="${entregas.rows[0]}"/>
          <div class="card-ui mt-4">
            <div class="card-ui-header">
              <h2 class="card-ui-titulo"><i class="fas fa-file-pdf"></i>Mi entrega más reciente</h2>
              <c:set var="entregaEstado" value="${ultima.estado}"/>
              <%@ include file="/WEB-INF/jspf/entrega_badge.jspf" %>
            </div>
            <div class="info-grid">
              <div class="info-par">
                <span class="info-etiqueta">Archivo</span>
                <span class="info-valor">
                  <i class="fas fa-file-pdf"></i> <c:out value="${ultima.nombre_archivo}"/>
                </span>
              </div>
              <div class="info-par">
                <span class="info-etiqueta">Fecha de entrega</span>
                <span class="info-valor"><fmt:formatDate value="${ultima.fecha_entrega}" pattern="dd/MM/yyyy HH:mm"/></span>
              </div>
              <div class="info-par">
                <span class="info-etiqueta">Observaciones de revisión</span>
                <span class="info-valor">
                  <c:choose>
                    <c:when test="${not empty ultima.observaciones}"><c:out value="${ultima.observaciones}"/></c:when>
                    <c:otherwise><span class="texto-resumen">Sin observaciones.</span></c:otherwise>
                  </c:choose>
                </span>
              </div>
            </div>
            <a class="btn-uts-outline mt-3" href="<c:url value='/comun/entrega_descargar.jsp?id=${ultima.id}'/>">
              <i class="fas fa-download"></i> Descargar mi documento
            </a>
          </div>
        </c:if>

        <%-- Formulario de subida: disponible si no hay entrega o la última fue rechazada --%>
        <c:set var="puedeEntregar" value="false"/>
        <c:if test="${entregas.rowCount == 0}"><c:set var="puedeEntregar" value="true"/></c:if>
        <c:if test="${entregas.rowCount > 0 && entregas.rows[0].estado == 'Rechazado'}"><c:set var="puedeEntregar" value="true"/></c:if>

        <div class="card-ui mt-4">
          <div class="card-ui-header">
            <h2 class="card-ui-titulo"><i class="fas fa-upload"></i>Subir documento final</h2>
          </div>

          <c:choose>
            <c:when test="${puedeEntregar}">
              <c:if test="${entregas.rowCount > 0}">
                <div class="aviso-tarjeta alerta mb-3">
                  <i class="fas fa-exclamation-circle"></i>
                  <span>Tu entrega anterior fue <strong>rechazada</strong>. Puedes subir una nueva versión; el historial se conserva.</span>
                </div>
              </c:if>
              <form class="form-ui" method="post" action="<c:url value='/estudiante/entrega_guardar.jsp'/>" enctype="multipart/form-data">
                <div class="mb-3">
                  <label for="documento" class="form-label fw-semibold">Documento final (PDF)</label>
                  <input class="form-control" type="file" id="documento" name="documento" accept="application/pdf,.pdf" required>
                  <p class="form-help">Solo se permiten archivos PDF. Tamaño máximo: 10 MB.</p>
                </div>
                <button type="submit" class="btn-uts"><i class="fas fa-upload"></i> Entregar documento final</button>
              </form>
            </c:when>
            <c:otherwise>
              <div class="aviso-tarjeta">
                <i class="fas fa-check-circle"></i>
                <span>Tu documento final ya fue entregado y está en proceso de revisión. Podrás subir una nueva versión si fuese rechazado.</span>
              </div>
            </c:otherwise>
          </c:choose>
        </div>

        <%-- Historial de versiones (si existe más de una) --%>
        <c:if test="${entregas.rowCount > 1}">
          <div class="card-ui mt-4">
            <div class="card-ui-header">
              <h2 class="card-ui-titulo"><i class="fas fa-history"></i>Historial de entregas</h2>
              <span class="badge-simple neutro"><c:out value="${entregas.rowCount}"/> versiones</span>
            </div>
            <div class="tabla-contenedor">
              <table class="table table-hover align-middle table-ui">
                <thead>
                  <tr>
                    <th>#</th>
                    <th>Archivo</th>
                    <th>Fecha</th>
                    <th>Estado</th>
                    <th>Observaciones</th>
                    <th class="text-end">Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="e" items="${entregas.rows}" varStatus="st">
                    <tr>
                      <td><c:out value="${entregas.rowCount - st.index}"/></td>
                      <td><i class="fas fa-file-pdf"></i> <c:out value="${e.nombre_archivo}"/></td>
                      <td><fmt:formatDate value="${e.fecha_entrega}" pattern="dd/MM/yyyy HH:mm"/></td>
                      <td>
                        <c:set var="entregaEstado" value="${e.estado}"/>
                        <%@ include file="/WEB-INF/jspf/entrega_badge.jspf" %>
                      </td>
                      <td>
                        <c:choose>
                          <c:when test="${not empty e.observaciones}"><span class="texto-resumen"><c:out value="${e.observaciones}"/></span></c:when>
                          <c:otherwise><span class="texto-resumen">—</span></c:otherwise>
                        </c:choose>
                      </td>
                      <td class="text-end">
                        <a class="btn-icono" href="<c:url value='/comun/entrega_descargar.jsp?id=${e.id}'/>" title="Descargar">
                          <i class="fas fa-download"></i>
                        </a>
                      </td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
            </div>
          </div>
        </c:if>
      </c:otherwise>
    </c:choose>
  </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>

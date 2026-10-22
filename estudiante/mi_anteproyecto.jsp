<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="estudiante"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Mi anteproyecto"/>
<c:set var="menuActivo"   value="mi_anteproyecto"/>

<%-- El estudiante solo ve su propio anteproyecto --%>
<sql:query var="rs" dataSource="${bd}">
  SELECT a.id, a.titulo, a.resumen, a.enlace_documento, a.estado, a.fecha_registro,
         a.nota_director, a.observaciones_director, a.observaciones_evaluador,
         CONCAT(i.descripcion) AS idea_descripcion,
         CONCAT(d.nombres,' ',d.apellido1,' ',COALESCE(d.apellido2,'')) AS director,
         CONCAT(d.correo) AS correo_director, CONCAT(d.codigo) AS codigo_director,
         CONCAT(v.nombres,' ',v.apellido1,' ',COALESCE(v.apellido2,'')) AS evaluador,
         CONCAT(v.correo) AS correo_evaluador, CONCAT(v.codigo) AS codigo_evaluador
  FROM anteproyectos a
  JOIN ideas i ON i.id = a.id_idea
  LEFT JOIN usuarios d ON d.id = a.id_director
  LEFT JOIN usuarios v ON v.id = a.id_evaluador
  WHERE a.id_estudiante = ?
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>

<%@ include file="/WEB-INF/jspf/header.jspf" %>

<c:choose>
  <c:when test="${rs.rowCount == 0}">
    <div class="empty-state">
      <i class="fas fa-folder-open"></i>
      <h5>Aún no has radicado un anteproyecto</h5>
      <p>Selecciona una idea de proyecto para radicar tu anteproyecto.</p>
      <a class="btn-uts" href="<c:url value='/estudiante/ideas.jsp'/>"><i class="fas fa-lightbulb"></i> Ver ideas</a>
    </div>
  </c:when>
  <c:otherwise>
    <c:forEach var="a" items="${rs.rows}">

      <div class="page-header">
        <div>
          <h1 class="page-title"><i class="fas fa-folder-open"></i><c:out value="${a.titulo}"/></h1>
          <p class="page-subtitle">Radicado el <fmt:formatDate value="${a.fecha_registro}" pattern="dd/MM/yyyy"/></p>
        </div>
        <div class="page-actions">
          <%-- Solo puede editar o eliminar mientras esté radicado --%>
          <c:if test="${a.estado == 'radicado'}">
            <a class="btn-uts" href="<c:url value='/estudiante/anteproyecto_form.jsp?id=${a.id}'/>">
              <i class="fas fa-pen"></i> Editar
            </a>
            <button type="button" class="btn-peligro" data-bs-toggle="modal" data-bs-target="#modalEliminar">
              <i class="fas fa-trash-alt"></i> Eliminar
            </button>
          </c:if>
        </div>
      </div>

      <div class="card-ui">
        <div class="card-ui-header">
          <h2 class="card-ui-titulo"><i class="fas fa-tasks"></i>Estado del anteproyecto</h2>
          <c:set var="estadoValor" value="${a.estado}"/>
          <%@ include file="/WEB-INF/jspf/estado_badge.jspf" %>
        </div>
        <c:set var="estadoValor" value="${a.estado}"/>
        <%@ include file="/WEB-INF/jspf/estado_stepper.jspf" %>
      </div>

      <div class="row g-4">
        <div class="col-lg-7">
          <div class="card-ui">
            <div class="card-ui-header">
              <h2 class="card-ui-titulo"><i class="fas fa-file-signature"></i>Información del anteproyecto</h2>
            </div>
            <div class="info-grid">
              <div class="info-par">
                <span class="info-etiqueta">Título</span><span class="info-valor"><c:out value="${a.titulo}"/></span>
              </div>
              <div class="info-par">
                <span class="info-etiqueta">Resumen</span><span class="info-valor"><c:out value="${a.resumen}"/></span>
              </div>
              <div class="info-par">
                <span class="info-etiqueta">Idea base</span><span class="info-valor"><c:out value="${a.idea_descripcion}"/></span>
              </div>
              <c:if test="${not empty a.enlace_documento}">
                <div class="info-par">
                  <span class="info-etiqueta">Documento</span>
                  <span class="info-valor">
                    <a href="<c:out value='${a.enlace_documento}'/>" target="_blank" rel="noopener">
                      <i class="fas fa-external-link-alt"></i> Ver enlace
                    </a>
                  </span>
                </div>
              </c:if>
            </div>
          </div>
        </div>

        <div class="col-lg-5">
          <div class="card-ui">
            <div class="card-ui-header">
              <h2 class="card-ui-titulo"><i class="fas fa-user-tie"></i>Docentes a cargo</h2>
            </div>
            <div class="info-grid">
              <div class="info-par">
                <span class="info-etiqueta">Director</span>
                <span class="info-valor">
                  <c:choose>
                    <c:when test="${not empty a.director}">
                      <strong><c:out value="${a.director}"/></strong>
                      <br><span class="texto-resumen">Código <c:out value="${a.codigo_director}"/> · <c:out value="${a.correo_director}"/></span>
                    </c:when>
                    <c:otherwise><span class="texto-resumen">Por asignar</span></c:otherwise>
                  </c:choose>
                </span>
              </div>
              <div class="info-par">
                <span class="info-etiqueta">Evaluador</span>
                <span class="info-valor">
                  <c:choose>
                    <c:when test="${not empty a.evaluador}">
                      <strong><c:out value="${a.evaluador}"/></strong>
                      <br><span class="texto-resumen">Código <c:out value="${a.codigo_evaluador}"/> · <c:out value="${a.correo_evaluador}"/></span>
                    </c:when>
                    <c:otherwise><span class="texto-resumen">Por asignar</span></c:otherwise>
                  </c:choose>
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <%-- Observaciones del director y del evaluador si ya existen --%>
      <c:if test="${not empty a.nota_director || not empty a.observaciones_evaluador}">
        <div class="card-ui">
          <div class="card-ui-header">
            <h2 class="card-ui-titulo"><i class="fas fa-comments"></i>Retroalimentación</h2>
          </div>
          <div class="info-grid">
            <c:if test="${not empty a.nota_director}">
              <div class="info-par">
                <span class="info-etiqueta">Nota del director</span>
                <span class="info-valor"><strong><fmt:formatNumber value="${a.nota_director}" pattern="0.0"/></strong> / 5.0</span>
              </div>
            </c:if>
            <c:if test="${not empty a.observaciones_director}">
              <div class="info-par">
                <span class="info-etiqueta">Observaciones del director</span>
                <span class="info-valor"><c:out value="${a.observaciones_director}"/></span>
              </div>
            </c:if>
            <c:if test="${not empty a.observaciones_evaluador}">
              <div class="info-par">
                <span class="info-etiqueta">Observaciones del evaluador</span>
                <span class="info-valor"><c:out value="${a.observaciones_evaluador}"/></span>
              </div>
            </c:if>
          </div>
        </div>
      </c:if>

      <%-- Modal de confirmación para eliminar el anteproyecto (solo radicado) --%>
      <c:if test="${a.estado == 'radicado'}">
        <div class="modal fade" id="modalEliminar" tabindex="-1" aria-hidden="true">
          <div class="modal-dialog">
            <div class="modal-content">
              <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-trash-alt me-2 text-danger"></i>Eliminar anteproyecto</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
              </div>
              <div class="modal-body">
                ¿Estás seguro de eliminar tu anteproyecto? La idea volverá a estar disponible
                y podrás volver a elegir otra más adelante.
              </div>
              <div class="modal-footer">
                <button type="button" class="btn-uts-outline gris" data-bs-dismiss="modal">
                  <i class="fas fa-times"></i> Cancelar
                </button>
                <form method="post" action="<c:url value='/estudiante/anteproyecto_eliminar.jsp'/>">
                  <input type="hidden" name="id" value="${a.id}">
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

<%@ include file="/WEB-INF/jspf/footer.jspf" %>

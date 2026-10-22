<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="estudiante"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Banco de Ideas"/>
<c:set var="menuActivo"   value="ideas"/>

<%-- Un estudiante que ya tiene anteproyecto no debe poder elegir otra idea --%>
<sql:query var="puedeTomar" dataSource="${bd}">
  SELECT id FROM anteproyectos WHERE id_estudiante = ?
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>

<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-lightbulb"></i>Banco de Ideas</h1>
    <p class="page-subtitle">Elige una idea disponible para radicar tu anteproyecto.</p>
  </div>
</div>

<%-- Si ya tiene anteproyecto, se muestra un aviso y no el listado --%>
<c:choose>
  <c:when test="${puedeTomar.rowCount > 0}">
    <div class="card-ui">
      <div class="empty-state">
        <i class="fas fa-check-circle" style="color:var(--color-exito)"></i>
        <h5>Ya tienes un anteproyecto radicado</h5>
        <p>Cada estudiante puede tener un solo anteproyecto. Revisa su estado en "Mi anteproyecto".</p>
        <a class="btn-uts" href="<c:url value='/estudiante/mi_anteproyecto.jsp'/>">
          <i class="fas fa-folder-open"></i> Ver mi anteproyecto
        </a>
      </div>
    </div>
  </c:when>
  <c:otherwise>
    <sql:query var="rs" dataSource="${bd}">
      SELECT id, titulo, descripcion, estado, fecha_registro
      FROM ideas WHERE estado = 'disponible'
      ORDER BY fecha_registro DESC, id DESC
    </sql:query>

    <c:choose>
      <c:when test="${rs.rowCount == 0}">
        <div class="card-ui">
          <div class="empty-state">
            <i class="fas fa-lightbulb"></i>
            <h5>No hay ideas disponibles</h5>
            <p>La coordinación aún no ha publicado ideas para este periodo.</p>
          </div>
        </div>
      </c:when>
      <c:otherwise>
        <div class="row g-4">
          <c:forEach var="i" items="${rs.rows}">
            <div class="col-md-6 col-xl-4">
              <div class="card-ui h-100 d-flex flex-column">
                <div class="card-ui-header">
                  <h2 class="card-ui-titulo fs-6">
                    <i class="fas fa-lightbulb"></i>Idea #<c:out value="${i.id}"/>
                  </h2>
                  <span class="badge-simple activo"><c:out value="${i.estado}"/></span>
                </div>
                <div class="flex-grow-1">
                  <h5 class="fw-semibold mb-2"><c:out value="${i.titulo}"/></h5>
                  <p class="texto-resumen mb-0">
                    <c:out value="${fn:substring(i.descripcion, 0, 120)}"/><c:if test="${fn:length(i.descripcion) > 120}">…</c:if>
                  </p>
                </div>
                <div class="mt-3">
                  <a class="btn-uts w-100" href="<c:url value='/estudiante/anteproyecto_form.jsp?idea=${i.id}'/>">
                    <i class="fas fa-file-signature"></i> Radicar anteproyecto
                  </a>
                </div>
              </div>
            </div>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>
  </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>

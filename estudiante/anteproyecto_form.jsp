<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="estudiante"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Radicar anteproyecto"/>
<c:set var="menuActivo"   value="ideas"/>

<%-- El estudiante solo puede tener un anteproyecto a la vez --%>
<sql:query var="yaExiste" dataSource="${bd}">
  SELECT id FROM anteproyectos WHERE id_estudiante = ?
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>

<c:if test="${yaExiste.rowCount > 0 && empty param.id}">
  <c:redirect url="/estudiante/mi_anteproyecto.jsp">
    <c:param name="error" value="Ya tienes un anteproyecto radicado. Solo puedes tener uno"/>
  </c:redirect>
</c:if>

<%-- Modo nuevo: viene de una idea disponible --%>
<c:if test="${empty param.id}">
  <c:if test="${empty param.idea}">
    <c:redirect url="/estudiante/ideas.jsp">
      <c:param name="error" value="Debes elegir una idea para radicar tu anteproyecto"/>
    </c:redirect>
  </c:if>
  <sql:query var="rsIdea" dataSource="${bd}">
    SELECT id, titulo, descripcion FROM ideas WHERE id = ? AND estado = 'disponible'
    <sql:param value="${param.idea}"/>
  </sql:query>
  <c:if test="${rsIdea.rowCount == 0}">
    <c:redirect url="/estudiante/ideas.jsp">
      <c:param name="error" value="La idea elegida ya no está disponible"/>
    </c:redirect>
  </c:if>
  <c:set var="i" value="${rsIdea.rows[0]}"/>
</c:if>

<%-- Modo edición: solo su propio anteproyecto y solo si está radicado --%>
<c:if test="${not empty param.id}">
  <%-- Modo edición: trae también el título de la idea con un JOIN --%>
  <sql:query var="rsPropio" dataSource="${bd}">
    SELECT a.id, a.id_idea, a.titulo, a.resumen, a.enlace_documento, a.estado,
           CONCAT(i2.titulo) AS idea_titulo
    FROM anteproyectos a
    JOIN ideas i2 ON i2.id = a.id_idea
    WHERE a.id = ? AND a.id_estudiante = ? AND a.estado = 'radicado'
    <sql:param value="${param.id}"/>
    <sql:param value="${sessionScope.usuarioId}"/>
  </sql:query>
  <c:if test="${rsPropio.rowCount == 0}">
    <c:redirect url="/estudiante/mi_anteproyecto.jsp">
      <c:param name="error" value="No puedes editar un anteproyecto que ya no está radicado"/>
    </c:redirect>
  </c:if>
  <c:set var="i" value="${rsPropio.rows[0]}"/>
  <c:set var="tituloPagina" value="Editar anteproyecto"/>
</c:if>

<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div class="page-header">
  <div>
    <h1 class="page-title">
      <i class="fas ${not empty param.id ? 'fa-edit' : 'fa-file-signature'}"></i>
      <c:choose>
        <c:when test="${not empty param.id}">Editar anteproyecto</c:when>
        <c:otherwise>Radicar anteproyecto</c:otherwise>
      </c:choose>
    </h1>
    <p class="page-subtitle">
      <c:choose>
        <c:when test="${not empty param.id}">Actualiza la información de tu anteproyecto radicado.</c:when>
        <c:otherwise>Completa los datos a partir de la idea seleccionada. Solo puedes editar mientras esté radicado.</c:otherwise>
      </c:choose>
    </p>
  </div>
</div>

<div class="card-ui" style="max-width:820px;">
  <div class="card-ui-header">
    <h2 class="card-ui-titulo"><i class="fas fa-lightbulb"></i>Idea seleccionada</h2>
  </div>
  <div class="aviso-tarjeta mb-3">
    <i class="fas fa-info-circle"></i>
    <span><strong><c:out value="${not empty param.id ? i.idea_titulo : i.titulo}"/></strong>. Al radicar, la idea queda tomada y tu anteproyecto pasa a la coordinación.</span>
  </div>

  <%-- Solo se envía id_idea en modo nuevo --%>
  <form class="form-ui" method="post" action="<c:url value='/estudiante/anteproyecto_guardar.jsp'/>" novalidate>
    <c:if test="${empty param.id}">
      <input type="hidden" name="id_idea" value="<c:out value='${i.id}'/>">
    </c:if>
    <c:if test="${not empty param.id}">
      <input type="hidden" name="id" value="<c:out value='${i.id}'/>">
    </c:if>

    <div class="row g-3">
      <div class="col-md-12">
        <div class="form-floating">
          <input type="text" class="form-control" id="titulo" name="titulo" required
                 value="<c:out value='${i.titulo}'/>" placeholder="Título del anteproyecto">
          <label for="titulo">Título del anteproyecto</label>
        </div>
      </div>
      <div class="col-md-12">
        <div class="form-floating">
          <textarea class="form-control" id="resumen" name="resumen" required
                    placeholder="Resumen del anteproyecto" style="height:120px"><c:out value="${i.resumen}"/></textarea>
          <label for="resumen">Resumen</label>
        </div>
        <p class="form-help">Describe el problema, los objetivos y la propuesta de solución.</p>
      </div>
      <div class="col-md-12">
        <div class="form-floating">
          <input type="text" class="form-control" id="enlace_documento" name="enlace_documento"
                 value="<c:out value='${i.enlace_documento}'/>" placeholder="https://drive.google.com/...">
          <label for="enlace_documento">Enlace al documento (opcional)</label>
        </div>
        <p class="form-help">Pega aquí el enlace público a tu documento (Google Drive, OneDrive, etc.).</p>
      </div>
    </div>

    <div class="d-flex gap-2 mt-4">
      <button type="submit" class="btn-uts"><i class="fas fa-save"></i> Guardar</button>
      <a class="btn-uts-outline gris" href="<c:url value='/estudiante/mi_anteproyecto.jsp'/>"><i class="fas fa-times"></i> Cancelar</a>
    </div>
  </form>
</div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>

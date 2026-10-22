<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="director"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Calificar anteproyecto"/>
<c:set var="menuActivo"   value="anteproyectos"/>

<%-- El director solo consulta y califica los anteproyectos asignados a él --%>
<sql:query var="rs" dataSource="${bd}">
  SELECT a.id, a.titulo, a.resumen, a.enlace_documento, a.estado, a.fecha_registro,
         a.nota_director, a.observaciones_director, a.observaciones_evaluador,
         CONCAT(e.nombres,' ',e.apellido1,' ',COALESCE(e.apellido2,'')) AS estudiante,
         CONCAT(e.codigo) AS codigo_estudiante, CONCAT(e.correo) AS correo_estudiante,
         CONCAT(e.apellido1) AS apellido1_estudiante,
         CONCAT(v.nombres,' ',v.apellido1) AS evaluador,
         CONCAT(i.titulo) AS idea, CONCAT(i.descripcion) AS idea_descripcion
  FROM anteproyectos a
  JOIN usuarios e ON e.id = a.id_estudiante
  LEFT JOIN usuarios v ON v.id = a.id_evaluador
  JOIN ideas i ON i.id = a.id_idea
  WHERE a.id = ? AND a.id_director = ?
  <sql:param value="${param.id}"/>
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>

<c:if test="${rs.rowCount == 0}">
  <c:redirect url="/director/anteproyectos.jsp">
    <c:param name="error" value="El anteproyecto no existe o no está asignado a ti"/>
  </c:redirect>
</c:if>

<c:set var="a" value="${rs.rows[0]}"/>

<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-pen"></i>Calificar anteproyecto</h1>
    <p class="page-subtitle"><c:out value="${a.titulo}"/></p>
  </div>
  <div class="page-actions">
    <a class="btn-uts-outline gris" href="<c:url value='/director/anteproyectos.jsp'/>">
      <i class="fas fa-arrow-left"></i> Volver
    </a>
  </div>
</div>

<div class="row g-4">
  <div class="col-lg-6">
    <div class="card-ui">
      <div class="card-ui-header">
        <h2 class="card-ui-titulo"><i class="fas fa-user-graduate"></i>Información del alumno</h2>
      </div>
      <div class="info-grid">
        <div class="info-par">
          <span class="info-etiqueta">Código</span><span class="info-valor"><c:out value="${a.codigo_estudiante}"/></span>
        </div>
        <div class="info-par">
          <span class="info-etiqueta">Nombre completo</span><span class="info-valor"><c:out value="${a.estudiante}"/></span>
        </div>
        <div class="info-par">
          <span class="info-etiqueta">Correo</span><span class="info-valor"><c:out value="${a.correo_estudiante}"/></span>
        </div>
        <div class="info-par">
          <span class="info-etiqueta">Radicado</span><span class="info-valor"><fmt:formatDate value="${a.fecha_registro}" pattern="dd/MM/yyyy"/></span>
        </div>
        <div class="info-par">
          <span class="info-etiqueta">Idea base</span><span class="info-valor"><c:out value="${a.idea}"/></span>
        </div>
      </div>
      <c:if test="${not empty a.enlace_documento}">
        <a class="btn-uts-outline mt-3" href="<c:out value='${a.enlace_documento}'/>" target="_blank" rel="noopener">
          <i class="fas fa-external-link-alt"></i> Ver documento
        </a>
      </c:if>
    </div>
  </div>

  <div class="col-lg-6">
    <div class="card-ui">
      <div class="card-ui-header">
        <h2 class="card-ui-titulo"><i class="fas fa-star"></i>Calificación y observaciones</h2>
      </div>

      <c:choose>

        <%-- Mientras esté con_director el director puede crear y corregir su calificación --%>
        <c:when test="${a.estado == 'con_director'}">
          <form class="form-ui" method="post" action="<c:url value='/director/calificar_guardar.jsp'/>" novalidate>
            <input type="hidden" name="id" value="<c:out value='${a.id}'/>">

            <div class="row g-3">
              <div class="col-md-5">
                <div class="form-floating">
                  <%-- La nota se imprime con c:out (punto decimal) para que el campo numérico la acepte --%>
                  <input type="number" step="0.1" min="0.0" max="5.0" class="form-control" id="nota" name="nota"
                         value="<c:out value='${a.nota_director}'/>" placeholder="0.0 a 5.0" required>
                  <label for="nota">Nota (0.0 – 5.0)</label>
                </div>
              </div>
              <div class="col-md-7">
                <div class="form-floating">
                  <input type="text" class="form-control" id="observaciones" name="observaciones"
                         value="<c:out value='${a.observaciones_director}'/>" placeholder="Observaciones (opcional)">
                  <label for="observaciones">Observaciones</label>
                </div>
              </div>
            </div>

            <div class="d-flex gap-2 mt-4">
              <button type="submit" class="btn-uts">
                <i class="fas fa-save"></i>
                <c:choose>
                  <c:when test="${not empty a.nota_director}">Actualizar calificación</c:when>
                  <c:otherwise>Guardar calificación</c:otherwise>
                </c:choose>
              </button>
              <a class="btn-uts-outline gris" href="<c:url value='/director/anteproyectos.jsp'/>"><i class="fas fa-times"></i> Cancelar</a>
            </div>
          </form>

          <%-- Aprobar para el evaluador requiere nota registrada y >= 3.0 --%>
          <c:if test="${not empty a.nota_director}">
            <hr class="my-4">
            <c:choose>
              <c:when test="${a.nota_director >= 3.0}">
                <div class="aviso-tarjeta">
                  <i class="fas fa-check-circle"></i>
                  <span>Con esta nota el anteproyecto puede ser aprobado para el evaluador.</span>
                </div>
                <form method="post" action="<c:url value='/director/aprobar.jsp'/>" class="mt-3">
                  <input type="hidden" name="id" value="<c:out value='${a.id}'/>">
                  <button type="submit" class="btn-uts"><i class="fas fa-check-circle"></i> Aprobar para el evaluador</button>
                </form>
              </c:when>
              <c:otherwise>
                <div class="aviso-tarjeta alerta">
                  <i class="fas fa-exclamation-triangle"></i>
                  <span>La nota es inferior a 3.0, por lo que no puedes aprobar el anteproyecto para el evaluador. Si necesitas corregirla, actualiza la calificación.</span>
                </div>
              </c:otherwise>
            </c:choose>
          </c:if>
        </c:when>

        <%-- Ya no está con_director: solo se muestra la calificación registrada --%>
        <c:when test="${not empty a.nota_director}">
          <div class="info-grid">
            <div class="info-par">
              <span class="info-etiqueta">Nota asignada</span>
              <span class="info-valor">
                <span class="nota-grande"><fmt:formatNumber value="${a.nota_director}" pattern="0.0"/></span> / 5.0
              </span>
            </div>
            <div class="info-par">
              <span class="info-etiqueta">Observaciones</span><span class="info-valor"><c:out value="${a.observaciones_director}"/></span>
            </div>
          </div>
          <div class="aviso-tarjeta mt-3">
            <i class="fas fa-check-circle"></i>
            <c:choose>
              <c:when test="${a.estado == 'aprobado'}"><span>Anteproyecto aprobado por el evaluador. ¡Proceso completado!</span></c:when>
              <c:otherwise><span>Tu calificación fue registrada y aprobada. Ahora el evaluador atenderá el anteproyecto.</span></c:otherwise>
            </c:choose>
          </div>
        </c:when>

        <c:otherwise>
          <div class="aviso-tarjeta">
            <i class="fas fa-info-circle"></i>
            <span>Este anteproyecto aún no está en estado <strong>con_director</strong>.</span>
          </div>
        </c:otherwise>
      </c:choose>
    </div>
  </div>
</div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>



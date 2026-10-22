<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="coordinacion"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Asignar director y evaluador"/>
<c:set var="menuActivo"   value="anteproyectos"/>

<%-- Solo se puede asignar si el anteproyecto está radicado --%>
<sql:query var="rs" dataSource="${bd}">
  SELECT a.id, a.titulo, a.estado, a.id_director, a.id_evaluador,
         CONCAT(e.nombres,' ',e.apellido1,' ',COALESCE(e.apellido2,'')) AS estudiante,
         CONCAT(e.codigo) AS codigo_estudiante
  FROM anteproyectos a
  JOIN usuarios e ON e.id = a.id_estudiante
  WHERE a.id = ? AND a.estado = 'radicado'
  <sql:param value="${param.id}"/>
</sql:query>

<c:if test="${rs.rowCount == 0}">
  <c:redirect url="/coordinacion/anteproyectos.jsp">
    <c:param name="error" value="El anteproyecto no existe o ya tiene docentes asignados"/>
  </c:redirect>
</c:if>

<c:set var="a" value="${rs.rows[0]}"/>

<%-- Lista de docentes que pueden ser directores (todos, o solo quienes pueden dirigir) --%>
<sql:query var="rsDirectores" dataSource="${bd}">
  SELECT id, CONCAT(codigo, ' - ', nombres, ' ', apellido1, ' ', COALESCE(apellido2,'')) AS nombre
  FROM usuarios WHERE rol = 'director' AND estado = 'activo' ORDER BY nombres
</sql:query>

<sql:query var="rsEvaluadores" dataSource="${bd}">
  SELECT id, CONCAT(codigo, ' - ', nombres, ' ', apellido1, ' ', COALESCE(apellido2,'')) AS nombre
  FROM usuarios WHERE rol = 'evaluador' AND estado = 'activo' ORDER BY nombres
</sql:query>

<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-user-cog"></i>Asignar director y evaluador</h1>
    <p class="page-subtitle">Anteproyecto: <strong><c:out value="${a.titulo}"/></strong></p>
  </div>
</div>

<div class="card-ui" style="max-width:820px;">
  <div class="card-ui-header">
    <h2 class="card-ui-titulo"><i class="fas fa-users-cog"></i>Selección de docentes</h2>
  </div>
  <div class="aviso-tarjeta mb-3">
    <i class="fas fa-info-circle"></i>
    <span>Estudiante: <strong><c:out value="${a.estudiante}"/></strong> (código <c:out value="${a.codigo_estudiante}"/>). Al guardar, el anteproyecto pasa a estado <strong>con_director</strong>.</span>
  </div>

  <form class="form-ui" method="post" action="<c:url value='/coordinacion/asignar_guardar.jsp'/>" novalidate>
    <input type="hidden" name="id" value="${a.id}">

    <div class="row g-3">
      <div class="col-md-6">
        <div class="form-floating">
          <select class="form-select" id="id_director" name="id_director" required>
            <option value="">Selecciona un director...</option>
            <c:forEach var="d" items="${rsDirectores.rows}">
              <option value="${d.id}" ${a.id_director == d.id ? 'selected' : ''}>
                <c:out value="${d.nombre}"/>
              </option>
            </c:forEach>
          </select>
          <label for="id_director">Director</label>
        </div>
        <p class="form-help">Será quien califique el anteproyecto del alumno.</p>
      </div>
      <div class="col-md-6">
        <div class="form-floating">
          <select class="form-select" id="id_evaluador" name="id_evaluador" required>
            <option value="">Selecciona un evaluador...</option>
            <c:forEach var="e" items="${rsEvaluadores.rows}">
              <option value="${e.id}" ${a.id_evaluador == e.id ? 'selected' : ''}>
                <c:out value="${e.nombre}"/>
              </option>
            </c:forEach>
          </select>
          <label for="id_evaluador">Evaluador</label>
        </div>
        <p class="form-help">Será quien apruebe el anteproyecto después del director.</p>
      </div>
    </div>

    <div class="d-flex gap-2 mt-4">
      <button type="submit" class="btn-uts"><i class="fas fa-save"></i> Guardar asignación</button>
      <a class="btn-uts-outline gris" href="<c:url value='/coordinacion/anteproyectos.jsp'/>"><i class="fas fa-times"></i> Cancelar</a>
    </div>
  </form>
</div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>

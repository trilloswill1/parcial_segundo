<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="coordinacion"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Asignar sustentación"/>
<c:set var="menuActivo"   value="panel"/>

<%-- Solo se puede programar si el proyecto cumple TODOS los requisitos:
     anteproyecto aprobado, entrega final aprobada y sin sustentación programada/realizada --%>
<sql:query var="rs" dataSource="${bd}">
  SELECT a.id, a.titulo, a.id_director, a.id_evaluador,
         CONCAT(e.nombres,' ',e.apellido1,' ',COALESCE(e.apellido2,'')) AS estudiante,
         CONCAT(e.codigo) AS codigo_estudiante
  FROM anteproyectos a
  JOIN usuarios e ON e.id = a.id_estudiante
  WHERE a.id = ? AND a.estado = 'aprobado'
    AND EXISTS (SELECT 1 FROM entrega_final ef WHERE ef.id_anteproyecto = a.id AND ef.estado = 'Aprobado')
    AND NOT EXISTS (SELECT 1 FROM sustentacion s WHERE s.id_anteproyecto = a.id AND s.estado IN ('Programada','Realizada'))
  <sql:param value="${param.id}"/>
</sql:query>

<c:if test="${rs.rowCount == 0}">
  <c:redirect url="/coordinacion/panel.jsp">
    <c:param name="error" value="El proyecto no cumple los requisitos para programar la sustentación"/>
  </c:redirect>
</c:if>

<c:set var="a" value="${rs.rows[0]}"/>

<%-- Jurados posibles: directores y evaluadores activos --%>
<sql:query var="rsJurados" dataSource="${bd}">
  SELECT id, rol, CONCAT(codigo, ' - ', nombres, ' ', apellido1, ' ', COALESCE(apellido2,'')) AS nombre
  FROM usuarios WHERE rol IN ('director','evaluador') AND estado = 'activo'
  ORDER BY rol, nombres
</sql:query>

<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-gavel"></i>Asignar sustentación</h1>
    <p class="page-subtitle">Proyecto: <strong><c:out value="${a.titulo}"/></strong></p>
  </div>
  <div class="page-actions">
    <a class="btn-uts-outline gris" href="<c:url value='/coordinacion/panel.jsp'/>"><i class="fas fa-arrow-left"></i> Volver</a>
  </div>
</div>

<div class="card-ui" style="max-width:900px;">
  <div class="card-ui-header">
    <h2 class="card-ui-titulo"><i class="fas fa-calendar-plus"></i>Datos de la sustentación</h2>
  </div>
  <div class="aviso-tarjeta mb-3">
    <i class="fas fa-info-circle"></i>
    <span>Estudiante: <strong><c:out value="${a.estudiante}"/></strong> (código <c:out value="${a.codigo_estudiante}"/>). Al guardar, el estudiante recibirá una notificación y podrá ver su sustentación programada.</span>
  </div>

  <form class="form-ui" method="post" action="<c:url value='/coordinacion/sustentacion_guardar.jsp'/>" novalidate>
    <input type="hidden" name="id" value="${a.id}">

    <div class="row g-3">
      <div class="col-md-4">
        <div class="form-floating">
          <input type="date" class="form-control" id="fecha" name="fecha" required>
          <label for="fecha">Fecha de la sustentación</label>
        </div>
      </div>
      <div class="col-md-4">
        <div class="form-floating">
          <input type="time" class="form-control" id="hora" name="hora" required>
          <label for="hora">Hora</label>
        </div>
      </div>
      <div class="col-md-4">
        <div class="form-floating">
          <input type="text" class="form-control" id="lugar" name="lugar" placeholder="Lugar físico" maxlength="255">
          <label for="lugar">Lugar (opcional)</label>
        </div>
      </div>
      <div class="col-12">
        <div class="form-floating">
          <input type="text" class="form-control" id="enlace" name="enlace" placeholder="Enlace de la reunión virtual" maxlength="500">
          <label for="enlace">Lugar o enlace virtual (opcional)</label>
        </div>
        <p class="form-help">Registra al menos el lugar físico o un enlace de videollamada para que el estudiante sepa dónde presentarse.</p>
      </div>
    </div>

    <hr class="my-4">

    <div class="row g-3">
      <div class="col-md-6">
        <div class="form-floating">
          <select class="form-select" id="jurado_1" name="jurado_1" required>
            <option value="">Selecciona el primer jurado...</option>
            <c:forEach var="j" items="${rsJurados.rows}">
              <option value="${j.id}" ${a.id_director == j.id ? 'selected' : ''}>
                <c:out value="${j.nombre}"/> (<c:out value="${j.rol}"/>)
              </option>
            </c:forEach>
          </select>
          <label for="jurado_1">Jurado 1</label>
        </div>
      </div>
      <div class="col-md-6">
        <div class="form-floating">
          <select class="form-select" id="jurado_2" name="jurado_2" required>
            <option value="">Selecciona el segundo jurado...</option>
            <c:forEach var="j" items="${rsJurados.rows}">
              <option value="${j.id}" ${a.id_evaluador == j.id ? 'selected' : ''}>
                <c:out value="${j.nombre}"/> (<c:out value="${j.rol}"/>)
              </option>
            </c:forEach>
          </select>
          <label for="jurado_2">Jurado 2</label>
        </div>
        <p class="form-help">Los dos jurados deben ser docentes diferentes.</p>
      </div>
    </div>

    <div class="d-flex gap-2 mt-4">
      <button type="submit" class="btn-uts"><i class="fas fa-save"></i> Programar sustentación</button>
      <a class="btn-uts-outline gris" href="<c:url value='/coordinacion/panel.jsp'/>"><i class="fas fa-times"></i> Cancelar</a>
    </div>
  </form>
</div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>

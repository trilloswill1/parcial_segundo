<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="coordinacion"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Panel"/>
<c:set var="menuActivo"   value="panel"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<%-- Conteo de ideas y anteproyectos por estado --%>
<sql:query var="ideasDisp" dataSource="${bd}">
  SELECT COUNT(*) AS n FROM ideas WHERE estado = 'disponible'
</sql:query>
<sql:query var="radicados" dataSource="${bd}">
  SELECT COUNT(*) AS n FROM anteproyectos WHERE estado = 'radicado'
</sql:query>
<sql:query var="enProceso" dataSource="${bd}">
  SELECT COUNT(*) AS n FROM anteproyectos WHERE estado IN ('con_director','aprobado_director')
</sql:query>
<sql:query var="aprobados" dataSource="${bd}">
  SELECT COUNT(*) AS n FROM anteproyectos WHERE estado = 'aprobado'
</sql:query>

<%-- Proyectos que cumplen los requisitos para programar sustentación --%>
<sql:query var="sustElegibles" dataSource="${bd}">
  SELECT a.id, a.titulo,
         CONCAT(e.nombres,' ',e.apellido1,' ',COALESCE(e.apellido2,'')) AS estudiante,
         CONCAT(e.codigo) AS codigo_estudiante,
         (SELECT MAX(ef.fecha_entrega) FROM entrega_final ef
          WHERE ef.id_anteproyecto = a.id AND ef.estado = 'Aprobado') AS fecha_entrega
  FROM anteproyectos a
  JOIN usuarios e ON e.id = a.id_estudiante
  WHERE a.estado = 'aprobado'
    AND EXISTS (SELECT 1 FROM entrega_final ef WHERE ef.id_anteproyecto = a.id AND ef.estado = 'Aprobado')
    AND NOT EXISTS (SELECT 1 FROM sustentacion s WHERE s.id_anteproyecto = a.id AND s.estado IN ('Programada','Realizada'))
  ORDER BY fecha_entrega DESC
</sql:query>

<%-- Sustentaciones ya programadas o registradas --%>
<sql:query var="sustProgramadas" dataSource="${bd}">
  SELECT s.id, s.fecha_sustentacion, s.hora_sustentacion, s.lugar, s.enlace, s.estado,
         CONCAT(e.nombres,' ',e.apellido1) AS estudiante,
         CONCAT(j1.nombres,' ',j1.apellido1) AS jurado1,
         CONCAT(j2.nombres,' ',j2.apellido1) AS jurado2
  FROM sustentacion s
  JOIN anteproyectos a ON a.id = s.id_anteproyecto
  JOIN usuarios e ON e.id = a.id_estudiante
  LEFT JOIN usuarios j1 ON j1.id = s.jurado_1
  LEFT JOIN usuarios j2 ON j2.id = s.jurado_2
  ORDER BY s.fecha_sustentacion DESC, s.hora_sustentacion DESC
  LIMIT 50
</sql:query>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-th-large"></i>Hola, <c:out value="${sessionScope.usuarioNombre}"/></h1>
    <p class="page-subtitle">Estado general de las ideas y los anteproyectos.</p>
  </div>
  <div class="page-actions">
    <a class="btn-uts" href="<c:url value='/coordinacion/idea_form.jsp'/>">
      <i class="fas fa-plus"></i> Nueva idea
    </a>
  </div>
</div>

<%-- Tarjetas de estadísticas --%>
<div class="row g-3 mb-4">
  <div class="col-6 col-xl-3">
    <div class="stat-card">
      <div class="stat-icon azul"><i class="fas fa-lightbulb"></i></div>
      <div>
        <div class="stat-valor"><c:out value="${ideasDisp.rows[0].n}"/></div>
        <div class="stat-etiqueta">Ideas disponibles</div>
      </div>
    </div>
  </div>
  <div class="col-6 col-xl-3">
    <div class="stat-card">
      <div class="stat-icon"><i class="fas fa-file-signature"></i></div>
      <div>
        <div class="stat-valor"><c:out value="${radicados.rows[0].n}"/></div>
        <div class="stat-etiqueta">Radicados (sin director)</div>
      </div>
    </div>
  </div>
  <div class="col-6 col-xl-3">
    <div class="stat-card">
      <div class="stat-icon ambar"><i class="fas fa-spinner"></i></div>
      <div>
        <div class="stat-valor"><c:out value="${enProceso.rows[0].n}"/></div>
        <div class="stat-etiqueta">En proceso de revisión</div>
      </div>
    </div>
  </div>
  <div class="col-6 col-xl-3">
    <div class="stat-card">
      <div class="stat-icon verde"><i class="fas fa-check-circle"></i></div>
      <div>
        <div class="stat-valor"><c:out value="${aprobados.rows[0].n}"/></div>
        <div class="stat-etiqueta">Aprobados</div>
      </div>
    </div>
  </div>
</div>

<%-- Sustentaciones: programar y hacer seguimiento --%>
<div class="card-ui mt-4">
  <div class="card-ui-header">
    <h2 class="card-ui-titulo"><i class="fas fa-gavel"></i>Sustentaciones</h2>
    <span class="badge-simple neutro"><c:out value="${sustProgramadas.rowCount}"/> programadas/registradas</span>
  </div>

  <h3 style="font-size:1.05rem;" class="mb-2"><i class="fas fa-calendar-plus"></i> Proyectos listos para sustentación</h3>
  <c:choose>
    <c:when test="${sustElegibles.rowCount == 0}">
      <p class="texto-resumen">No hay proyectos pendientes de programar. Un proyecto aparece aquí cuando tiene el anteproyecto aprobado y su entrega final aprobada.</p>
    </c:when>
    <c:otherwise>
      <div class="tabla-contenedor">
        <table class="table table-hover align-middle table-ui">
          <thead>
            <tr>
              <th>Estudiante</th>
              <th>Título</th>
              <th>Entrega aprobada</th>
              <th class="text-end">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="p" items="${sustElegibles.rows}">
              <tr>
                <td>
                  <strong><c:out value="${p.estudiante}"/></strong>
                  <br><span class="texto-resumen">Código <c:out value="${p.codigo_estudiante}"/></span>
                </td>
                <td><span class="texto-resumen"><c:out value="${p.titulo}"/></span></td>
                <td><fmt:formatDate value="${p.fecha_entrega}" pattern="dd/MM/yyyy"/></td>
                <td class="text-end">
                  <a class="btn-uts" href="<c:url value='/coordinacion/sustentacion_form.jsp?id=${p.id}'/>">
                    <i class="fas fa-gavel"></i> Asignar sustentación
                  </a>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </c:otherwise>
  </c:choose>

  <hr class="my-4">

  <h3 style="font-size:1.05rem;" class="mb-2"><i class="fas fa-list"></i> Sustentaciones programadas</h3>
  <c:choose>
    <c:when test="${sustProgramadas.rowCount == 0}">
      <p class="texto-resumen">Aún no se ha programado ninguna sustentación.</p>
    </c:when>
    <c:otherwise>
      <div class="tabla-contenedor">
        <table class="table table-hover align-middle table-ui">
          <thead>
            <tr>
              <th>Estudiante</th>
              <th>Fecha</th>
              <th>Hora</th>
              <th>Lugar / Enlace</th>
              <th>Jurados</th>
              <th class="text-center">Estado</th>
              <th class="text-end">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="sp" items="${sustProgramadas.rows}">
              <tr>
                <td><c:out value="${sp.estudiante}"/></td>
                <td><fmt:formatDate value="${sp.fecha_sustentacion}" pattern="dd/MM/yyyy"/></td>
                <td><fmt:formatDate value="${sp.hora_sustentacion}" pattern="HH:mm"/></td>
                <td>
                  <c:choose>
                    <c:when test="${not empty sp.lugar}"><span class="texto-resumen"><c:out value="${sp.lugar}"/></span></c:when>
                    <c:when test="${not empty sp.enlace}"><span class="texto-resumen"><c:out value="${sp.enlace}"/></span></c:when>
                    <c:otherwise><span class="texto-resumen">—</span></c:otherwise>
                  </c:choose>
                </td>
                <td><span class="texto-resumen"><c:out value="${sp.jurado1}"/> · <c:out value="${sp.jurado2}"/></span></td>
                <td class="text-center">
                  <c:set var="sustEstado" value="${sp.estado}"/>
                  <%@ include file="/WEB-INF/jspf/sustentacion_badge.jspf" %>
                </td>
                <td class="text-end">
                  <a class="btn-icono" href="<c:url value='/coordinacion/sustentacion_ver.jsp?id=${sp.id}'/>" title="Ver / revisar">
                    <i class="fas fa-clipboard-check"></i>
                  </a>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<%-- Accesos rápidos --%>
<div class="card-ui mt-4">
  <div class="card-ui-header">
    <h2 class="card-ui-titulo"><i class="fas fa-bolt"></i>Accesos rápidos</h2>
  </div>
  <div class="row g-3">
    <div class="col-md-6 col-xl-4">
      <a class="acceso-rapido" href="<c:url value='/coordinacion/notificaciones.jsp'/>">
        <span class="acceso-icono"><i class="fas fa-bell"></i></span>
        <span>
          <strong>Notificaciones</strong>
          <small>Ver actividad del sistema</small>
        </span>
      </a>
    </div>
    <div class="col-md-6 col-xl-4">
      <a class="acceso-rapido" href="<c:url value='/coordinacion/ideas.jsp'/>">
        <span class="acceso-icono"><i class="fas fa-lightbulb"></i></span>
        <span>
          <strong>Banco de Ideas</strong>
          <small>Crear y administrar ideas</small>
        </span>
      </a>
    </div>
    <div class="col-md-6 col-xl-4">
      <a class="acceso-rapido" href="<c:url value='/coordinacion/anteproyectos.jsp'/>">
        <span class="acceso-icono"><i class="fas fa-folder-open"></i></span>
        <span>
          <strong>Anteproyectos</strong>
          <small>Buscar y asignar director y evaluador</small>
        </span>
      </a>
    </div>
    <div class="col-md-6 col-xl-4">
      <a class="acceso-rapido" href="<c:url value='/coordinacion/entregas_finales.jsp'/>">
        <span class="acceso-icono"><i class="fas fa-file-upload"></i></span>
        <span>
          <strong>Entregas finales</strong>
          <small>Revisar y aprobar documentos</small>
        </span>
      </a>
    </div>
    <div class="col-md-6 col-xl-4">
      <a class="acceso-rapido" href="<c:url value='/coordinacion/informe_estudiantes.jsp'/>">
        <span class="acceso-icono"><i class="fas fa-user-graduate"></i></span>
        <span>
          <strong>Informe de estudiantes</strong>
          <small>Estado del proyecto por alumno</small>
        </span>
      </a>
    </div>
    <div class="col-md-6 col-xl-4">
      <a class="acceso-rapido" href="<c:url value='/coordinacion/informe_directores.jsp'/>">
        <span class="acceso-icono"><i class="fas fa-chalkboard-teacher"></i></span>
        <span>
          <strong>Informe de directores</strong>
          <small>Carga y avance por director</small>
        </span>
      </a>
    </div>
    <div class="col-md-6 col-xl-4">
      <a class="acceso-rapido" href="<c:url value='/coordinacion/informe_evaluadores.jsp'/>">
        <span class="acceso-icono"><i class="fas fa-clipboard-check"></i></span>
        <span>
          <strong>Informe de evaluadores</strong>
          <small>Pendientes y aprobaciones</small>
        </span>
      </a>
    </div>
    <div class="col-md-6 col-xl-4">
      <a class="acceso-rapido" href="<c:url value='/comun/calendario.jsp'/>">
        <span class="acceso-icono"><i class="fas fa-calendar-alt"></i></span>
        <span>
          <strong>Calendario académico</strong>
          <small>Fechas importantes del periodo</small>
        </span>
      </a>
    </div>
    <div class="col-md-6 col-xl-4">
      <a class="acceso-rapido" href="<c:url value='/comun/formatos.jsp'/>">
        <span class="acceso-icono"><i class="fas fa-file-alt"></i></span>
        <span>
          <strong>Formatos de grado</strong>
          <small>Plantillas oficiales</small>
        </span>
      </a>
    </div>
  </div>
</div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>

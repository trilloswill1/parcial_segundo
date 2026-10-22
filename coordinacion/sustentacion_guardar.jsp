<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="coordinacion"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>

<%-- Validación de campos obligatorios --%>
<c:if test="${empty param.id || empty param.fecha || empty param.hora || empty param.jurado_1 || empty param.jurado_2}">
  <c:redirect url="/coordinacion/sustentacion_form.jsp">
    <c:param name="id" value="${param.id}"/>
    <c:param name="error" value="Debes indicar fecha, hora y los dos jurados"/>
  </c:redirect>
</c:if>

<%-- Los jurados deben ser diferentes --%>
<c:if test="${param.jurado_1 == param.jurado_2}">
  <c:redirect url="/coordinacion/sustentacion_form.jsp">
    <c:param name="id" value="${param.id}"/>
    <c:param name="error" value="Los dos jurados deben ser docentes diferentes"/>
  </c:redirect>
</c:if>

<%-- Revalidación en el servidor: el proyecto debe seguir cumpliendo los requisitos --%>
<sql:query var="proy" dataSource="${bd}">
  SELECT a.id, a.id_estudiante,
         CONCAT(e.nombres,' ',e.apellido1,' ',COALESCE(e.apellido2,'')) AS estudiante
  FROM anteproyectos a
  JOIN usuarios e ON e.id = a.id_estudiante
  WHERE a.id = ? AND a.estado = 'aprobado'
    AND EXISTS (SELECT 1 FROM entrega_final ef WHERE ef.id_anteproyecto = a.id AND ef.estado = 'Aprobado')
    AND NOT EXISTS (SELECT 1 FROM sustentacion s WHERE s.id_anteproyecto = a.id AND s.estado IN ('Programada','Realizada'))
  <sql:param value="${param.id}"/>
</sql:query>

<c:if test="${proy.rowCount == 0}">
  <c:redirect url="/coordinacion/panel.jsp">
    <c:param name="error" value="No se pudo programar: el proyecto no cumple los requisitos o ya tiene una sustentación"/>
  </c:redirect>
</c:if>

<c:set var="antId"         value="${proy.rows[0].id}"/>
<c:set var="estudianteId"  value="${proy.rows[0].id_estudiante}"/>
<c:set var="estudianteNom" value="${proy.rows[0].estudiante}"/>

<%-- Los dos jurados deben existir y estar activos como director o evaluador --%>
<sql:query var="juradosOk" dataSource="${bd}">
  SELECT COUNT(*) AS n FROM usuarios
  WHERE estado = 'activo' AND rol IN ('director','evaluador') AND id IN (?, ?)
  <sql:param value="${param.jurado_1}"/>
  <sql:param value="${param.jurado_2}"/>
</sql:query>

<c:if test="${juradosOk.rows[0].n != 2}">
  <c:redirect url="/coordinacion/sustentacion_form.jsp">
    <c:param name="id" value="${param.id}"/>
    <c:param name="error" value="Uno de los jurados seleccionados no es válido"/>
  </c:redirect>
</c:if>

<c:catch var="errorSql">
  <sql:update var="ins" dataSource="${bd}">
    INSERT INTO sustentacion
      (id_anteproyecto, fecha_sustentacion, hora_sustentacion, lugar, enlace, jurado_1, jurado_2, estado)
    VALUES (?, ?, ?, ?, ?, ?, ?, 'Programada')
    <sql:param value="${antId}"/>
    <sql:param value="${param.fecha}"/>
    <sql:param value="${param.hora}"/>
    <sql:param value="${param.lugar}"/>
    <sql:param value="${param.enlace}"/>
    <sql:param value="${param.jurado_1}"/>
    <sql:param value="${param.jurado_2}"/>
  </sql:update>
</c:catch>

<c:if test="${not empty errorSql}">
  <c:redirect url="/coordinacion/panel.jsp">
    <c:param name="error" value="No fue posible guardar la sustentación"/>
  </c:redirect>
</c:if>

<%-- Recupero el id recién creado (el más reciente del anteproyecto) --%>
<sql:query var="nueva" dataSource="${bd}">
  SELECT id FROM sustentacion WHERE id_anteproyecto = ? ORDER BY id DESC LIMIT 1
  <sql:param value="${antId}"/>
</sql:query>
<c:set var="sustId" value="${nueva.rows[0].id}"/>

<%-- Notificación al estudiante --%>
<sql:update dataSource="${bd}">
  INSERT INTO notificaciones (tipo_evento, titulo, descripcion, id_usuario, id_referencia, tabla_referencia)
  VALUES ('sustentacion', 'Sustentación programada', ?, ?, ?, 'sustentacion')
  <sql:param value="Tu sustentación fue programada para el ${param.fecha} a las ${param.hora}. Ingresa a la sección Sustentación para ver el lugar o enlace."/>
  <sql:param value="${estudianteId}"/>
  <sql:param value="${sustId}"/>
</sql:update>

<%-- Notificación a los jurados --%>
<sql:update dataSource="${bd}">
  INSERT INTO notificaciones (tipo_evento, titulo, descripcion, id_usuario, id_referencia, tabla_referencia)
  VALUES ('sustentacion', 'Fuiste asignado como jurado', ?, ?, ?, 'sustentacion')
  <sql:param value="Fuiste asignado como jurado de la sustentación de ${estudianteNom} para el ${param.fecha} a las ${param.hora}."/>
  <sql:param value="${param.jurado_1}"/>
  <sql:param value="${sustId}"/>
</sql:update>
<sql:update dataSource="${bd}">
  INSERT INTO notificaciones (tipo_evento, titulo, descripcion, id_usuario, id_referencia, tabla_referencia)
  VALUES ('sustentacion', 'Fuiste asignado como jurado', ?, ?, ?, 'sustentacion')
  <sql:param value="Fuiste asignado como jurado de la sustentación de ${estudianteNom} para el ${param.fecha} a las ${param.hora}."/>
  <sql:param value="${param.jurado_2}"/>
  <sql:param value="${sustId}"/>
</sql:update>

<c:redirect url="/coordinacion/panel.jsp">
  <c:param name="ok" value="Sustentación programada correctamente"/>
</c:redirect>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="coordinacion"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>

<%-- Validaciones: deben ir ambos docentes --%>
<c:if test="${empty param.id_director || empty param.id_evaluador}">
  <c:redirect url="/coordinacion/asignar_form.jsp">
    <c:param name="id" value="${param.id}"/>
    <c:param name="error" value="Debes seleccionar director y evaluador"/>
  </c:redirect>
</c:if>

<c:catch var="errorSql">
  <%-- Asignar docentes y pasar el anteproyecto a con_director; solo si sigue radicado --%>
  <sql:update var="filas" dataSource="${bd}">
    UPDATE anteproyectos SET id_director = ?, id_evaluador = ?, estado = 'con_director'
    WHERE id = ? AND estado = 'radicado'
    <sql:param value="${param.id_director}"/>
    <sql:param value="${param.id_evaluador}"/>
    <sql:param value="${param.id}"/>
  </sql:update>
</c:catch>

<c:choose>
  <c:when test="${not empty errorSql || filas == 0}">
    <c:redirect url="/coordinacion/anteproyectos.jsp">
      <c:param name="error" value="No fue posible asignar: el anteproyecto ya no está radicado"/>
    </c:redirect>
  </c:when>
  <c:otherwise>
    <%-- Obtener nombres de director y evaluador para la notificación --%>
    <sql:query var="docentes" dataSource="${bd}">
      SELECT 
        CONCAT(d.nombres, ' ', d.apellido1) AS director_nombre,
        CONCAT(v.nombres, ' ', v.apellido1) AS evaluador_nombre,
        CONCAT(e.nombres, ' ', e.apellido1) AS estudiante_nombre
      FROM anteproyectos a
      JOIN usuarios d ON d.id = a.id_director
      JOIN usuarios v ON v.id = a.id_evaluador
      JOIN usuarios e ON e.id = a.id_estudiante
      WHERE a.id = ?
      <sql:param value="${param.id}"/>
    </sql:query>
    
    <c:if test="${docentes.rowCount > 0}">
      <c:set var="dir" value="${docentes.rows[0].director_nombre}"/>
      <c:set var="eva" value="${docentes.rows[0].evaluador_nombre}"/>
      <c:set var="est" value="${docentes.rows[0].estudiante_nombre}"/>
      
      <%-- Notificación al director --%>
      <sql:update dataSource="${bd}">
        INSERT INTO notificaciones (tipo_evento, titulo, descripcion, id_usuario, id_referencia, tabla_referencia)
        VALUES ('asignacion', 'Anteproyecto asignado como director', ?, ?, ?, 'anteproyectos')
        <sql:param value="Se te asignó como director del anteproyecto de ${est}"/>
        <sql:param value="${param.id_director}"/>
        <sql:param value="${param.id}"/>
      </sql:update>
      
      <%-- Notificación al evaluador --%>
      <sql:update dataSource="${bd}">
        INSERT INTO notificaciones (tipo_evento, titulo, descripcion, id_usuario, id_referencia, tabla_referencia)
        VALUES ('asignacion', 'Anteproyecto asignado como evaluador', ?, ?, ?, 'anteproyectos')
        <sql:param value="Se te asignó como evaluador del anteproyecto de ${est}"/>
        <sql:param value="${param.id_evaluador}"/>
        <sql:param value="${param.id}"/>
      </sql:update>
      
      <%-- Notificación a coordinación --%>
      <sql:update dataSource="${bd}">
        INSERT INTO notificaciones (tipo_evento, titulo, descripcion, id_usuario, id_referencia, tabla_referencia)
        VALUES ('asignacion', 'Director y evaluador asignados', ?, ?, ?, 'anteproyectos')
        <sql:param value="Asignados director (${dir}) y evaluador (${eva}) al anteproyecto de ${est}"/>
        <sql:param value="${sessionScope.usuarioId}"/>
        <sql:param value="${param.id}"/>
      </sql:update>
    </c:if>
    
    <c:redirect url="/coordinacion/anteproyectos.jsp">
      <c:param name="ok" value="Director y evaluador asignados correctamente"/>
    </c:redirect>
  </c:otherwise>
</c:choose>
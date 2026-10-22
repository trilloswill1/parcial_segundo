<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="evaluador"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>

<c:if test="${empty param.id}">
  <c:redirect url="/evaluador/anteproyectos.jsp">
    <c:param name="error" value="No se indicó qué anteproyecto aprobar"/>
  </c:redirect>
</c:if>

<%-- Aprueba para el estudiante y la coordinación; solo si es suyo y está aprobado por el director --%>
<c:catch var="errorSql">
  <sql:update var="filas" dataSource="${bd}">
    UPDATE anteproyectos SET estado = 'aprobado'
    WHERE id = ? AND id_evaluador = ? AND estado = 'aprobado_director'
    <sql:param value="${param.id}"/>
    <sql:param value="${sessionScope.usuarioId}"/>
  </sql:update>
</c:catch>

<c:choose>
  <c:when test="${not empty errorSql || filas == 0}">
    <c:redirect url="/evaluador/anteproyecto_ver.jsp">
      <c:param name="id" value="${param.id}"/>
      <c:param name="error" value="No fue posible aprobar: el anteproyecto debe estar aprobado por el director"/>
    </c:redirect>
  </c:when>
  <c:otherwise>
    <%-- Obtener información para notificaciones --%>
    <sql:query var="info" dataSource="${bd}">
      SELECT 
        CONCAT(e.nombres, ' ', e.apellido1) AS estudiante_nombre,
        a.id_director,
        CONCAT(d.nombres, ' ', d.apellido1) AS director_nombre
      FROM anteproyectos a
      JOIN usuarios e ON e.id = a.id_estudiante
      LEFT JOIN usuarios d ON d.id = a.id_director
      WHERE a.id = ?
      <sql:param value="${param.id}"/>
    </sql:query>
    
    <c:if test="${info.rowCount > 0}">
      <c:set var="est" value="${info.rows[0].estudiante_nombre}"/>
      <c:set var="dirId" value="${info.rows[0].id_director}"/>
      <c:set var="dirNom" value="${info.rows[0].director_nombre}"/>
      
      <%-- Notificación al director --%>
      <c:if test="${not empty dirId}">
        <sql:update dataSource="${bd}">
          INSERT INTO notificaciones (tipo_evento, titulo, descripcion, id_usuario, id_referencia, tabla_referencia)
          VALUES ('aprobacion', 'Anteproyecto aprobado por evaluador', ?, ?, ?, 'anteproyectos')
          <sql:param value="El evaluador aprobó el anteproyecto de ${est}. Proceso completado."/>
          <sql:param value="${dirId}"/>
          <sql:param value="${param.id}"/>
        </sql:update>
      </c:if>
      
      <%-- Notificación a coordinación --%>
      <c:set var="msgCoord">
        El evaluador aprobó el anteproyecto de ${est}.
        <c:choose>
          <c:when test="${not empty dirNom}">Director: ${dirNom}</c:when>
          <c:otherwise>Sin director asignado</c:otherwise>
        </c:choose>
        . Proceso completado.
      </c:set>
      <sql:update dataSource="${bd}">
        INSERT INTO notificaciones (tipo_evento, titulo, descripcion, id_usuario, id_referencia, tabla_referencia)
        VALUES ('aprobacion', 'Anteproyecto aprobado por evaluador', ?, ?, ?, 'anteproyectos')
        <sql:param value="${msgCoord}"/>
        <sql:param value="${sessionScope.usuarioId}"/>
        <sql:param value="${param.id}"/>
      </sql:update>
      
      <%-- Notificación al estudiante --%>
      <sql:query var="estId" dataSource="${bd}">
        SELECT id_estudiante FROM anteproyectos WHERE id = ?
        <sql:param value="${param.id}"/>
      </sql:query>
      <c:if test="${estId.rowCount > 0}">
        <sql:update dataSource="${bd}">
          INSERT INTO notificaciones (tipo_evento, titulo, descripcion, id_usuario, id_referencia, tabla_referencia)
          VALUES ('aprobacion', 'Tu anteproyecto fue aprobado', ?, ?, ?, 'anteproyectos')
          <sql:param value="Tu anteproyecto fue aprobado por el evaluador. ¡Felicidades! El proceso de anteproyecto ha finalizado."/>
          <sql:param value="${estId.rows[0].id_estudiante}"/>
          <sql:param value="${param.id}"/>
        </sql:update>
      </c:if>
    </c:if>
    
    <c:redirect url="/evaluador/anteproyectos.jsp">
      <c:param name="ok" value="Anteproyecto aprobado para el estudiante y la coordinación"/>
    </c:redirect>
  </c:otherwise>
</c:choose>
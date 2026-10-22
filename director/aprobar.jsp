<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="director"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>

<c:if test="${empty param.id}">
  <c:redirect url="/director/anteproyectos.jsp">
    <c:param name="error" value="No se indicó qué anteproyecto aprobar"/>
  </c:redirect>
</c:if>

<%-- Solo aprueba si el anteproyecto es suyo, está con_director y la nota es >= 3.0 --%>
<c:catch var="errorSql">
  <sql:update var="filas" dataSource="${bd}">
    UPDATE anteproyectos SET estado = 'aprobado_director'
    WHERE id = ? AND id_director = ? AND estado = 'con_director' AND nota_director >= 3.0
    <sql:param value="${param.id}"/>
    <sql:param value="${sessionScope.usuarioId}"/>
  </sql:update>
</c:catch>

<c:choose>
  <c:when test="${not empty errorSql || filas == 0}">
    <c:redirect url="/director/anteproyecto_ver.jsp">
      <c:param name="id" value="${param.id}"/>
      <c:param name="error" value="No se pudo aprobar: revisa que la nota sea 3.0 o más y que el anteproyecto siga con director"/>
    </c:redirect>
  </c:when>
  <c:otherwise>
    <%-- Obtener información para notificaciones --%>
    <sql:query var="info" dataSource="${bd}">
      SELECT 
        CONCAT(e.nombres, ' ', e.apellido1) AS estudiante_nombre,
        a.id_evaluador,
        CONCAT(v.nombres, ' ', v.apellido1) AS evaluador_nombre
      FROM anteproyectos a
      JOIN usuarios e ON e.id = a.id_estudiante
      LEFT JOIN usuarios v ON v.id = a.id_evaluador
      WHERE a.id = ?
      <sql:param value="${param.id}"/>
    </sql:query>
    
    <c:if test="${info.rowCount > 0}">
      <c:set var="est" value="${info.rows[0].estudiante_nombre}"/>
      <c:set var="evaId" value="${info.rows[0].id_evaluador}"/>
      <c:set var="evaNom" value="${info.rows[0].evaluador_nombre}"/>
      
      <%-- Notificación al evaluador --%>
      <c:if test="${not empty evaId}">
        <sql:update dataSource="${bd}">
          INSERT INTO notificaciones (tipo_evento, titulo, descripcion, id_usuario, id_referencia, tabla_referencia)
          VALUES ('aprobacion', 'Anteproyecto aprobado por director', ?, ?, ?, 'anteproyectos')
          <sql:param value="El director aprobó el anteproyecto de ${est}. Pendiente de tu evaluación."/>
          <sql:param value="${evaId}"/>
          <sql:param value="${param.id}"/>
        </sql:update>
      </c:if>
      
      <%-- Notificación a coordinación --%>
      <c:set var="msgCoord">
        El director aprobó el anteproyecto de ${est}.
        <c:choose>
          <c:when test="${not empty evaNom}">Evaluador: ${evaNom}</c:when>
          <c:otherwise>Sin evaluador asignado</c:otherwise>
        </c:choose>
      </c:set>
      <sql:update dataSource="${bd}">
        INSERT INTO notificaciones (tipo_evento, titulo, descripcion, id_usuario, id_referencia, tabla_referencia)
        VALUES ('aprobacion', 'Anteproyecto aprobado por director', ?, ?, ?, 'anteproyectos')
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
          VALUES ('aprobacion', 'Tu anteproyecto fue aprobado por el director', ?, ?, ?, 'anteproyectos')
          <sql:param value="Tu anteproyecto fue aprobado por el director. Ahora pasa a evaluación."/>
          <sql:param value="${estId.rows[0].id_estudiante}"/>
          <sql:param value="${param.id}"/>
        </sql:update>
      </c:if>
    </c:if>
    
    <c:redirect url="/director/anteproyectos.jsp">
      <c:param name="ok" value="Anteproyecto aprobado para el evaluador"/>
    </c:redirect>
  </c:otherwise>
</c:choose>
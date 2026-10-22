<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="director"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>

<%-- Valido que llegue la nota y el id --%>
<c:if test="${empty param.nota || empty param.id}">
  <c:redirect url="/director/anteproyectos.jsp">
    <c:param name="error" value="Debes asignar una nota al anteproyecto"/>
  </c:redirect>
</c:if>

<%-- Convierto la nota (que llega como texto) en número para validarla --%>
<%-- parseLocale en_US: el formulario envía la nota con punto (4.2) aunque la página esté en es_CO --%>
<c:catch var="errorNota">
  <fmt:parseNumber var="notaNum" value="${param.nota}" pattern="0.0" parseLocale="en_US"/>
</c:catch>
<c:if test="${not empty errorNota}">
  <c:redirect url="/director/anteproyecto_ver.jsp">
    <c:param name="id" value="${param.id}"/>
    <c:param name="error" value="La nota debe ser un número entre 0.0 y 5.0"/>
  </c:redirect>
</c:if>
<c:if test="${notaNum < 0.0 || notaNum > 5.0}">
  <c:redirect url="/director/anteproyecto_ver.jsp">
    <c:param name="id" value="${param.id}"/>
    <c:param name="error" value="La nota debe estar entre 0.0 y 5.0"/>
  </c:redirect>
</c:if>

<%-- Solo guarda la nota y observaciones; el estado lo cambia aprobar.jsp --%>
<c:catch var="errorSql">
  <sql:update var="filas" dataSource="${bd}">
    UPDATE anteproyectos
    SET nota_director = ?, observaciones_director = ?
    WHERE id = ? AND id_director = ? AND estado = 'con_director'
    <sql:param value="${notaNum}"/>
    <sql:param value="${param.observaciones}"/>
    <sql:param value="${param.id}"/>
    <sql:param value="${sessionScope.usuarioId}"/>
  </sql:update>
</c:catch>

<c:choose>
  <c:when test="${not empty errorSql || filas == 0}">
    <c:redirect url="/director/anteproyecto_ver.jsp">
      <c:param name="id" value="${param.id}"/>
      <c:param name="error" value="No fue posible guardar la calificación"/>
    </c:redirect>
  </c:when>
  <c:otherwise>
    <%-- Notificación de calificación guardada --%>
    <sql:query var="info" dataSource="${bd}">
      SELECT 
        CONCAT(e.nombres, ' ', e.apellido1) AS estudiante_nombre,
        a.id_estudiante
      FROM anteproyectos a
      JOIN usuarios e ON e.id = a.id_estudiante
      WHERE a.id = ?
      <sql:param value="${param.id}"/>
    </sql:query>
    
    <c:if test="${info.rowCount > 0}">
      <c:set var="est" value="${info.rows[0].estudiante_nombre}"/>
      <c:set var="estId" value="${info.rows[0].id_estudiante}"/>
      
      <%-- Notificación al estudiante --%>
      <c:set var="msgEst">
        El director calificó tu anteproyecto con nota ${notaNum}.
        <c:if test="${not empty param.observaciones}">Observaciones: ${param.observaciones}</c:if>
      </c:set>
      <sql:update dataSource="${bd}">
        INSERT INTO notificaciones (tipo_evento, titulo, descripcion, id_usuario, id_referencia, tabla_referencia)
        VALUES ('calificacion', 'Calificación registrada en tu anteproyecto', ?, ?, ?, 'anteproyectos')
        <sql:param value="${msgEst}"/>
        <sql:param value="${estId}"/>
        <sql:param value="${param.id}"/>
      </sql:update>
      
      <%-- Notificación a coordinación --%>
      <sql:update dataSource="${bd}">
        INSERT INTO notificaciones (tipo_evento, titulo, descripcion, id_usuario, id_referencia, tabla_referencia)
        VALUES ('calificacion', 'Calificación registrada por director', ?, ?, ?, 'anteproyectos')
        <sql:param value="El director calificó el anteproyecto de ${est} con nota ${notaNum}"/>
        <sql:param value="${sessionScope.usuarioId}"/>
        <sql:param value="${param.id}"/>
      </sql:update>
    </c:if>
    
    <c:redirect url="/director/anteproyecto_ver.jsp">
      <c:param name="id" value="${param.id}"/>
      <c:param name="ok" value="Calificación guardada correctamente"/>
    </c:redirect>
  </c:otherwise>
</c:choose>
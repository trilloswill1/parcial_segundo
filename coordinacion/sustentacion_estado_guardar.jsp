<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="coordinacion"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>

<%
// Validación de la calificación (opcional): debe ser un número entre 0 y 5
boolean calOk = true;
String calRaw = request.getParameter("calificacion");
String calVal = null;
if (calRaw != null) {
  calRaw = calRaw.trim();
  if (calRaw.length() > 0) {
    try {
      double c = Double.parseDouble(calRaw);
      if (c < 0 || c > 5) { calOk = false; } else { calVal = calRaw; }
    } catch (NumberFormatException ex) {
      calOk = false;
    }
  }
}
pageContext.setAttribute("calOk", calOk);
pageContext.setAttribute("calVal", calVal);
%>

<c:if test="${empty param.id}">
  <c:redirect url="/coordinacion/panel.jsp">
    <c:param name="error" value="No se indicó qué sustentación actualizar"/>
  </c:redirect>
</c:if>

<%-- Estado dentro de la lista permitida --%>
<c:set var="estadoDb" value=""/>
<c:choose>
  <c:when test="${param.estado == 'Programada'}"><c:set var="estadoDb" value="Programada"/></c:when>
  <c:when test="${param.estado == 'Realizada'}"><c:set var="estadoDb" value="Realizada"/></c:when>
  <c:when test="${param.estado == 'Cancelada'}"><c:set var="estadoDb" value="Cancelada"/></c:when>
</c:choose>

<c:if test="${empty estadoDb}">
  <c:redirect url="/coordinacion/sustentacion_ver.jsp">
    <c:param name="id" value="${param.id}"/>
    <c:param name="error" value="Estado no válido"/>
  </c:redirect>
</c:if>

<c:if test="${!calOk}">
  <c:redirect url="/coordinacion/sustentacion_ver.jsp">
    <c:param name="id" value="${param.id}"/>
    <c:param name="error" value="La calificación debe ser un número entre 0.0 y 5.0"/>
  </c:redirect>
</c:if>

<%-- Verificar que la sustentación existe y obtener el estudiante para notificar --%>
<sql:query var="info" dataSource="${bd}">
  SELECT s.id, a.id_estudiante,
         CONCAT(e.nombres,' ',e.apellido1) AS estudiante
  FROM sustentacion s
  JOIN anteproyectos a ON a.id = s.id_anteproyecto
  JOIN usuarios e ON e.id = a.id_estudiante
  WHERE s.id = ?
  <sql:param value="${param.id}"/>
</sql:query>

<c:if test="${info.rowCount == 0}">
  <c:redirect url="/coordinacion/panel.jsp">
    <c:param name="error" value="La sustentación no existe"/>
  </c:redirect>
</c:if>

<c:set var="sustId"       value="${info.rows[0].id}"/>
<c:set var="estudianteId" value="${info.rows[0].id_estudiante}"/>

<c:catch var="errorSql">
  <c:choose>
    <c:when test="${empty calVal}">
      <sql:update var="filas" dataSource="${bd}">
        UPDATE sustentacion SET estado = ?, calificacion = NULL, observaciones = ? WHERE id = ?
        <sql:param value="${estadoDb}"/>
        <sql:param value="${param.observaciones}"/>
        <sql:param value="${sustId}"/>
      </sql:update>
    </c:when>
    <c:otherwise>
      <sql:update var="filas" dataSource="${bd}">
        UPDATE sustentacion SET estado = ?, calificacion = ?, observaciones = ? WHERE id = ?
        <sql:param value="${estadoDb}"/>
        <sql:param value="${calVal}"/>
        <sql:param value="${param.observaciones}"/>
        <sql:param value="${sustId}"/>
      </sql:update>
    </c:otherwise>
  </c:choose>
</c:catch>

<c:choose>
  <c:when test="${not empty errorSql}">
    <c:redirect url="/coordinacion/sustentacion_ver.jsp">
      <c:param name="id" value="${sustId}"/>
      <c:param name="error" value="No fue posible guardar los cambios"/>
    </c:redirect>
  </c:when>
  <c:otherwise>
    <%-- Título y descripción de la notificación según el nuevo estado --%>
    <c:set var="tituloNotif" value="Sustentación actualizada"/>
    <c:set var="descNotif" value="El estado de tu sustentación es: ${estadoDb}."/>
    <c:choose>
      <c:when test="${estadoDb == 'Realizada'}">
        <c:set var="tituloNotif" value="Sustentación realizada"/>
        <c:set var="descNotif" value="Tu sustentación fue registrada como realizada."/>
      </c:when>
      <c:when test="${estadoDb == 'Cancelada'}">
        <c:set var="tituloNotif" value="Sustentación cancelada"/>
        <c:set var="descNotif" value="Tu sustentación fue cancelada."/>
      </c:when>
    </c:choose>
    <c:if test="${not empty calVal}">
      <c:set var="descNotif" value="${descNotif} Calificación registrada: ${calVal}/5.0."/>
    </c:if>
    <c:if test="${not empty param.observaciones}">
      <c:set var="descNotif" value="${descNotif} Observaciones: ${param.observaciones}"/>
    </c:if>

    <sql:update dataSource="${bd}">
      INSERT INTO notificaciones (tipo_evento, titulo, descripcion, id_usuario, id_referencia, tabla_referencia)
      VALUES ('sustentacion', ?, ?, ?, ?, 'sustentacion')
      <sql:param value="${tituloNotif}"/>
      <sql:param value="${descNotif}"/>
      <sql:param value="${estudianteId}"/>
      <sql:param value="${sustId}"/>
    </sql:update>

    <c:redirect url="/coordinacion/sustentacion_ver.jsp">
      <c:param name="id" value="${sustId}"/>
      <c:param name="ok" value="Sustentación actualizada correctamente"/>
    </c:redirect>
  </c:otherwise>
</c:choose>

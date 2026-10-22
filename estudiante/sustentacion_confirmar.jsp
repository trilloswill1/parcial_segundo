<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="estudiante"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>

<%-- El estudiante confirma su propia sustentación. Solo actualiza la fila
     vinculada a su anteproyecto y únicamente si está en estado Programada. --%>
<c:if test="${empty param.id}">
  <c:redirect url="/estudiante/sustentacion.jsp">
    <c:param name="error" value="No se indicó qué sustentación confirmar"/>
  </c:redirect>
</c:if>

<c:set var="sustId"       value="${param.id}"/>
<c:set var="estudianteId" value="${sessionScope.usuarioId}"/>

<c:catch var="errorSql">
  <sql:update var="filas" dataSource="${bd}">
    UPDATE sustentacion s
    JOIN anteproyectos a ON a.id = s.id_anteproyecto
    SET s.estado = 'Realizada'
    WHERE s.id = ? AND a.id_estudiante = ? AND s.estado = 'Programada'
    <sql:param value="${sustId}"/>
    <sql:param value="${estudianteId}"/>
  </sql:update>
</c:catch>

<c:choose>
  <c:when test="${not empty errorSql}">
    <c:redirect url="/estudiante/sustentacion.jsp">
      <c:param name="error" value="No fue posible registrar la sustentación"/>
    </c:redirect>
  </c:when>
  <c:when test="${filas == 0}">
    <c:redirect url="/estudiante/sustentacion.jsp">
      <c:param name="error" value="No se pudo confirmar: la sustentación no está disponible, ya fue realizada o fue cancelada"/>
    </c:redirect>
  </c:when>
  <c:otherwise>
    <c:redirect url="/estudiante/sustentacion.jsp">
      <c:param name="ok" value="Tu sustentación fue registrada como realizada"/>
    </c:redirect>
  </c:otherwise>
</c:choose>

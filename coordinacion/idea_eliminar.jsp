<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="coordinacion"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>

<c:if test="${empty param.id}">
  <c:redirect url="/coordinacion/ideas.jsp">
    <c:param name="error" value="No se indicó qué idea eliminar"/>
  </c:redirect>
</c:if>

<%-- Intento eliminar; si la idea tiene anteproyecto asociado, la llave foránea lo impide --%>
<c:catch var="errorSql">
  <sql:update var="filas" dataSource="${bd}">
    DELETE FROM ideas WHERE id = ? AND estado = 'disponible'
    <sql:param value="${param.id}"/>
  </sql:update>
</c:catch>

<c:choose>
  <c:when test="${not empty errorSql || filas == 0}">
    <c:redirect url="/coordinacion/ideas.jsp">
      <c:param name="error" value="No se puede eliminar la idea porque ya fue tomada y tiene un anteproyecto asociado"/>
    </c:redirect>
  </c:when>
  <c:otherwise>
    <c:redirect url="/coordinacion/ideas.jsp">
      <c:param name="ok" value="Idea eliminada correctamente"/>
    </c:redirect>
  </c:otherwise>
</c:choose>
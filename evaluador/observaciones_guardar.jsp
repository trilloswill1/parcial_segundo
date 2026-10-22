<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="evaluador"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>

<c:if test="${empty param.id}">
  <c:redirect url="/evaluador/anteproyectos.jsp">
    <c:param name="error" value="No se indicó qué anteproyecto evaluar"/>
  </c:redirect>
</c:if>

<%-- Guarda observaciones del evaluador; solo si el anteproyecto es suyo y está aprobado por el director --%>
<c:catch var="errorSql">
  <sql:update var="filas" dataSource="${bd}">
    UPDATE anteproyectos SET observaciones_evaluador = ?
    WHERE id = ? AND id_evaluador = ? AND estado = 'aprobado_director'
    <sql:param value="${param.observaciones}"/>
    <sql:param value="${param.id}"/>
    <sql:param value="${sessionScope.usuarioId}"/>
  </sql:update>
</c:catch>

<c:choose>
  <c:when test="${not empty errorSql || filas == 0}">
    <c:redirect url="/evaluador/anteproyecto_ver.jsp">
      <c:param name="id" value="${param.id}"/>
      <c:param name="error" value="No fue posible guardar las observaciones"/>
    </c:redirect>
  </c:when>
  <c:otherwise>
    <c:redirect url="/evaluador/anteproyecto_ver.jsp">
      <c:param name="id" value="${param.id}"/>
      <c:param name="ok" value="Observaciones guardadas correctamente"/>
    </c:redirect>
  </c:otherwise>
</c:choose>
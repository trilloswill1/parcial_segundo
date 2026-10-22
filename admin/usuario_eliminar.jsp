<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="administrador"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>

<%-- No se puede eliminar el propio administrador que está en sesión --%>
<c:if test="${param.id == sessionScope.usuarioId}">
  <c:redirect url="/admin/usuarios.jsp">
    <c:param name="error" value="No puedes eliminar tu propia cuenta"/>
  </c:redirect>
</c:if>

<c:if test="${empty param.id}">
  <c:redirect url="/admin/usuarios.jsp">
    <c:param name="error" value="No se indicó qué usuario eliminar"/>
  </c:redirect>
</c:if>

<%-- Intento eliminar; si tiene ideas o anteproyectos asociados falla por la llave foránea --%>
<c:catch var="errorSql">
  <sql:update var="filas" dataSource="${bd}">
    DELETE FROM usuarios WHERE id = ?
    <sql:param value="${param.id}"/>
  </sql:update>
</c:catch>

<c:choose>
  <c:when test="${not empty errorSql}">
    <c:redirect url="/admin/usuarios.jsp">
      <c:param name="error" value="No se puede eliminar: el usuario tiene información asociada. Puedes cambiar su estado a inactivo"/>
    </c:redirect>
  </c:when>
  <c:when test="${filas == 0}">
    <c:redirect url="/admin/usuarios.jsp">
      <c:param name="error" value="El usuario no existe"/>
    </c:redirect>
  </c:when>
  <c:otherwise>
    <c:redirect url="/admin/usuarios.jsp">
      <c:param name="ok" value="Usuario eliminado correctamente"/>
    </c:redirect>
  </c:otherwise>
</c:choose>
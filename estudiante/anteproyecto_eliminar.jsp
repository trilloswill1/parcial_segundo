<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="estudiante"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>

<c:if test="${empty param.id}">
  <c:redirect url="/estudiante/mi_anteproyecto.jsp">
    <c:param name="error" value="No se indicó qué anteproyecto eliminar"/>
  </c:redirect>
</c:if>

<%-- Transacción: elimina el anteproyecto del estudiante (solo si está radicado) y libera la idea --%>
<c:catch var="errorSql">
  <sql:transaction dataSource="${bd}">
    <sql:update>
      UPDATE ideas i
      JOIN anteproyectos a ON a.id_idea = i.id
      SET i.estado = 'disponible'
      WHERE a.id = ? AND a.id_estudiante = ? AND a.estado = 'radicado'
      <sql:param value="${param.id}"/>
      <sql:param value="${sessionScope.usuarioId}"/>
    </sql:update>
    <sql:update var="filas">
      DELETE FROM anteproyectos
      WHERE id = ? AND id_estudiante = ? AND estado = 'radicado'
      <sql:param value="${param.id}"/>
      <sql:param value="${sessionScope.usuarioId}"/>
    </sql:update>
  </sql:transaction>
</c:catch>

<c:choose>
  <c:when test="${not empty errorSql || filas == 0}">
    <c:redirect url="/estudiante/mi_anteproyecto.jsp">
      <c:param name="error" value="No fue posible eliminar el anteproyecto. Solo se puede eliminar si está radicado"/>
    </c:redirect>
  </c:when>
  <c:otherwise>
    <c:redirect url="/estudiante/mi_anteproyecto.jsp">
      <c:param name="ok" value="Anteproyecto eliminado y su idea quedó disponible de nuevo"/>
    </c:redirect>
  </c:otherwise>
</c:choose>
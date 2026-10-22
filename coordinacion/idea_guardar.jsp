<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="coordinacion"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>

<%-- Validaciones del formulario --%>
<c:if test="${empty param.titulo || empty param.descripcion}">
  <c:redirect url="/coordinacion/idea_form.jsp">
    <c:if test="${not empty param.id}"><c:param name="id" value="${param.id}"/></c:if>
    <c:param name="error" value="El título y la descripción son obligatorios"/>
  </c:redirect>
</c:if>

<c:catch var="errorSql">
  <c:choose>
    <c:when test="${not empty param.id}">
      <%-- Actualizo la idea existente sin cambiar su estado --%>
      <sql:update dataSource="${bd}">
        UPDATE ideas SET titulo = ?, descripcion = ? WHERE id = ?
        <sql:param value="${param.titulo}"/>
        <sql:param value="${param.descripcion}"/>
        <sql:param value="${param.id}"/>
      </sql:update>
    </c:when>
    <c:otherwise>
      <%-- Nueva idea siempre queda disponible y la registra la coordinación de la sesión --%>
      <sql:update dataSource="${bd}">
        INSERT INTO ideas (titulo, descripcion, estado, id_coordinador, fecha_registro)
        VALUES (?, ?, 'disponible', ?, CURDATE())
        <sql:param value="${param.titulo}"/>
        <sql:param value="${param.descripcion}"/>
        <sql:param value="${sessionScope.usuarioId}"/>
      </sql:update>
    </c:otherwise>
  </c:choose>
</c:catch>

<c:choose>
  <c:when test="${not empty errorSql}">
    <c:redirect url="/coordinacion/idea_form.jsp">
      <c:if test="${not empty param.id}"><c:param name="id" value="${param.id}"/></c:if>
      <c:param name="error" value="No fue posible guardar la idea, inténtalo de nuevo"/>
    </c:redirect>
  </c:when>
  <c:otherwise>
    <%-- Notificación de idea nueva --%>
    <c:if test="${empty param.id}">
      <sql:query var="nuevaIdea" dataSource="${bd}">
        SELECT LAST_INSERT_ID() AS id FROM ideas LIMIT 1
      </sql:query>
      <sql:update dataSource="${bd}">
        INSERT INTO notificaciones (tipo_evento, titulo, descripcion, id_usuario, id_referencia, tabla_referencia)
        VALUES ('idea_nueva', 'Nueva idea de anteproyecto', ?, ?, ?, 'ideas')
        <sql:param value="Se creó la idea: ${param.titulo}"/>
        <sql:param value="${sessionScope.usuarioId}"/>
        <sql:param value="${nuevaIdea.rows[0].id}"/>
      </sql:update>
    </c:if>
    <c:redirect url="/coordinacion/ideas.jsp">
      <c:param name="ok" value="Idea guardada correctamente"/>
    </c:redirect>
  </c:otherwise>
</c:choose>

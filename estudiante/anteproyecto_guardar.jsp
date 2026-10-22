<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="estudiante"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>

<%-- Validaciones del formulario --%>
<c:if test="${empty param.titulo || empty param.resumen}">
  <c:redirect url="/estudiante/anteproyecto_form.jsp">
    <c:if test="${not empty param.id}"><c:param name="id" value="${param.id}"/></c:if>
    <c:if test="${empty param.id && not empty param.id_idea}"><c:param name="idea" value="${param.id_idea}"/></c:if>
    <c:param name="error" value="El título y el resumen son obligatorios"/>
  </c:redirect>
</c:if>

<%-- Transacción: en modo nuevo inserta el anteproyecto y marca la idea como tomada --%>
<c:catch var="errorSql">
  <sql:transaction dataSource="${bd}">
    <c:choose>
      <c:when test="${not empty param.id}">
        <%-- Solo se puede actualizar si sigue radicado y pertenece al estudiante --%>
        <sql:update var="filas">
          UPDATE anteproyectos
          SET titulo = ?, resumen = ?, enlace_documento = ?
          WHERE id = ? AND id_estudiante = ? AND estado = 'radicado'
          <sql:param value="${param.titulo}"/>
          <sql:param value="${param.resumen}"/>
          <sql:param value="${param.enlace_documento}"/>
          <sql:param value="${param.id}"/>
          <sql:param value="${sessionScope.usuarioId}"/>
        </sql:update>
      </c:when>
      <c:otherwise>
        <%-- Verifica dentro de la transacción que la idea siga disponible --%>
        <sql:update>
          UPDATE ideas SET estado = 'tomada'
          WHERE id = ? AND estado = 'disponible'
          <sql:param value="${param.id_idea}"/>
        </sql:update>
        <sql:update>
          INSERT INTO anteproyectos (id_estudiante, id_idea, titulo, resumen, enlace_documento, estado, fecha_registro)
          VALUES (?, ?, ?, ?, ?, 'radicado', CURDATE())
          <sql:param value="${sessionScope.usuarioId}"/>
          <sql:param value="${param.id_idea}"/>
          <sql:param value="${param.titulo}"/>
          <sql:param value="${param.resumen}"/>
          <sql:param value="${param.enlace_documento}"/>
        </sql:update>
      </c:otherwise>
    </c:choose>
  </sql:transaction>
</c:catch>

<c:choose>
  <%-- Error si falló la transacción o si editando no se afectó ninguna fila --%>
  <c:when test="${not empty errorSql || (not empty param.id && filas == 0)}">
    <c:redirect url="/estudiante/mi_anteproyecto.jsp">
      <c:param name="error" value="No fue posible guardar: el anteproyecto ya no está radicado"/>
    </c:redirect>
  </c:when>
  <c:otherwise>
    <%-- Notificación de anteproyecto nuevo (solo en modo nuevo) --%>
    <c:if test="${empty param.id}">
      <sql:query var="nuevoAnte" dataSource="${bd}">
        SELECT LAST_INSERT_ID() AS id FROM anteproyectos LIMIT 1
      </sql:query>
      <sql:update dataSource="${bd}">
        INSERT INTO notificaciones (tipo_evento, titulo, descripcion, id_usuario, id_referencia, tabla_referencia)
        VALUES ('anteproyecto_nuevo', 'Nuevo anteproyecto radicado', ?, ?, ?, 'anteproyectos')
        <sql:param value="El estudiante ${sessionScope.usuarioNombre} radicó: ${param.titulo}"/>
        <sql:param value="${sessionScope.usuarioId}"/>
        <sql:param value="${nuevoAnte.rows[0].id}"/>
      </sql:update>
    </c:if>
    <c:redirect url="/estudiante/mi_anteproyecto.jsp">
      <c:param name="ok" value="Anteproyecto guardado correctamente"/>
    </c:redirect>
  </c:otherwise>
</c:choose>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="cualquiera"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>

<c:if test="${empty sessionScope.usuarioId}">
  <c:redirect url="/index.jsp"/>
</c:if>

<c:if test="${empty param.tipo || empty param.asunto || empty param.descripcion}">
  <c:redirect url="/pqrs/registro.jsp">
    <c:param name="error" value="Todos los campos obligatorios deben estar diligenciados"/>
  </c:redirect>
</c:if>

<c:if test="${param.tipo ne 'Petición' && param.tipo ne 'Queja' && param.tipo ne 'Reclamo' && param.tipo ne 'Sugerencia'}">
  <c:redirect url="/pqrs/registro.jsp">
    <c:param name="error" value="El tipo de PQRS seleccionado no es válido"/>
  </c:redirect>
</c:if>

<c:catch var="errorSql">
  <sql:query var="solicitante" dataSource="${bd}">
    SELECT codigo, CONCAT(nombres,' ',apellido1,' ',IFNULL(apellido2,'')) AS nombre, correo, rol
    FROM usuarios WHERE id = ?
    <sql:param value="${sessionScope.usuarioId}"/>
  </sql:query>

  <sql:transaction dataSource="${bd}">
    <sql:update var="insertPqrs">
      INSERT INTO pqrs (id_usuario, codigo_usuario, nombre_usuario, correo_usuario, rol_usuario, tipo, asunto, descripcion, estado, fecha_creacion)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'pendiente', CURRENT_TIMESTAMP)
      <sql:param value="${sessionScope.usuarioId}"/>
      <sql:param value="${solicitante.rows[0].codigo}"/>
      <sql:param value="${solicitante.rows[0].nombre}"/>
      <sql:param value="${solicitante.rows[0].correo}"/>
      <sql:param value="${solicitante.rows[0].rol}"/>
      <sql:param value="${param.tipo}"/>
      <sql:param value="${param.asunto}"/>
      <sql:param value="${param.descripcion}"/>
    </sql:update>

    <sql:query var="nuevaPqrs">
      SELECT LAST_INSERT_ID() AS id
    </sql:query>

    <sql:update>
      INSERT INTO notificaciones (tipo_evento, titulo, descripcion, id_usuario, id_referencia, tabla_referencia)
      VALUES ('pqrs_nueva', 'Nueva PQRS registrada', ?, ?, ?, 'pqrs')
      <sql:param value="PQRS de ${sessionScope.usuarioNombre}: ${param.asunto}"/>
      <sql:param value="${sessionScope.usuarioId}"/>
      <sql:param value="${nuevaPqrs.rows[0].id}"/>
    </sql:update>
  </sql:transaction>
</c:catch>

<c:choose>
  <c:when test="${not empty errorSql}">
    <%
      Throwable ex = (Throwable) pageContext.findAttribute("errorSql");
      if (ex != null) {
        application.log("Error al registrar PQRS. usuarioId=" + session.getAttribute("usuarioId")
          + " tipo=" + ex.getClass().getName()
          + " mensaje=" + ex.getMessage(), ex);
      }
    %>
    <c:redirect url="/pqrs/registro.jsp">
      <c:param name="error" value="No fue posible registrar la PQRS. Inténtalo de nuevo."/>
    </c:redirect>
  </c:when>
  <c:otherwise>
    <c:redirect url="/pqrs/registro.jsp">
      <c:param name="ok" value="PQRS registrada correctamente. Será atendida por el administrador."/>
    </c:redirect>
  </c:otherwise>
</c:choose>

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

<c:catch var="errorSql">
  <sql:update dataSource="${bd}">
    INSERT INTO pqrs (id_usuario, codigo_usuario, nombre_usuario, correo_usuario, rol_usuario, tipo, asunto, descripcion, estado, fecha_creacion)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'pendiente', CURRENT_TIMESTAMP)
    <sql:param value="${sessionScope.usuarioId}"/>
    <sql:query var="u" dataSource="${bd}">
      SELECT codigo, CONCAT(nombres,' ',apellido1,' ',IFNULL(apellido2,'')) AS nombre, correo, rol
      FROM usuarios WHERE id = ?
      <sql:param value="${sessionScope.usuarioId}"/>
    </sql:query>
  </sql:update>
</c:catch>

<c:choose>
  <c:when test="${not empty errorSql}">
    <c:redirect url="/pqrs/registro.jsp">
      <c:param name="error" value="No fue posible registrar la PQRS. Inténtalo de nuevo."/>
    </c:redirect>
  </c:when>
  <c:otherwise>
    <sql:query var="u" dataSource="${bd}">
      SELECT codigo, CONCAT(nombres,' ',apellido1,' ',IFNULL(apellido2,'')) AS nombre, correo, rol
      FROM usuarios WHERE id = ?
      <sql:param value="${sessionScope.usuarioId}"/>
    </sql:query>
    <c:forEach var="usr" items="${u.rows}">
      <sql:update dataSource="${bd}">
        UPDATE pqrs SET codigo_usuario = ?, nombre_usuario = ?, correo_usuario = ?, rol_usuario = ?
        WHERE id = (SELECT MAX(id) FROM pqrs WHERE id_usuario = ?)
        <sql:param value="${usr.codigo}"/>
        <sql:param value="${usr.nombre}"/>
        <sql:param value="${usr.correo}"/>
        <sql:param value="${usr.rol}"/>
        <sql:param value="${sessionScope.usuarioId}"/>
      </sql:update>
    </c:forEach>
    <sql:query var="ultima" dataSource="${bd}">
      SELECT id FROM pqrs WHERE id_usuario = ? ORDER BY id DESC LIMIT 1
      <sql:param value="${sessionScope.usuarioId}"/>
    </sql:query>
    <sql:update dataSource="${bd}">
      INSERT INTO notificaciones (tipo_evento, titulo, descripcion, id_usuario, id_referencia, tabla_referencia)
      VALUES ('pqrs_nueva', 'Nueva PQRS registrada', ?, ?, ?, 'pqrs')
      <sql:param value="PQRS de ${sessionScope.usuarioNombre}: ${param.asunto}"/>
      <sql:param value="${sessionScope.usuarioId}"/>
      <sql:param value="${ultima.rows[0].id}"/>
    </sql:update>
    <c:redirect url="/pqrs/registro.jsp">
      <c:param name="ok" value="PQRS registrada correctamente. Será atendida por el administrador."/>
    </c:redirect>
  </c:otherwise>
</c:choose>

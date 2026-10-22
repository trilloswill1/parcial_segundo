<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="administrador"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>

<%-- Validaciones de campos obligatorios --%>
<c:if test="${empty param.codigo || empty param.nombres || empty param.apellido1 || empty param.correo || empty param.rol}">
  <c:redirect url="/admin/usuario_form.jsp">
    <c:if test="${not empty param.id}"><c:param name="id" value="${param.id}"/></c:if>
    <c:param name="error" value="Todos los campos obligatorios deben estar diligenciados"/>
  </c:redirect>
</c:if>

<%-- En modo nuevo la contraseña es obligatoria --%>
<c:if test="${empty param.id && empty param.clave}">
  <c:redirect url="/admin/usuario_form.jsp">
    <c:param name="error" value="La contraseña es obligatoria para un usuario nuevo"/>
  </c:redirect>
</c:if>

<%-- El correo debe contener @ --%>
<c:if test="${!fn:contains(param.correo, '@')}">
  <c:redirect url="/admin/usuario_form.jsp">
    <c:if test="${not empty param.id}"><c:param name="id" value="${param.id}"/></c:if>
    <c:param name="error" value="El correo ingresado no es válido"/>
  </c:redirect>
</c:if>

<%-- La contraseña (si viene) debe tener mínimo 8 caracteres --%>
<c:if test="${not empty param.clave && fn:length(param.clave) < 8}">
  <c:redirect url="/admin/usuario_form.jsp">
    <c:if test="${not empty param.id}"><c:param name="id" value="${param.id}"/></c:if>
    <c:param name="error" value="La contraseña debe tener mínimo 8 caracteres"/>
  </c:redirect>
</c:if>

<%-- El administrador en sesión no puede desactivarse ni quitarse su propio rol --%>
<c:if test="${param.id == sessionScope.usuarioId && (param.estado == 'inactivo' || param.rol != 'administrador')}">
  <c:redirect url="/admin/usuario_form.jsp">
    <c:param name="id" value="${param.id}"/>
    <c:param name="error" value="No puedes desactivar tu cuenta ni cambiar tu propio rol"/>
  </c:redirect>
</c:if>

<%-- Operación de insert o update dentro de c:catch para detectar código/correo duplicados --%>
<c:catch var="errorSql">
  <c:choose>
    <c:when test="${not empty param.id}">
      <c:choose>
        <%-- Si la contraseña viene vacía no se toca la columna --%>
        <c:when test="${empty param.clave}">
          <sql:update dataSource="${bd}">
            UPDATE usuarios
            SET codigo = ?, nombres = ?, apellido1 = ?, apellido2 = ?,
                correo = ?, rol = ?, estado = ?
            WHERE id = ?
            <sql:param value="${param.codigo}"/>
            <sql:param value="${param.nombres}"/>
            <sql:param value="${param.apellido1}"/>
            <sql:param value="${param.apellido2}"/>
            <sql:param value="${param.correo}"/>
            <sql:param value="${param.rol}"/>
            <sql:param value="${param.estado}"/>
            <sql:param value="${param.id}"/>
          </sql:update>
        </c:when>
        <c:otherwise>
          <sql:update dataSource="${bd}">
            UPDATE usuarios
            SET codigo = ?, nombres = ?, apellido1 = ?, apellido2 = ?,
                correo = ?, rol = ?, estado = ?, clave = SHA2(?,256)
            WHERE id = ?
            <sql:param value="${param.codigo}"/>
            <sql:param value="${param.nombres}"/>
            <sql:param value="${param.apellido1}"/>
            <sql:param value="${param.apellido2}"/>
            <sql:param value="${param.correo}"/>
            <sql:param value="${param.rol}"/>
            <sql:param value="${param.estado}"/>
            <sql:param value="${param.clave}"/>
            <sql:param value="${param.id}"/>
          </sql:update>
        </c:otherwise>
      </c:choose>
    </c:when>
    <c:otherwise>
      <sql:update dataSource="${bd}">
        INSERT INTO usuarios (codigo, nombres, apellido1, apellido2, correo, clave, rol, estado, fecha_registro)
        VALUES (?, ?, ?, ?, ?, SHA2(?,256), ?, ?, CURDATE())
        <sql:param value="${param.codigo}"/>
        <sql:param value="${param.nombres}"/>
        <sql:param value="${param.apellido1}"/>
        <sql:param value="${param.apellido2}"/>
        <sql:param value="${param.correo}"/>
        <sql:param value="${param.clave}"/>
        <sql:param value="${param.rol}"/>
        <sql:param value="${param.estado}"/>
      </sql:update>
    </c:otherwise>
  </c:choose>
</c:catch>

<c:choose>
  <c:when test="${not empty errorSql}">
    <%-- Clave única duplicada: código o correo ya registrados --%>
    <c:redirect url="/admin/usuario_form.jsp">
      <c:if test="${not empty param.id}"><c:param name="id" value="${param.id}"/></c:if>
      <c:param name="error" value="El código o el correo ya están registrados"/>
    </c:redirect>
  </c:when>
  <c:otherwise>
    <%-- Notificación de usuario nuevo --%>
    <c:if test="${empty param.id}">
      <sql:query var="nuevoUsuario" dataSource="${bd}">
        SELECT LAST_INSERT_ID() AS id FROM usuarios LIMIT 1
      </sql:query>
      <sql:update dataSource="${bd}">
        INSERT INTO notificaciones (tipo_evento, titulo, descripcion, id_usuario, id_referencia, tabla_referencia)
        VALUES ('usuario_nuevo', 'Nuevo usuario registrado', ?, ?, ?, 'usuarios')
        <sql:param value="Se registró ${param.nombres} ${param.apellido1} como ${param.rol}"/>
        <sql:param value="${nuevoUsuario.rows[0].id}"/>
        <sql:param value="${nuevoUsuario.rows[0].id}"/>
      </sql:update>
    </c:if>
    <c:redirect url="/admin/usuarios.jsp">
      <c:param name="ok" value="Usuario guardado correctamente"/>
    </c:redirect>
  </c:otherwise>
</c:choose>
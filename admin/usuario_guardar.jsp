<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="administrador"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>

<%--
  Página de acción: valida, guarda el usuario (y su notificación) y redirige.
  No genera salida HTML.

  Puntos clave de esta corrección:

  * c:redirect solo envía la cabecera 302 y NO detiene la ejecución del JSP.
    Por eso, después de cada redirección se corta la página con un "return"
    en un scriptlet. Sin ese corte, la página seguía insertando el usuario
    después de redirigir por una validación.

  * El INSERT en usuarios y el INSERT en notificaciones van dentro del mismo
    <sql:transaction>, de modo que JSTL reutiliza una única conexión JDBC.
    MySQL guarda LAST_INSERT_ID() por conexión: al consultarlo dentro de la
    misma transacción devuelve el id real del usuario recién insertado (antes
    se consultaba en otra conexión y devolvía 0, lo que provocaba el fallo de
    la clave foránea fk_notif_usuario).

  * Si la notificación falla, la transacción se revierte y no queda el
    usuario registrado a medias.
--%>

<%-- Sin sesión de administrador no se toca la base de datos (seguridad.jspf ya redirigió) --%>
<% if (session.getAttribute("usuarioId") == null
       || !"administrador".equals(session.getAttribute("usuarioRol"))) { return; } %>

<%-- La acción solo responde a POST: un GET o un reenvío no registran usuarios --%>
<%
  if (!"POST".equalsIgnoreCase(request.getMethod())) {
    response.sendRedirect(request.getContextPath() + "/admin/usuario_form.jsp");
    return;
  }
%>

<%-- ------------------------------------------------------------------
     Validaciones de campos obligatorios (se conservan los mensajes)
     ------------------------------------------------------------------ --%>
<c:set var="errorValidacion" value=""/>
<c:if test="${empty param.codigo || empty param.nombres || empty param.apellido1 || empty param.correo || empty param.rol}">
  <c:set var="errorValidacion" value="Todos los campos obligatorios deben estar diligenciados"/>
</c:if>

<%-- En modo nuevo la contraseña es obligatoria --%>
<c:if test="${empty errorValidacion && empty param.id && empty param.clave}">
  <c:set var="errorValidacion" value="La contraseña es obligatoria para un usuario nuevo"/>
</c:if>

<%-- El correo debe contener @ --%>
<c:if test="${empty errorValidacion && !fn:contains(param.correo, '@')}">
  <c:set var="errorValidacion" value="El correo ingresado no es válido"/>
</c:if>

<%-- La contraseña (si viene) debe tener mínimo 8 caracteres --%>
<c:if test="${empty errorValidacion && not empty param.clave && fn:length(param.clave) < 8}">
  <c:set var="errorValidacion" value="La contraseña debe tener mínimo 8 caracteres"/>
</c:if>

<%-- El administrador en sesión no puede desactivarse ni quitarse su propio rol --%>
<c:if test="${empty errorValidacion && param.id == sessionScope.usuarioId && (param.estado == 'inactivo' || param.rol != 'administrador')}">
  <c:set var="errorValidacion" value="No puedes desactivar tu cuenta ni cambiar tu propio rol"/>
</c:if>

<c:set var="hayErrorValidacion" value="${not empty errorValidacion}"/>
<c:if test="${hayErrorValidacion}">
  <c:redirect url="/admin/usuario_form.jsp">
    <c:if test="${not empty param.id}"><c:param name="id" value="${param.id}"/></c:if>
    <c:param name="error" value="${errorValidacion}"/>
  </c:redirect>
</c:if>
<%-- c:redirect no corta el JSP: este return evita que se guarde el usuario --%>
<% if (Boolean.TRUE.equals(pageContext.getAttribute("hayErrorValidacion"))) { return; } %>

<%-- ------------------------------------------------------------------
     Protección contra el reenvío del formulario (doble clic, F5 sobre el
     POST o el aviso "reenviar formulario" del navegador): si esta misma
     carga ya se guardó hace poco, no se vuelve a insertar.
     ------------------------------------------------------------------ --%>
<% pageContext.setAttribute("momentoActual", Long.valueOf(new java.util.Date().getTime())); %>
<c:set var="huellaRegistro" value="${param.codigo}|${param.correo}|${param.rol}"/>
<c:set var="esReenvio" value="${empty param.id && not empty sessionScope.ultimoUsuarioGuardado && sessionScope.ultimoUsuarioGuardado == huellaRegistro && sessionScope.ultimoUsuarioGuardadoTs + 120000 > momentoActual}"/>
<c:if test="${esReenvio}">
  <c:redirect url="/admin/usuarios.jsp">
    <c:param name="ok" value="Usuario guardado correctamente"/>
  </c:redirect>
</c:if>
<% if (Boolean.TRUE.equals(pageContext.getAttribute("esReenvio"))) { return; } %>

<%-- ------------------------------------------------------------------
     Guardado: usuario + notificación en una sola transacción.
     Los tags SQL internos NO llevan dataSource: toman la conexión de la
     transacción (JSTL lanza un error si se anida otro dataSource).
     ------------------------------------------------------------------ --%>
<c:catch var="errorSql">
  <sql:transaction dataSource="${bd}">
    <c:choose>
      <c:when test="${not empty param.id}">
        <%-- Edición: no se crea notificación --%>
        <c:choose>
          <%-- Si la contraseña viene vacía no se toca la columna --%>
          <c:when test="${empty param.clave}">
            <sql:update>
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
            <sql:update>
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
        <%-- Alta: se inserta el usuario y se notifica con su id real --%>
        <sql:update>
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

        <%--
          LAST_INSERT_ID() es un valor de sesión de MySQL: solo es válido en la
          conexión que ejecutó el INSERT. Como todo el bloque está dentro de
          <sql:transaction>, JSTL reutiliza la misma conexión JDBC y el id
          corresponde al usuario recién insertado.
          (No se usa SELECT MAX(id): no es fiable con registros concurrentes.)
        --%>
        <sql:query var="rsIdNuevoUsuario">
          SELECT CAST(LAST_INSERT_ID() AS SIGNED) AS id
        </sql:query>
        <c:set var="idNuevoUsuario" value="${rsIdNuevoUsuario.rows[0].id}"/>

        <%-- Respaldo: el código es único; si no llegó el id, se busca por él --%>
        <c:if test="${empty idNuevoUsuario || idNuevoUsuario == 0}">
          <sql:query var="rsIdRespaldo">
            SELECT id FROM usuarios WHERE codigo = ?
            <sql:param value="${param.codigo}"/>
          </sql:query>
          <c:if test="${rsIdRespaldo.rowCount > 0}">
            <c:set var="idNuevoUsuario" value="${rsIdRespaldo.rows[0].id}"/>
          </c:if>
        </c:if>

        <%-- Sin id no se puede crear la notificación: se aborta para revertir todo --%>
        <%
          Object idNuevo = pageContext.getAttribute("idNuevoUsuario");
          if (idNuevo == null || "0".equals(String.valueOf(idNuevo))) {
            throw new javax.servlet.ServletException(
                "No se pudo determinar el id del usuario recién insertado; se revierte el registro");
          }
        %>

        <sql:update>
          INSERT INTO notificaciones (tipo_evento, titulo, descripcion, id_usuario, id_referencia, tabla_referencia)
          VALUES ('usuario_nuevo', 'Nuevo usuario registrado', ?, ?, ?, 'usuarios')
          <sql:param value="Se registró ${param.nombres} ${param.apellido1} como ${param.rol}"/>
          <sql:param value="${idNuevoUsuario}"/>
          <sql:param value="${idNuevoUsuario}"/>
        </sql:update>
      </c:otherwise>
    </c:choose>
  </sql:transaction>
</c:catch>

<%-- ------------------------------------------------------------------
     Resultado: si hubo error se registra el detalle técnico en el log de
     Tomcat y se avisa al usuario con un mensaje amigable.
     ------------------------------------------------------------------ --%>
<c:set var="mensajeError" value=""/>
<c:if test="${not empty errorSql}">
  <c:choose>
    <c:when test="${fn:contains(errorSql.message, 'Duplicate entry')}">
      <c:set var="mensajeError" value="El código o el correo ya están registrados"/>
    </c:when>
    <c:otherwise>
      <c:set var="mensajeError" value="No se pudo guardar el usuario, por favor inténtalo de nuevo"/>
    </c:otherwise>
  </c:choose>
</c:if>

<%-- El detalle técnico va únicamente al log de Tomcat; nunca se muestra al usuario --%>
<%
  Throwable errorGuardado = (Throwable) pageContext.findAttribute("errorSql");
  if (errorGuardado != null) {
    java.util.logging.Logger.getLogger("Parcial_segundo.usuario_guardar").log(
        java.util.logging.Level.SEVERE,
        "No se pudo guardar el usuario (codigo=" + request.getParameter("codigo")
            + ", rol=" + request.getParameter("rol") + "): " + errorGuardado.getMessage(),
        errorGuardado);
  }
%>

<c:set var="hayErrorGuardado" value="${not empty mensajeError}"/>
<c:if test="${hayErrorGuardado}">
  <c:redirect url="/admin/usuario_form.jsp">
    <c:if test="${not empty param.id}"><c:param name="id" value="${param.id}"/></c:if>
    <c:param name="error" value="${mensajeError}"/>
  </c:redirect>
</c:if>
<% if (Boolean.TRUE.equals(pageContext.getAttribute("hayErrorGuardado"))) { return; } %>

<%-- ------------------------------------------------------------------
     Éxito: se marca la última carga y se redirige (POST/Redirect/GET) para
     que recargar la página no repita el registro.
     ------------------------------------------------------------------ --%>
<%
  String idEditado = request.getParameter("id");
  if (idEditado == null || idEditado.isEmpty()) {
    session.setAttribute("ultimoUsuarioGuardado",
        request.getParameter("codigo") + "|" + request.getParameter("correo") + "|" + request.getParameter("rol"));
    session.setAttribute("ultimoUsuarioGuardadoTs", Long.valueOf(new java.util.Date().getTime()));
  }
%>
<c:redirect url="/admin/usuarios.jsp">
  <c:param name="ok" value="Usuario guardado correctamente"/>
</c:redirect>

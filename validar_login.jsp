<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>

<%-- Valida que los campos no vengan vacíos --%>
<c:if test="${empty param.correo || empty param.clave}">
  <c:redirect url="/index.jsp">
    <c:param name="error" value="Debes ingresar tu correo y tu contraseña"/>
  </c:redirect>
</c:if>

<%-- Busco el usuario con clave hasheada --%>
<sql:query var="rs" dataSource="${bd}">
  SELECT id, codigo, nombres, apellido1, rol
  FROM usuarios
  WHERE correo = ? AND clave = SHA2(?,256) AND estado = 'activo'
  <sql:param value="${param.correo}"/>
  <sql:param value="${param.clave}"/>
</sql:query>

<c:choose>
  <c:when test="${rs.rowCount == 0}">
    <c:redirect url="/index.jsp">
      <c:param name="error" value="Correo o contraseña incorrectos"/>
    </c:redirect>
  </c:when>
  <c:otherwise>
    <%-- Guardo los datos del usuario en la sesión --%>
    <c:forEach var="u" items="${rs.rows}">
      <c:set scope="session" var="usuarioId" value="${u.id}"/>
      <c:set scope="session" var="usuarioCodigo" value="${u.codigo}"/>
      <c:set scope="session" var="usuarioNombre" value="${u.nombres} ${u.apellido1}"/>
      <c:set scope="session" var="usuarioRol" value="${u.rol}"/>

      <%-- Lo envío al panel de su rol --%>
      <c:choose>
        <c:when test="${u.rol == 'administrador'}"><c:redirect url="/admin/panel.jsp"/></c:when>
        <c:when test="${u.rol == 'coordinacion'}"><c:redirect url="/coordinacion/panel.jsp"/></c:when>
        <c:when test="${u.rol == 'director'}"><c:redirect url="/director/panel.jsp"/></c:when>
        <c:when test="${u.rol == 'evaluador'}"><c:redirect url="/evaluador/panel.jsp"/></c:when>
        <c:otherwise><c:redirect url="/estudiante/panel.jsp"/></c:otherwise>
      </c:choose>
    </c:forEach>
  </c:otherwise>
</c:choose>

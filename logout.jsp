<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>

<%-- Borro las variables de sesión y regreso al login --%>
<c:remove var="usuarioId" scope="session"/>
<c:remove var="usuarioCodigo" scope="session"/>
<c:remove var="usuarioNombre" scope="session"/>
<c:remove var="usuarioRol" scope="session"/>

<c:redirect url="/index.jsp">
  <c:param name="ok" value="Sesión cerrada correctamente"/>
</c:redirect>

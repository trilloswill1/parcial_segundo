<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="cualquiera"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="PQRS"/>
<c:set var="menuActivo"   value="pqrs"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<c:if test="${empty sessionScope.usuarioId}">
  <c:redirect url="/index.jsp"/>
</c:if>

<c:choose>
  <c:when test="${sessionScope.usuarioRol == 'administrador'}">
    <c:redirect url="/pqrs/lista.jsp"/>
  </c:when>
  <c:otherwise>
    <c:redirect url="/pqrs/registro.jsp"/>
  </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>

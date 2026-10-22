<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="evaluador"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>

<c:if test="${empty param.id}">
  <c:redirect url="/evaluador/entregas_finales.jsp">
    <c:param name="error" value="No se indicó qué entrega revisar"/>
  </c:redirect>
</c:if>

<%-- Traducción del código de estado (sin acentos) al valor real del ENUM --%>
<c:set var="estadoDb" value=""/>
<c:choose>
  <c:when test="${param.estado == 'Entregado'}"><c:set var="estadoDb" value="Entregado"/></c:when>
  <c:when test="${param.estado == 'revision'}"><c:set var="estadoDb" value="En revisión"/></c:when>
  <c:when test="${param.estado == 'Aprobado'}"><c:set var="estadoDb" value="Aprobado"/></c:when>
  <c:when test="${param.estado == 'Rechazado'}"><c:set var="estadoDb" value="Rechazado"/></c:when>
</c:choose>

<c:if test="${empty estadoDb}">
  <c:redirect url="/evaluador/entrega_revisar.jsp">
    <c:param name="id" value="${param.id}"/>
    <c:param name="error" value="Estado no válido"/>
  </c:redirect>
</c:if>

<%-- La entrega debe existir y estar asignada a este evaluador --%>
<sql:query var="info" dataSource="${bd}">
  SELECT ef.id, ef.id_estudiante, ef.id_anteproyecto, a.id_evaluador
  FROM entrega_final ef
  JOIN anteproyectos a ON a.id = ef.id_anteproyecto
  WHERE ef.id = ? AND a.id_evaluador = ?
  <sql:param value="${param.id}"/>
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>

<c:if test="${info.rowCount == 0}">
  <c:redirect url="/evaluador/entregas_finales.jsp">
    <c:param name="error" value="La entrega no existe o no está asignada a ti"/>
  </c:redirect>
</c:if>

<c:set var="entregaId"    value="${info.rows[0].id}"/>
<c:set var="idEstudiante" value="${info.rows[0].id_estudiante}"/>
<c:set var="idAnteproyecto" value="${info.rows[0].id_anteproyecto}"/>

<c:catch var="errorSql">
  <sql:update var="filas" dataSource="${bd}">
    UPDATE entrega_final SET estado = ?, observaciones = ?
    WHERE id = ?
    <sql:param value="${estadoDb}"/>
    <sql:param value="${param.observaciones}"/>
    <sql:param value="${entregaId}"/>
  </sql:update>
</c:catch>

<c:choose>
  <c:when test="${not empty errorSql}">
    <c:redirect url="/evaluador/entrega_revisar.jsp">
      <c:param name="id" value="${entregaId}"/>
      <c:param name="error" value="No fue posible guardar la revisión"/>
    </c:redirect>
  </c:when>
  <c:otherwise>
    <%-- Notificación al estudiante según el nuevo estado --%>
    <c:set var="tituloNotif" value="Tu entrega final fue actualizada"/>
    <c:choose>
      <c:when test="${estadoDb == 'Aprobado'}"><c:set var="tituloNotif" value="Tu entrega final fue aprobada"/></c:when>
      <c:when test="${estadoDb == 'Rechazado'}"><c:set var="tituloNotif" value="Tu entrega final fue rechazada"/></c:when>
      <c:when test="${estadoDb == 'En revisión'}"><c:set var="tituloNotif" value="Tu entrega final está en revisión"/></c:when>
    </c:choose>

    <c:set var="descNotif">
      Estado de tu entrega final (revisión del evaluador): ${estadoDb}.
      <c:if test="${not empty param.observaciones}"> Observaciones: ${param.observaciones}</c:if>
    </c:set>

    <sql:update dataSource="${bd}">
      INSERT INTO notificaciones (tipo_evento, titulo, descripcion, id_usuario, id_referencia, tabla_referencia)
      VALUES ('entrega_final', ?, ?, ?, ?, 'entrega_final')
      <sql:param value="${tituloNotif}"/>
      <sql:param value="${descNotif}"/>
      <sql:param value="${idEstudiante}"/>
      <sql:param value="${entregaId}"/>
    </sql:update>

    <%-- Notificación a coordinación --%>
    <sql:update dataSource="${bd}">
      INSERT INTO notificaciones (tipo_evento, titulo, descripcion, id_usuario, id_referencia, tabla_referencia)
      VALUES ('entrega_final', 'Entrega final revisada por evaluador', ?, ?, ?, 'entrega_final')
      <sql:param value="El evaluador cambió el estado de la entrega final a ${estadoDb}."/>
      <sql:param value="2"/>
      <sql:param value="${entregaId}"/>
    </sql:update>

    <c:redirect url="/evaluador/entrega_revisar.jsp">
      <c:param name="id" value="${entregaId}"/>
      <c:param name="ok" value="Revisión guardada correctamente"/>
    </c:redirect>
  </c:otherwise>
</c:choose>

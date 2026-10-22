<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="cualquiera"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Calendario Académico"/>
<c:set var="menuActivo"   value="calendario"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<%-- Eventos ordenados por fecha; el estado (pasado/en curso/próximo) se calcula en el SQL con CURDATE() --%>
<sql:query var="eventos" dataSource="${bd}">
  SELECT id, evento, descripcion, fecha_inicio, fecha_fin,
         CASE
           WHEN CURDATE() > COALESCE(fecha_fin, fecha_inicio) THEN 'pasado'
           WHEN CURDATE() < fecha_inicio THEN 'proximo'
           ELSE 'en_curso'
         END AS momento
  FROM calendario_academico
  ORDER BY fecha_inicio
</sql:query>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-calendar-alt"></i>Calendario Académico</h1>
    <p class="page-subtitle">Fechas importantes del periodo de trabajos de grado.</p>
  </div>
</div>

<div class="card-ui">
  <c:choose>
    <c:when test="${eventos.rowCount == 0}">
      <div class="empty-state">
        <i class="fas fa-calendar-times"></i>
        <h5>No hay eventos registrados</h5>
        <p>El calendario académico aún no tiene fechas publicadas.</p>
      </div>
    </c:when>
    <c:otherwise>
      <div class="linea-tiempo">
        <c:forEach var="ev" items="${eventos.rows}">

          <%-- Cada evento es una tarjeta en la línea de tiempo --%>
          <div class="evento ${ev.momento}">
            <div class="evento-tarjeta">
              <div class="evento-top">
                <div>
                  <span class="evento-fecha">
                    <c:choose>
                      <c:when test="${not empty ev.fecha_fin}">
                        <fmt:formatDate value="${ev.fecha_inicio}" pattern="dd MMM yyyy"/>
                        &ndash;
                        <fmt:formatDate value="${ev.fecha_fin}" pattern="dd MMM yyyy"/>
                      </c:when>
                      <c:otherwise>
                        <fmt:formatDate value="${ev.fecha_inicio}" pattern="dd MMM yyyy"/>
                      </c:otherwise>
                    </c:choose>
                  </span>
                  <div class="evento-titulo"><c:out value="${ev.evento}"/></div>
                  <c:if test="${not empty ev.descripcion}">
                    <p class="evento-desc"><c:out value="${ev.descripcion}"/></p>
                  </c:if>
                </div>
                <span class="badge-simple ${ev.momento == 'en_curso' ? 'activo' : (ev.momento == 'pasado' ? 'neutro' : 'inactivo')}">
                  <c:choose>
                    <c:when test="${ev.momento == 'pasado'}"><i class="fas fa-check"></i> Finalizado</c:when>
                    <c:when test="${ev.momento == 'en_curso'}"><i class="fas fa-bolt"></i> En curso</c:when>
                    <c:otherwise><i class="fas fa-clock"></i> Próximo</c:otherwise>
                  </c:choose>
                </span>
              </div>
            </div>
          </div>

        </c:forEach>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>

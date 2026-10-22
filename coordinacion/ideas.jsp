<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<c:set var="rolRequerido" value="coordinacion"/>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<c:set var="tituloPagina" value="Banco de Ideas"/>
<c:set var="menuActivo"   value="ideas"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<%-- Lista de ideas creadas por la coordinación; las tomadas no se pueden eliminar --%>
<sql:query var="rs" dataSource="${bd}">
  SELECT i.id, i.titulo, i.descripcion, i.estado, i.fecha_registro,
         CONCAT(u.nombres, ' ', u.apellido1) AS coordinador
  FROM ideas i
  LEFT JOIN usuarios u ON u.id = i.id_coordinador
  ORDER BY i.estado, i.fecha_registro DESC, i.id DESC
</sql:query>

<div class="page-header">
  <div>
    <h1 class="page-title"><i class="fas fa-lightbulb"></i>Banco de Ideas</h1>
    <p class="page-subtitle">Crea y administra las ideas que los estudiantes pueden seleccionar para su trabajo de grado.</p>
  </div>
  <div class="page-actions">
    <a class="btn-uts" href="<c:url value='/coordinacion/idea_form.jsp'/>">
      <i class="fas fa-plus"></i> Nueva idea
    </a>
  </div>
</div>

<div class="card-ui">
  <div class="card-ui-header">
    <h2 class="card-ui-titulo"><i class="fas fa-list"></i>Listado de ideas</h2>
    <span class="badge-simple neutro"><c:out value="${rs.rowCount}"/> ideas</span>
  </div>

  <c:choose>
    <c:when test="${rs.rowCount == 0}">
      <div class="empty-state">
        <i class="fas fa-lightbulb"></i>
        <h5>No hay ideas registradas</h5>
        <p>Crea la primera idea de anteproyecto para que los estudiantes la tomen.</p>
        <a class="btn-uts" href="<c:url value='/coordinacion/idea_form.jsp'/>"><i class="fas fa-plus"></i> Nueva idea</a>
      </div>
    </c:when>
    <c:otherwise>
      <div class="tabla-contenedor">
        <table class="table table-hover align-middle table-ui">
          <thead>
            <tr>
              <th>Título</th>
              <th>Registrada por</th>
              <th>Fecha</th>
              <th>Estado</th>
              <th class="text-end">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="i" items="${rs.rows}">
              <tr>
                <td>
                  <strong><c:out value="${i.titulo}"/></strong>
                  <c:if test="${not empty i.descripcion}">
                    <br><span class="texto-resumen"><c:out value="${fn:substring(i.descripcion, 0, 70)}"/>...</span>
                  </c:if>
                </td>
                <td><c:out value="${i.coordinador}"/></td>
                <td><fmt:formatDate value="${i.fecha_registro}" pattern="dd/MM/yyyy"/></td>
                <td>
                  <span class="badge-simple ${i.estado == 'disponible' ? 'activo' : 'neutro'}">
                    <c:out value="${i.estado}"/>
                  </span>
                </td>
                <td>
                  <div class="acciones-tabla">
                    <a class="btn-icono" href="<c:url value='/coordinacion/idea_form.jsp?id=${i.id}'/>" title="Editar">
                      <i class="fas fa-pen"></i>
                    </a>
                    <c:if test="${i.estado == 'disponible'}">
                      <button type="button" class="btn-icono peligro" data-bs-toggle="modal"
                              data-bs-target="#modalEliminarIdea${i.id}" title="Eliminar">
                        <i class="fas fa-trash-alt"></i>
                      </button>
                    </c:if>
                  </div>
                </td>
              </tr>

            </c:forEach>
          </tbody>
        </table>
      </div>

      <%-- Los modales de confirmación van fuera de la tabla (HTML válido) --%>
      <c:forEach var="i" items="${rs.rows}">
      <%-- Confirmación para eliminar la idea (solo si está disponible) --%>
      <c:if test="${i.estado == 'disponible'}">
        <div class="modal fade" id="modalEliminarIdea${i.id}" tabindex="-1" aria-hidden="true">
          <div class="modal-dialog">
            <div class="modal-content">
              <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-trash-alt me-2 text-danger"></i>Eliminar idea</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
              </div>
              <div class="modal-body">
                ¿Estás seguro de eliminar la idea <strong><c:out value="${i.titulo}"/></strong>?
                Esta acción no se puede deshacer.
              </div>
              <div class="modal-footer">
                <button type="button" class="btn-uts-outline gris" data-bs-dismiss="modal">
                  <i class="fas fa-times"></i> Cancelar
                </button>
                <form method="post" action="<c:url value='/coordinacion/idea_eliminar.jsp'/>">
                  <input type="hidden" name="id" value="${i.id}">
                  <button type="submit" class="btn-peligro"><i class="fas fa-trash-alt"></i> Sí, eliminar</button>
                </form>
              </div>
            </div>
          </div>
        </div>
        </c:if>
      </c:forEach>
    </c:otherwise>
  </c:choose>
</div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>

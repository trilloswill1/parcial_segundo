<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>

<%-- Si ya hay sesión iniciada, vuelvo al panel de mi rol conservando el mensaje (ej: "No tienes permiso") --%>
<c:if test="${not empty sessionScope.usuarioId}">
  <c:set var="destinoPanel" value="/estudiante/panel.jsp"/>
  <c:choose>
    <c:when test="${sessionScope.usuarioRol == 'administrador'}"><c:set var="destinoPanel" value="/admin/panel.jsp"/></c:when>
    <c:when test="${sessionScope.usuarioRol == 'coordinacion'}"><c:set var="destinoPanel" value="/coordinacion/panel.jsp"/></c:when>
    <c:when test="${sessionScope.usuarioRol == 'director'}"><c:set var="destinoPanel" value="/director/panel.jsp"/></c:when>
    <c:when test="${sessionScope.usuarioRol == 'evaluador'}"><c:set var="destinoPanel" value="/evaluador/panel.jsp"/></c:when>
  </c:choose>
  <c:redirect url="${destinoPanel}">
    <c:if test="${not empty param.error}"><c:param name="error" value="${param.error}"/></c:if>
    <c:if test="${not empty param.ok}"><c:param name="ok" value="${param.ok}"/></c:if>
  </c:redirect>
</c:if>

<%-- Pantalla de login institucional con foto de fondo --%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Iniciar sesión | Trabajos de Grado UTS</title>
  <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>🎓</text></svg>">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.1.0/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap">
  <link rel="stylesheet" href="<c:url value='/css/estilo.css'/>">
  <link rel="stylesheet" href="<c:url value='/css/login.css'/>">
</head>
<body>
<div class="lg-pantalla">

  <%-- Panel de marca (izquierda en escritorio, arriba en móvil) --%>
  <section class="lg-marca d-none d-lg-flex" aria-label="Identidad institucional">
    <div class="lg-marca-logo">
      <img src="<c:url value='/img/logo-uts.png'/>" alt="Logo Universidad Técnica del Sur">
    </div>
    <div class="lg-marca-badge">
      <span>SISTEMA DE TRABAJOS DE GRADO</span>
    </div>
    <h1>Gestión de Trabajos de Grado</h1>
    <p class="lg-marca-subtitulo">Del anteproyecto a la entrega final, en un solo lugar. Ingresa con tu cuenta institucional para continuar.</p>
    <div class="lg-marca-chips" aria-label="Características principales">
      <div class="lg-chip"><i class="fas fa-folder-open"></i> Radicación de anteproyectos</div>
      <div class="lg-chip"><i class="fas fa-clipboard-check"></i> Calificación en línea</div>
      <div class="lg-chip"><i class="fas fa-clock"></i> Seguimiento 24/7</div>
    </div>
  </section>

  <%-- Panel de marca reducido para móvil --%>
  <section class="lg-marca d-lg-none" aria-label="Identidad institucional">
    <div class="lg-marca-logo">
      <img src="<c:url value='/img/logo-uts.png'/>" alt="Logo Universidad Técnica del Sur">
    </div>
    <h1>Gestión de Trabajos de Grado</h1>
  </section>

  <%-- Tarjeta de acceso (derecha en escritorio, centrada en móvil) --%>
  <section class="lg-form-panel" aria-label="Formulario de acceso">
    <div class="lg-tarjeta">
      <div class="lg-tarjeta-icono" aria-hidden="true">
        <i class="fas fa-user-graduate"></i>
      </div>
      <h2>Accede a la plataforma</h2>
      <p class="lg-tarjeta-subtitulo">Estudiantes y docentes</p>

      <c:if test="${not empty param.error}">
        <div class="alert alert-danger d-flex align-items-center" role="alert">
          <i class="fas fa-exclamation-circle me-2"></i><c:out value="${param.error}"/>
        </div>
      </c:if>
      <c:if test="${not empty param.ok}">
        <div class="alert alert-success d-flex align-items-center" role="alert">
          <i class="fas fa-check-circle me-2"></i><c:out value="${param.ok}"/>
        </div>
      </c:if>

      <form class="form-ui" action="<c:url value='/validar_login.jsp'/>" method="post">
        <div class="form-floating mb-3">
          <input type="email" class="form-control" id="correo" name="correo"
                 placeholder="correo@uts.edu.co" autocomplete="username" required>
          <label for="correo">Correo institucional</label>
        </div>
        <div class="form-floating mb-3">
          <input type="password" class="form-control" id="clave" name="clave"
                 placeholder="Contraseña" autocomplete="current-password" required>
          <label for="clave">Contraseña</label>
        </div>
        <button type="submit" class="btn-uts lg-btn-ingresar">
          <i class="fas fa-sign-in-alt"></i> Ingresar
        </button>
      </form>
    </div>

    <%-- Ayuda colapsable: Usuarios de prueba --%>
    <details class="lg-ayuda" aria-label="Usuarios de prueba">
      <summary>
        <i class="fas fa-info-circle"></i> Usuarios de prueba
      </summary>
      <div class="lg-ayuda-panel">
        <div class="lg-ayuda-fila">
          <span class="lg-badge-rol administrador">Administrador</span>
          <div class="lg-usuario-info">
            <strong>Carlos Andrés Rojas Pérez</strong>
            <code>admin@uts.edu.co</code>
          </div>
        </div>
        <div class="lg-ayuda-fila">
          <span class="lg-badge-rol coordinacion">Coordinación</span>
          <div class="lg-usuario-info">
            <strong>Marcela Duarte Villamizar</strong>
            <code>coordinacion@uts.edu.co</code>
          </div>
        </div>
        <div class="lg-ayuda-fila">
          <span class="lg-badge-rol director">Director</span>
          <div class="lg-usuario-info">
            <strong>Jorge Enrique Camargo Silva</strong>
            <code>director1@uts.edu.co</code>
          </div>
          <div class="lg-usuario-info">
            <strong>Diana Patricia Ortiz Rueda</strong>
            <code>director2@uts.edu.co</code>
          </div>
        </div>
        <div class="lg-ayuda-fila">
          <span class="lg-badge-rol evaluador">Evaluador</span>
          <div class="lg-usuario-info">
            <strong>Hernán Darío Mejía Cala</strong>
            <code>evaluador1@uts.edu.co</code>
          </div>
          <div class="lg-usuario-info">
            <strong>Sandra Milena Quintero Ardila</strong>
            <code>evaluador2@uts.edu.co</code>
          </div>
        </div>
        <div class="lg-ayuda-fila">
          <span class="lg-badge-rol estudiante">Estudiante</span>
          <div class="lg-usuario-info">
            <strong>Laura Valentina Gómez Suárez</strong>
            <code>laura.gomez@uts.edu.co</code> <span class="lg-ayuda-estado">· aprobado</span>
          </div>
        </div>
        <div class="lg-ayuda-fila">
          <span class="lg-badge-rol estudiante">Estudiante</span>
          <div class="lg-usuario-info">
            <strong>Santiago Andrés Pardo Niño</strong>
            <code>santiago.pardo@uts.edu.co</code> <span class="lg-ayuda-estado">· radicado</span>
          </div>
        </div>
        <div class="lg-ayuda-fila">
          <span class="lg-badge-rol estudiante">Estudiante</span>
          <div class="lg-usuario-info">
            <strong>Camila Fernanda Rey Barrera</strong>
            <code>camila.rey@uts.edu.co</code> <span class="lg-ayuda-estado">· con director</span>
          </div>
        </div>
        <p class="lg-ayuda-clave">Contraseña de todos: <code>Uts2026*</code></p>
      </div>
    </details>
  </section>

</div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/2.9.2/umd/popper.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.1.0/js/bootstrap.min.js"></script>
</body>
</html>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.io.*, java.net.URLEncoder, java.sql.*, javax.servlet.ServletOutputStream, javax.sql.DataSource" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<%
String ctx = request.getContextPath();

Object uidObj = session.getAttribute("usuarioId");
String rol    = (String) session.getAttribute("usuarioRol");
if (uidObj == null || rol == null) {
  response.sendRedirect(ctx + "/index.jsp");
  return;
}
int usuarioId = Integer.parseInt(String.valueOf(uidObj));

String idParam = request.getParameter("id");
if (idParam == null || !idParam.matches("\\d+")) {
  response.sendRedirect(ctx + "/index.jsp?error=" + URLEncoder.encode("Entrega no válida", "UTF-8"));
  return;
}
int entregaId = Integer.parseInt(idParam);

DataSource ds = (DataSource) pageContext.findAttribute("bd");
Connection con = null;
String nombreArchivo = null;
String rutaArchivo = null;
boolean autorizado = false;
try {
  con = ds.getConnection();
  PreparedStatement ps = con.prepareStatement(
      "SELECT ef.nombre_archivo, ef.ruta_archivo, ef.id_estudiante, a.id_director, a.id_evaluador "
    + "FROM entrega_final ef JOIN anteproyectos a ON a.id = ef.id_anteproyecto WHERE ef.id = ?");
  ps.setInt(1, entregaId);
  ResultSet rs = ps.executeQuery();
  if (rs.next()) {
    nombreArchivo = rs.getString("nombre_archivo");
    rutaArchivo   = rs.getString("ruta_archivo");
    int idEstudiante = rs.getInt("id_estudiante");
    int idDirector   = rs.getInt("id_director");
    int idEvaluador  = rs.getInt("id_evaluador");
    boolean esDocente = (idDirector != 0 && usuarioId == idDirector) || (idEvaluador != 0 && usuarioId == idEvaluador);
    boolean esStaff   = "coordinacion".equals(rol) || "administrador".equals(rol);
    autorizado = (usuarioId == idEstudiante) || esDocente || esStaff;
  }
  rs.close(); ps.close();
} catch (Exception ex) {
  autorizado = false;
} finally {
  if (con != null) { try { con.close(); } catch (SQLException ignore) {} }
}

if (nombreArchivo == null || rutaArchivo == null || !autorizado) {
  response.sendRedirect(ctx + "/index.jsp?error=" + URLEncoder.encode("No tienes permiso para descargar este documento", "UTF-8"));
  return;
}

// --- Resolución segura de la ruta del archivo ---
String baseReal = application.getRealPath("/WEB-INF/documentos/entregas");
File baseDir = new File(baseReal);
File archivo = new File(application.getRealPath("/" + rutaArchivo));
boolean seguro = archivo.getCanonicalPath().startsWith(baseDir.getCanonicalPath());

if (!seguro || !archivo.exists() || !archivo.isFile()) {
  response.sendRedirect(ctx + "/index.jsp?error=" + URLEncoder.encode("El archivo ya no está disponible", "UTF-8"));
  return;
}

// --- Envío del PDF ---
response.reset();
response.setContentType("application/pdf");
response.setHeader("Content-Disposition", "inline; filename=\"" + nombreArchivo.replace("\"", "") + "\"");
response.setContentLengthLong(archivo.length());
BufferedInputStream in = new BufferedInputStream(new FileInputStream(archivo));
ServletOutputStream outStream = response.getOutputStream();
byte[] buf = new byte[8192];
int n;
try {
  while ((n = in.read(buf)) != -1) outStream.write(buf, 0, n);
} finally {
  in.close();
  outStream.flush();
}
%>

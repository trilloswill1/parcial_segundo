<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.io.*, java.net.URLEncoder, java.sql.*, java.util.*, javax.sql.DataSource" %>
<%@ include file="/WEB-INF/jspf/inicio.jspf" %>
<%!
// Búsqueda de un patrón de bytes dentro de un arreglo (para parsear multipart/form-data)
private static int indexOf(byte[] data, byte[] pattern, int from) {
  if (pattern.length == 0) return from;
  outer:
  for (int i = Math.max(0, from); i <= data.length - pattern.length; i++) {
    for (int j = 0; j < pattern.length; j++) {
      if (data[i + j] != pattern[j]) continue outer;
    }
    return i;
  }
  return -1;
}

private static String headerValue(String headers, String key) {
  String[] lines = headers.split("\r\n");
  for (String line : lines) {
    int idx = line.indexOf(':');
    if (idx > 0 && line.substring(0, idx).trim().equalsIgnoreCase(key)) {
      return line.substring(idx + 1).trim();
    }
  }
  return null;
}

// Extrae el parámetro (name o filename) de la cabecera Content-Disposition y limpia rutas
private static String dispositionParam(String headers, String param) {
  String disp = headerValue(headers, "Content-Disposition");
  if (disp == null) return null;
  String needle = param + "=\"";
  int i = disp.indexOf(needle);
  if (i < 0) return null;
  int start = i + needle.length();
  int end = disp.indexOf('"', start);
  if (end < 0) return null;
  String val = disp.substring(start, end).replace("\\", "/");
  int slash = val.lastIndexOf('/');
  if (slash >= 0) val = val.substring(slash + 1);
  return val.trim();
}
%>
<%
String ctx     = request.getContextPath();
String baseUrl = ctx + "/estudiante/entrega_final.jsp";
String destino = ctx + "/index.jsp";

// --- Autenticación y autorización en el servidor ---
Object uidObj = session.getAttribute("usuarioId");
String rol    = (String) session.getAttribute("usuarioRol");
if (uidObj == null || rol == null) {
  response.sendRedirect(destino);
  return;
}
if (!"estudiante".equals(rol)) {
  response.sendRedirect(destino + "?error=" + URLEncoder.encode("No tienes permiso para esta sección", "UTF-8"));
  return;
}
int usuarioId = Integer.parseInt(String.valueOf(uidObj));

String error = null;
String contentType = request.getContentType();
if (contentType == null || !contentType.toLowerCase().startsWith("multipart/form-data")) {
  response.sendRedirect(baseUrl + "?error=" + URLEncoder.encode("Envío no válido: se esperaba un formulario con archivo", "UTF-8"));
  return;
}

final long MAX_SIZE = 10L * 1024 * 1024; // 10 MB

// --- Lectura del cuerpo de la petición (con tope de tamaño) ---
ByteArrayOutputStream bos = new ByteArrayOutputStream();
InputStream is = request.getInputStream();
byte[] buffer = new byte[8192];
int leidos;
long total = 0;
while ((leidos = is.read(buffer)) != -1) {
  total += leidos;
  if (total > MAX_SIZE + 1024 * 1024) {
    response.sendRedirect(baseUrl + "?error=" + URLEncoder.encode("El archivo supera el límite permitido de 10 MB", "UTF-8"));
    return;
  }
  bos.write(buffer, 0, leidos);
}
byte[] body = bos.toByteArray();

// --- Separador (boundary) ---
String boundary = contentType.substring(contentType.indexOf("boundary=") + 9).trim();
if (boundary.startsWith("\"") && boundary.endsWith("\"") && boundary.length() > 1) {
  boundary = boundary.substring(1, boundary.length() - 1);
}
byte[] delim = ("--" + boundary).getBytes("ISO-8859-1");

// --- Parseo de las partes ---
Map<String, String> campos = new HashMap<String, String>();
String nombreOriginal = null;
byte[] archivoBytes = null;

int pos = indexOf(body, delim, 0);
while (pos >= 0) {
  int partStart = pos + delim.length;
  if (partStart + 1 < body.length && body[partStart] == '-' && body[partStart + 1] == '-') {
    break; // fin del cuerpo
  }
  if (partStart + 1 < body.length && body[partStart] == 13 && body[partStart + 1] == 10) {
    partStart += 2;
  }
  int next = indexOf(body, delim, partStart);
  if (next < 0) break;

  byte[] sep = {13, 10, 13, 10};
  int headerEnd = indexOf(body, sep, partStart);
  if (headerEnd < 0 || headerEnd > next) { pos = next; continue; }

  String headers = new String(body, partStart, headerEnd - partStart, "ISO-8859-1");
  int bodyStart = headerEnd + 4;
  int bodyEnd = next;
  if (bodyEnd - 2 >= bodyStart && body[bodyEnd - 2] == 13 && body[bodyEnd - 1] == 10) {
    bodyEnd -= 2; // quita el CRLF previo al delimitador
  }

  String name = dispositionParam(headers, "name");
  String filename = dispositionParam(headers, "filename");
  if (filename != null && filename.length() > 0 && name != null && name.equals("documento")) {
    nombreOriginal = filename;
    archivoBytes = Arrays.copyOfRange(body, bodyStart, bodyEnd);
  } else if (name != null) {
    campos.put(name, new String(body, bodyStart, bodyEnd - bodyStart, "UTF-8"));
  }
  pos = next;
}

// --- Validación del archivo ---
if (archivoBytes == null || archivoBytes.length == 0) {
  error = "Debes seleccionar un archivo PDF";
} else if (archivoBytes.length > MAX_SIZE) {
  error = "El archivo supera el límite permitido de 10 MB";
} else if (nombreOriginal == null || !nombreOriginal.toLowerCase().endsWith(".pdf")) {
  error = "Solo se permiten archivos con extensión .pdf";
} else if (!(archivoBytes.length >= 5
        && archivoBytes[0] == 0x25 && archivoBytes[1] == 0x50
        && archivoBytes[2] == 0x44 && archivoBytes[3] == 0x46
        && archivoBytes[4] == 0x2D)) {
  error = "El archivo no es un PDF válido";
}
if (error != null) {
  response.sendRedirect(baseUrl + "?error=" + URLEncoder.encode(error, "UTF-8"));
  return;
}

// --- Acceso a base de datos reutilizando el DataSource de inicio.jspf ---
DataSource ds = (DataSource) pageContext.findAttribute("bd");
Connection con = null;
File archivoGuardado = null;
try {
  con = ds.getConnection();

  // El anteproyecto se obtiene del usuario autenticado (no del formulario)
  int anteId = -1;
  String anteEstado = null;
  PreparedStatement ps = con.prepareStatement("SELECT id, estado FROM anteproyectos WHERE id_estudiante = ?");
  ps.setInt(1, usuarioId);
  ResultSet rs = ps.executeQuery();
  if (rs.next()) { anteId = rs.getInt("id"); anteEstado = rs.getString("estado"); }
  rs.close(); ps.close();

  if (anteId < 0) {
    error = "No tienes un anteproyecto registrado";
  } else if (!"aprobado".equals(anteEstado)) {
    error = "Tu anteproyecto aún no está aprobado para la entrega final";
  } else {
    // Evita registros duplicados (se permite nueva versión si la última fue rechazada)
    ps = con.prepareStatement("SELECT COUNT(*) FROM entrega_final WHERE id_anteproyecto = ? AND estado <> 'Rechazado'");
    ps.setInt(1, anteId);
    rs = ps.executeQuery();
    rs.next();
    int existentes = rs.getInt(1);
    rs.close(); ps.close();
    if (existentes > 0) error = "Ya tienes una entrega final registrada para este anteproyecto";
  }

  if (error == null) {
    // --- Guardado físico del archivo (nombre seguro, fuera de acceso directo) ---
    String relDir = "WEB-INF/documentos/entregas";
    String realDir = application.getRealPath("/" + relDir);
    File dir = new File(realDir == null ? relDir : realDir);
    if (!dir.exists()) dir.mkdirs();

    String guardado = "entrega_" + anteId + "_" + new java.util.Date().getTime() + "_"
        + UUID.randomUUID().toString().replace("-", "") + ".pdf";
    archivoGuardado = new File(dir, guardado);
    FileOutputStream fos = new FileOutputStream(archivoGuardado);
    try { fos.write(archivoBytes); } finally { fos.close(); }

    String rutaRel = relDir + "/" + guardado;
    String nombre = nombreOriginal.length() > 255 ? nombreOriginal.substring(0, 255) : nombreOriginal;

    // --- Registro en MySQL ---
    ps = con.prepareStatement(
        "INSERT INTO entrega_final (id_anteproyecto, id_estudiante, nombre_archivo, ruta_archivo, estado) "
      + "VALUES (?, ?, ?, ?, 'Entregado')", Statement.RETURN_GENERATED_KEYS);
    ps.setInt(1, anteId);
    ps.setInt(2, usuarioId);
    ps.setString(3, nombre);
    ps.setString(4, rutaRel);
    ps.executeUpdate();
    rs = ps.getGeneratedKeys();
    int entregaId = rs.next() ? rs.getInt(1) : -1;
    rs.close(); ps.close();

    // --- Notificación a coordinación ---
    String nombreEst = String.valueOf(session.getAttribute("usuarioNombre"));
    PreparedStatement pn = con.prepareStatement(
        "INSERT INTO notificaciones (tipo_evento, titulo, descripcion, id_usuario, id_referencia, tabla_referencia) "
      + "VALUES ('entrega_final', 'Nueva entrega final recibida', ?, ?, ?, 'entrega_final')");
    ps = con.prepareStatement("SELECT id FROM usuarios WHERE rol = 'coordinacion' AND estado = 'activo'");
    rs = ps.executeQuery();
    List<Integer> coordinadores = new ArrayList<Integer>();
    while (rs.next()) coordinadores.add(Integer.valueOf(rs.getInt(1)));
    rs.close(); ps.close();
    for (Integer cid : coordinadores) {
      pn.setString(1, "El estudiante " + nombreEst + " radicó su documento final para revisión.");
      pn.setInt(2, cid.intValue());
      pn.setInt(3, entregaId);
      pn.addBatch();
    }
    pn.executeBatch();
    pn.close();
  }
} catch (Exception ex) {
  error = "No fue posible registrar la entrega. Inténtalo de nuevo.";
  if (archivoGuardado != null && archivoGuardado.exists()) archivoGuardado.delete();
} finally {
  if (con != null) { try { con.close(); } catch (SQLException ignore) {} }
}

if (error != null) {
  response.sendRedirect(baseUrl + "?error=" + URLEncoder.encode(error, "UTF-8"));
  return;
}
response.sendRedirect(baseUrl + "?ok=" + URLEncoder.encode("Documento final entregado correctamente. Quedó en revisión.", "UTF-8"));
%>

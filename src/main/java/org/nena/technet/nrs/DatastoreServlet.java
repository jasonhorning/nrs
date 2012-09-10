package org.nena.technet.nrs;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.Map;

//@WebServlet(name = "DatastoreServlet", urlPatterns = {"/data/*"})
public class DatastoreServlet extends javax.servlet.http.HttpServlet {
  private static final Map<String, String> contentTypes = new HashMap<String, String>();
  static {
    contentTypes.put("json","application/json");
    contentTypes.put("xml","text/xml");
    contentTypes.put("xsd","text/xml");
    contentTypes.put("xsl","text/xml");
  }

  private String getRoot(){
    final String DATASTORE_PATH = "NRS_DATASTORE_PATH";
    final String USER_HOME = System.getProperty("user.home");
    final String ETC_NENA_NRS_DATASTORE = "/etc/nena/nrs/datastore";

    String root = System.getProperty(DATASTORE_PATH);
    if (null == root) root = System.getenv().get(DATASTORE_PATH);
    if ( (null == root) && new File(ETC_NENA_NRS_DATASTORE).exists() ) root = ETC_NENA_NRS_DATASTORE;

    if (null != root) root = root.replaceAll("~/", USER_HOME + "/");

    return root;
  }

  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    File file = getFile(request);
    if ((null == file) || (! file.exists())) {
      response.setStatus(HttpServletResponse.SC_NOT_FOUND);
      return;
    }

    int status = inFileOutResponse(file, response);
    response.setStatus(status);
  }

  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    File file = getFile(request);
    File parent = (file == null) ? null : file.getParentFile();
    if ((null == file) || (file.exists() && ! file.canWrite()) || (null == parent) || (! parent.canWrite())) {
      response.setStatus(HttpServletResponse.SC_NOT_FOUND);
      return;
    }

    try {
      if (inRequestOutFile(request, file)) {
        int status = inFileOutResponse(file, response);
        response.setStatus(status);
      }
    } catch (Throwable e) {
      response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
      e.printStackTrace(System.err);
    }
  }

  protected void doPut(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    doPost(request, response);
  }

  private File getFile(HttpServletRequest request) {
    String root = getRoot();
    String path_info = request.getPathInfo();
    String file_name = root + path_info;
    File file = new File(file_name);

    if ( (null == root) || (null == path_info) || (path_info.contains("../")) || (path_info.lastIndexOf(".") < 0) ) {
      return null;
    }
    return file;
  }

  private boolean inRequestOutFile(HttpServletRequest request, File file) throws Exception {
    InputStream in = request.getInputStream();
    File tmp = File.createTempFile(file.getName().substring(file.getName().lastIndexOf("/")+1), null);
    OutputStream out = new FileOutputStream(tmp);

    byte[] buf = new byte[1024];
    int count = 0;
    try {
      while ((count = in.read(buf)) >= 0) {
        out.write(buf, 0, count);
      }
    } finally {
      try {in.close();} catch (IOException ignore) {}
      try {out.close();} catch (IOException ignore) {}
    }

    return tmp.renameTo(file);
  }


  private int inFileOutResponse(File file, HttpServletResponse response) {
    String file_name = file.getName();
    String file_ext = file_name.substring(file_name.lastIndexOf(".") + 1);
    String ct = contentTypes.get(file_ext);
    ct = (null == ct) ? "text/plain" : ct;

    response.setContentType(ct);
    response.setHeader("Content-Length", String.valueOf(file.length()));

    try {
      FileInputStream in = new FileInputStream(file);
      OutputStream out = response.getOutputStream();

      byte[] buf = new byte[1024];
      int count = 0;
      try {
        while ((count = in.read(buf)) >= 0) {
          out.write(buf, 0, count);
        }
      } finally {
        try {in.close();} catch (IOException ignore) {}
        try {out.close();} catch (IOException ignore) {}
      }
    } catch (FileNotFoundException e) {
      return HttpServletResponse.SC_NOT_FOUND;
    } catch (Throwable e) {
      e.printStackTrace(System.err);
      return HttpServletResponse.SC_INTERNAL_SERVER_ERROR;
    }
    return HttpServletResponse.SC_OK;
  }

}
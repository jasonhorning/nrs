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
        contentTypes.put("json", "application/json");
        contentTypes.put("xml", "text/xml");
        contentTypes.put("xsd", "text/xml");
        contentTypes.put("xsl", "text/xml");
        contentTypes.put("css", "text/css");
    }

    private String getRoot() {
        final String DATASTORE_PATH = "NRS_DATASTORE_PATH";
        final String VAR_NENA_NRS_DATASTORE = "/var/nena/nrs/datastore";

        String root = System.getProperty(DATASTORE_PATH);
        if (null == root) root = System.getenv().get(DATASTORE_PATH);
        if ((null == root) && new File(VAR_NENA_NRS_DATASTORE).exists()) root = VAR_NENA_NRS_DATASTORE;

        return root;
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        File file = getFile(request.getPathInfo());
        if ((null == file) || (!file.exists())) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        int status = inFileOutResponse(file, response);
        response.setStatus(status);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //right now we only support POSTing multiple files (single files must use PUT)
        if (!"/multiplefiles".equals(request.getPathInfo())) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        //count up the files in the POST
        int filecount;
        for (filecount=0; null != request.getParameter("filename" + filecount) && filecount < 10; filecount++){}

        //each file will be written as a temp file, and the final destination will be tested for writability before

        //for each file, files[i][0] holds the temp File, files[i][1] holds the destination File
        File[][] files = new File[filecount][2];

        try {
            for (int i=0; i<filecount; i++) {
                String path = request.getParameter("filename" + i);
                String body = request.getParameter("body" + i);
                files[i][1] = getFile(path);
                File file = files[i][1];
                File parent = files[i][1].getParentFile();
                if ((null == file) || (file.exists() && !file.canWrite()) || (null == parent) || (!parent.canWrite())) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
                files[i][0] = writeTempFile(path, body);
            }

            //all files have been written to tmp's, and their destinations have been verified for writability, so move the tmp's to their destinations
            for (int i=0; i<filecount; i++) {
                if (null == files[i][0] || null == files[i][1]) continue;
                files[i][0].renameTo(files[i][1]);
            }

            //echo the first file back to the caller as the response body
            if (filecount > 0) {
                int status = inFileOutResponse(files[0][1], response);
                response.setStatus(status);
            }

        } catch (Throwable e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            e.printStackTrace(System.err);
        }
    }

    private File getFile(String path_info) {
        String root = getRoot();
        String file_name = root + path_info;
        File file = new File(file_name);

        if ((null == root) || (null == path_info) || (path_info.contains("../")) || (path_info.lastIndexOf(".") < 0)) {
            return null;
        }
        return file;
    }

    private File writeTempFile (String nonTempPath, String content) throws Exception {
        File tmp = File.createTempFile(nonTempPath.substring(nonTempPath.lastIndexOf("/") + 1), null);
        if (null == content) return tmp;

        OutputStream out = new FileOutputStream(tmp);
        try {
            out.write(content.getBytes());
        } finally {
            try {
                out.close();
            } catch (IOException ignore) {
            }
        }
        return tmp;
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
                try {
                    in.close();
                } catch (IOException ignore) {
                }
                try {
                    out.close();
                } catch (IOException ignore) {
                }
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
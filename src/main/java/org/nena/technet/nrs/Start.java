package org.nena.technet.nrs;

import java.io.File;
import java.net.URL;
import java.security.ProtectionDomain;

import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.webapp.WebAppContext;

public final class Start {

  public static void main(String[] args) throws Exception {
    String jetty_home = System.getProperty("jetty.home", "..");
    int port = Integer.parseInt(System.getProperty("port", "8080"));
    Server server = new Server(port);

    ProtectionDomain domain = Server.class.getProtectionDomain();
    URL location = domain.getCodeSource().getLocation();

    WebAppContext webapp = new WebAppContext();
    webapp.setContextPath("/");
    webapp.setDescriptor(location.toExternalForm() + "/WEB-INF/web.xml");
    webapp.setServer(server);
    webapp.setWar(location.toExternalForm());

    // (Optional) Set the directory the war will extract to.
    // If not set, java.io.tmpdir will be used, which can cause problems
    // if the temp directory gets cleaned periodically.
    // Your build scripts should remove this directory between deployments
//    webapp.setTempDirectory(new File("/path/to/webapp-directory"));

    server.setHandler(webapp);
    server.start();
    server.join();
  }
}
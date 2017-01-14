NRS System Administration Guide
===============================


Background
----------

NENA is responsible for maintaining values contained in a variety of protocols and system interfaces.  These values are defined in registries and are published as XML documents (files).  The NENA Registry System (NRS) is a web-based application that manages and publishes the NENA registries.

Status of this document
-----------------------

Draft - for the purpose of determining an appropriate hosting environment.

_Note: The instructions in this document are prescriptive, but in reality there are many ways to install the NRS application onto a Linux server.  If these instructions aren't suitable, they can be modified to match the environment that the NRS application is installed into._


Package Contents
----------------

* `nrs.tar.gz`  
  the NRS application distribution, which contains:

  * `/usr/local/bin/nrs/nrs-jetty-console.war`  
    the NRS application (executable Jar, despite its .war name)

  * `/var/nena/nrs/datastore/*`
    the NRS registry XML files

  * `/etc/httpd.d/nrs.*`  
    Apache web server configuration files for NRS


System Requirements
-------------------

* Linux, kernel 2.6 or later (tested on CentOS 6.3)
* Apache 2.2 or later
* Oracle Java 7 JRE (java version "1.7.0_04" or later)
* NRS application resource requirements
  * 128MB RAM
  * 10MB disk space for application
  * 10MB disk space for registries


Network Requirements
--------------------

The NRS application is a web-based application.  Public Internet access to TCP port 80 on the server is required.
For administration and troubleshooting purposes, internet access to ssh TCP port 22 is recommended.
Note: A future enhancement to the NRS application may require git+ssh access to github.com for the purposes of publishing the NRS xml files to the GitHub code repository.


Installation Instructions
-------------------------
_Note: execute the following as root._

	% java -version
		java version "1.7.0_04"
		Java(TM) SE Runtime Environment (build 1.7.0_04-b20)
		Java HotSpot(TM) 64-Bit Server VM (build 23.0-b21, mixed mode)
	% useradd nrs
	% cd /
	% tar zxovf ~bdupras/projects/nena/nrs/target/nena-nrs.tar.gz
	% chown -R nrs.nrs /var/nena/nrs
	% java -jar /opt/nena/nrs/bin/nrs-jetty-console.war --createStartScript nrs-admin
	% vi /opt/nena/nrs/bin/nrs-admin.cnf
		JAVA_USER=nrs
                JAVA_OPTS="-server -Xmx512m -Dorg.eclipse.jetty.server.Request.maxFormContentSize=1000000"
		JAVA_ARGS="--headless --port 8080 --contextPath /nrs --tmpDir /var/tmp"
	% vi /opt/nena/nrs/bin/nrs-admin
		LOG="/var/nena/nrs/log/$NAME.out"
	% ln -s /opt/nena/nrs/bin/nrs-admin /etc/init.d/
	% ln -s /var/nena/nrs/datastore/registry/ /var/www/html/
	% chkconfig nrs-admin on
	% chkconfig httpd on
	% service httpd restart
		Stopping httpd:                                            [  OK  ]
		Starting httpd:                                            [  OK  ]
	% service nrs-admin restart
		Restarting nrs-admin.
	% curl -I http://localhost:8080/nrs
		HTTP/1.1 302 Found
		Location: http://localhost:8080/nrs/
		Content-Length: 0
		Server: Jetty(7.6.0.v20120127)
	% curl -I http://localhost/registry/_registries.xml
		HTTP/1.1 200 OK
		Date: Sun, 03 Feb 2013 07:15:02 GMT
		Server: Apache/2.2.15 (CentOS)
		Last-Modified: Sun, 03 Feb 2013 06:45:34 GMT
		ETag: "2200b4-aad-4d4cc52cf2ea2"
		Accept-Ranges: bytes
		Content-Length: 2733
		Connection: close
		Content-Type: text/xml


Maintaining NRS administrator users & passwords
------------------------------------------
_Note: the NRS application doesn't track users and passwords internally.  Rather, when the NRS application is installed with an Apache front-end web server, Apache user authentication is used to secure the NRS application._

_Note: execute the following as root (use the -c flag the first time to create a new nrs.passwd file.)_

	% htdigest /etc/httpd/conf.d/nrs.passwd "NRS Administration" nrsadmin
	Adding password for nrsadmin in realm NRS Administration.
	New password:
	Re-type new password:


Starting and stopping the NRS administration application
--------------------------------------------------------

	#as root
	% service httpd start
	% service nrs-admin start
	% service nrs-admin stop


Backup/Restore
--------------

Filesystem backups and restores of the `/var/nena/nrs` directory are all that are required to backup and restore the data that the NRS administration application maintains.  The files in this directory are very small, far less than 10MB in total size.


Application Design
------------------
<pre>
                                  O Public HTTP Port, e.g.
                                  | http://technet.nena.org
                                  |
   +------------------------------|---------------------------------------+
   |                              |                         Linux Host OS |
   |                              |                                       |
   |    +-------------------------+------------------------------+        |
   |    |                                      Apache Web Server |        |
   |    |--------------------------------------------------------|        |
   |    |                                                        |        |
   |    |    /nrs/registry/*                /nrs/admin/*         |        |
   |    | served via filesystem         served via mod_proxy     |        |
   |    |   anonymous access         authenticaed via mod_digest |        |
   |    +--------+-------------------------------+---------------+        |
   |             |                               |                        |
   |             |                               |                        |
   |             |                               |                        |
   |             |reads                          v                        |
   |             |                               O Private HTTP port      |
   |             v                               | http://localhost:8080  |
   |    +----------------+               +-------+---------------+        |
   |    |  NRS XML Files |               | NRS Admin Application |        |
   |    |----------------|               |-----------------------|        |
   |    |  plain files   | &lt; - - - - - - +   Java application    |        |
   |    |    on disk     |  reads/writes |  embedded web server  |        |
   |    +----------------+               +-----------------------+        |
   +----------------------------------------------------------------------+

</pre>


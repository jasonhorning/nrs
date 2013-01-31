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

* nrs.tar.gz
  the NRS application distribution, which contains:

  * /usr/local/bin/nrs/nrs-jetty-console.war
    the NRS application (executable Jar, despite its .war name)

  * /var/nrs/datastore/*
    the NRS registry XML files

  * /etc/httpd.d/nrs.*
    Apache web server configuration files for NRS


System Requirements
-------------------

* Linux, kernel 2.6 or later (tested on CentOS 6.3)
* Apache 2.2 or later
* Oracle Java 7 JRE (java version "1.7.0_04" or later)
* NRS application resource requirements
  128MB RAM
  10MB disk space for application
  10MB disk space for registries


Network Requirements
--------------------

The NRS application is a web-based application.  Public Internet access to TCP port 80 on the server is required.
For administration and troubleshooting purposes, internet access to ssh TCP port 22 is recommended.
Note: A future enhancement to the NRS application may require git+ssh access to github.com for the purposes of publishing the NRS xml files to the GitHub code repository.


Installation Instructions
-------------------------

`
# as root
% useradd nrs
% cd /
% tar zxvf /path/to/nrs.tar.gz
% java -jar /usr/local/bin/nrs/nrs-jetty-console.war --createStartScript nrs-admin
% mv /usr/local/bin/nrs/nrs-admin /etc/rc3.d/
# edit /usr/local/bin/nrs/nrs-admin.cnf and modify the following settings
    JAVA_USER=nrs
    contextPath=/nrs
    port=8080
    tmpDir=/var/tmp
% chkconfig --level 35 nrs-admin on
% chkconfig --level 35 httpd on
`

Setting up the apache web server
--------------------------------


Securing the admin tool
-----------------------

#as root (instructions tbd)

`
% htpasswd ...
`

Starting and stopping the NRS administration application
--------------------------------------------------------

`
#as root
% service httpd start
% service nrs-admin start
% service nrs-admin stop
`

Backup/Restore
--------------

Filesystem backups and restores of the /var/nrs directory are all that are required to backup and restore the data that the NRS administration application maintains.  The files in this directory are very small, far less than 10MB in total size.

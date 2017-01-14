#!/bin/bash -e
# because mvn is too rigid.  Ergh.

mvn clean package

cp -R src/main/system target
mkdir -p target/system/opt/nena/nrs/bin/
cp target/nrs-jetty-console.war target/system/opt/nena/nrs/bin/
cp target/nrs.war target/system/opt/nena/nrs/bin/

# because git doesn't let you check in empty directories.  Ergh.
find . -name emptyfile.txt -exec rm {} \;

(cd target/system && tar zcvf ../nena-nrs.tar.gz *)


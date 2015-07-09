{#
Salt Formula by Ian Weaklim weaklim@jpl.nasa.gov ianw@uwyo.edu
Developed for JPL/NASA Summer 2014
#}
include:
  - tomcat

install_deps:
  pkg.installed:
    - names:
      - apr-devel
      - apr-util-devel
      - openssl-devel

decompress_apache_apr:
  archive:
    - extracted
    - name: /usr/src
    - source: salt://tomcat/files/tomcat-native-1.1.31-src.tar.gz
    - archive_format: tar
    - if_missing: /usr/src/tomcat-native-1.1.31-src

compile_apr:
  cmd.run:
    - cwd: /usr/src/tomcat-native-1.1.31-src
    - name: cd /usr/src/tomcat-native-1.1.31-src/jni/native; ./configure --with-apr=/usr/bin/apr-1-config --with-java-home=/usr --with-ssl=yes --prefix=/usr; make && make install

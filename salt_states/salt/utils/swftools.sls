{#
Salt Formula by Ian Weaklim weaklim@jpl.nasa.gov ianw@uwyo.edu
Developed for JPL/NASA Summer 2014
#}
include:
 - utils

swftools_deps:
  pkg.installed:
    - order: 1
    - names:
      - gcc-c++
      - zlib-devel
      - libjpeg-turbo-devel
      - giflib-devel
      - freetype-devel 

decompress_swftools:
    archive:
    - order: 1
    - extracted
    - name: /usr/src/
    - source: salt://utils/files/source/swftools.tar.gz
    - archive_format: tar
    - if_missing: /usr/src/swftools
    - source_hash: md5=3f5107aa676c26f7b86b3af6080a2d03

swftools_install:
  cmd.run:
    - cwd: /usr/src/swftools
    - name: /usr/src/swftools/configure; cd /usr/src/swftools/lib/pdf; make; make install;cd /usr/src/swftools; /usr/src/swftools/configure && make && make install
    - onlyif: test ! -e /usr/local/bin/pdf2swf
    - require:
      - pkg: swftools_deps

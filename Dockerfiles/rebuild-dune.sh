#!/bin/bash

set -e

export BASEDIR=/data/home/dune-gdt-python-bindings
cd $BASEDIR

# load the variables of this environment, sources the virtualenv
source /data/dune/PATH.sh

# build dune
NPROC=2
./dune-common/bin/dunecontrol --opts=config.opts/$OPTS --builddir=/data/dune/build configure
./dune-common/bin/dunecontrol --opts=config.opts/$OPTS --builddir=/data/dune/build bexec "make -j$NPROC all"
./dune-common/bin/dunecontrol --opts=config.opts/$OPTS --builddir=/data/dune/build bexec "make -j$NPROC bindings_no_ext || echo no bindings"
./dune-common/bin/dunecontrol --opts=config.opts/$OPTS --builddir=/data/dune/build bexec "make install_python"


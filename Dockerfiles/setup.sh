#!/bin/bash

set -e

# initialize the virtualenv
mkdir -p /data/dune/venv && \
  cd /data/dune/venv && \
  virtualenv --python=python3 dune-gdt-python-bindings

# load the variables of this environment, sources the virtualenv
source /data/dune/PATH.sh

export BASEDIR=/data/home/dune-gdt-python-bindings

# install python dependencies into the virtualenv
cd $BASEDIR
pip install --upgrade pip
pip install $(grep Cython requirements.txt)
pip install -r requirements.txt
cd $BASEDIR
cd pymor && pip install -e .

# build dune
if [ "${OPTS: -6}" == ".ninja" ]; then
  MAKE=ninja
else
  MAKE=make
fi

cd "${BASEDIR}"/dune
NPROC=$(($(nproc) - 1))
./dune-common/bin/dunecontrol --opts=config.opts/$OPTS --builddir=/data/dune/build configure
./dune-common/bin/dunecontrol --opts=config.opts/$OPTS --builddir=/data/dune/build bexec "$MAKE -j$NPROC all"
./dune-common/bin/dunecontrol --opts=config.opts/$OPTS --builddir=/data/dune/build bexec "$MAKE -j$NPROC bindings_no_ext || echo no bindings"
./dune-common/bin/dunecontrol --opts=config.opts/$OPTS --builddir=/data/dune/build bexec "$MAKE install_python"


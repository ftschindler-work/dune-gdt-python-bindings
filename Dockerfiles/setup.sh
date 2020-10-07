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
for mod in dune-xt dune-gdt; do
  nice ionice ./dune-common/bin/dunecontrol --opts=config.opts/$OPTS --builddir=$INSTALL_PREFIX/build-$OPTS --only=$mod bexec "$MAKE -j$NPROC bindings_no_ext"
  nice ionice ./dune-common/bin/dunecontrol --opts=config.opts/$OPTS --builddir=$INSTALL_PREFIX/build-$OPTS --only=$mod bexec "$MAKE -j$NPROC install_python"
done


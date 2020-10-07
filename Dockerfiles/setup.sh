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
  MAKE="make -j(($(nproc) - 1))"
fi

cd "${BASEDIR}"/dune
nice ionice ./dune-common/bin/dunecontrol --opts=config.opts/$OPTS --builddir=/data/dune/build configure
nice ionice ./dune-common/bin/dunecontrol --opts=config.opts/$OPTS --builddir=/data/dune/build bexec "$MAKE all"
for mod in dune-xt dune-gdt; do
  nice ionice ./dune-common/bin/dunecontrol --opts=config.opts/$OPTS --builddir=/data/dune/build --only=$mod bexec "$MAKE bindings_no_ext"
  nice ionice ./dune-common/bin/dunecontrol --opts=config.opts/$OPTS --builddir=/data/dune/build --only=$mod bexec "$MAKE install_python"
done


#!/bin/bash

set -e

export BASEDIR=/data/home/dune-gdt-python-bindings
cd $BASEDIR

# load the variables of this environment, sources the virtualenv
source /data/dune/PATH.sh

# build dune
if [ "${OPTS: -6}" == ".ninja" ]; then
  MAKE=ninja
else
  MAKE="make -j(($(nproc) - 1))"
fi

nice ionice ./dune-common/bin/dunecontrol --opts=config.opts/$OPTS --builddir=/data/dune/build configure
nice ionice ./dune-common/bin/dunecontrol --opts=config.opts/$OPTS --builddir=/data/dune/build bexec "$MAKE all"
for mod in dune-xt dune-gdt; do
  nice ionice ./dune-common/bin/dunecontrol --opts=config.opts/$OPTS --builddir=/data/dune/build --only=$mod bexec "$MAKE bindings_no_ext"
  nice ionice ./dune-common/bin/dunecontrol --opts=config.opts/$OPTS --builddir=/data/dune/build --only=$mod bexec "$MAKE install_python"
done


#!/bin/bash

set -e

if [ "X${OPTS}" == "X" ]; then
    echo You have to define OPTS, i.e. export OPTS=gcc-relwithdebinfo
    exit
fi

# define environment in case we are not in one of our dockers
# determines which one to use below envs/
if [ "X${DXT_ENVIRONMENT}" == "X" ]; then
    echo No environment specified, defaulting to debian-full!
    export DXT_ENVIRONMENT=debian-full
fi

# check existence of the virtualenv
if [ -e envs/${DXT_ENVIRONMENT}/venv/dune-${OPTS} ]; then
    echo -n
else
    echo Missing virtualenv, did you call setup.sh?
    exit
fi

# load the variables of this environment, sources the virtualenv
source envs/${DXT_ENVIRONMENT}/PATH.sh

# build dune
if [ "${OPTS: -6}" == ".ninja" ]; then
  MAKE=ninja
else
  MAKE=make
fi

cd "${BASEDIR}"/dune
NPROC=$(($(nproc) - 1))
nice ionice ./dune-common/bin/dunecontrol --opts=config.opts/$OPTS --builddir=$INSTALL_PREFIX/build-$OPTS configure
nice ionice ./dune-common/bin/dunecontrol --opts=config.opts/$OPTS --builddir=$INSTALL_PREFIX/build-$OPTS bexec "$MAKE -j$NPROC all"
nice ionice ./dune-common/bin/dunecontrol --opts=config.opts/$OPTS --builddir=$INSTALL_PREFIX/build-$OPTS bexec "$MAKE -j$NPROC bindings_no_ext || echo no bindings"
nice ionice ./dune-common/bin/dunecontrol --opts=config.opts/$OPTS --builddir=$INSTALL_PREFIX/build-$OPTS bexec "$MAKE install_python"

echo
echo "All done! From now on run"
echo "  export OPTS=$OPTS"
echo "  source envs/${DXT_ENVIRONMENT}/PATH.sh"
echo "to activate the virtualenv!"

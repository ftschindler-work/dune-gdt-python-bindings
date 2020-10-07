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

# initialize the virtualenv, if not yet present
export BASEDIR="${PWD}"
mkdir -p envs/${DXT_ENVIRONMENT}/venv
if [ -e envs/${DXT_ENVIRONMENT}/venv/dune-${OPTS} ]; then
  echo not creating virtualenv in envs/${DXT_ENVIRONMENT}/venv/dune-${OPTS}, already exists
else
  cd envs/${DXT_ENVIRONMENT}/venv
  virtualenv --python=python3 dune-${OPTS}
  source dune-${OPTS}/bin/activate
  echo "$BASEDIR/scripts" > "$(python -c 'from distutils.sysconfig import get_python_lib; print(get_python_lib())')/scripts.pth"
  deactivate
fi
cd "${BASEDIR}"
unset BASEDIR

# load the variables of this environment, sources the virtualenv
source envs/${DXT_ENVIRONMENT}/PATH.sh

# install python dependencies into the virtualenv
cd "${BASEDIR}"
pip install $(grep Cython requirements.txt)
pip install -r requirements.txt

cd "${BASEDIR}"
cd pymor && pip install -e .

cd "${BASEDIR}"
if [ -e simdb ] ; then
  cd simdb
  pip install -e .
  cd "${BASEDIR}"
else
  pip install simdb
fi

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
for mod in dune-xt dune-gdt; do
  nice ionice ./dune-common/bin/dunecontrol --opts=config.opts/$OPTS --builddir=$INSTALL_PREFIX/build-$OPTS --only=$mod bexec "$MAKE -j$NPROC bindings_no_ext"
  nice ionice ./dune-common/bin/dunecontrol --opts=config.opts/$OPTS --builddir=$INSTALL_PREFIX/build-$OPTS --only=$mod bexec "$MAKE -j$NPROC install_python"
done

cd "${BASEDIR}"
echo
echo "All done! From now on run"
echo "  export OPTS=$OPTS"
echo "  source envs/${DXT_ENVIRONMENT}/PATH.sh"
echo "to activate the virtualenv!"

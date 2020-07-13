DIR="$(cd "$(dirname ${BASH_SOURCE[0]})" ;  pwd -P )"
export BASEDIR=$(cd ${DIR}/../.. && pwd)
export INSTALL_PREFIX=${DIR}
export PATH=${INSTALL_PREFIX}/bin:$PATH
export LD_LIBRARY_PATH=${INSTALL_PREFIX}/lib64:${INSTALL_PREFIX}/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=${INSTALL_PREFIX}/lib64/pkgconfig:${INSTALL_PREFIX}/lib/pkgconfig:${INSTALL_PREFIX}/share/pkgconfig:$PKG_CONFIG_PATH
export CMAKE_FLAGS="-DDUNE_PYTHON_VIRTUALENV_EXECUTABLE=python3 -DDUNE_PYTHON_VIRTUALENV_SETUP=FALSE -DDUNE_PYTHON_ALLOW_GET_PIP=FALSE"
export SIMDB_GIT_REPOS=$BASEDIR
export SIMDB_PATH=${BASEDIR}/DATA
if [ "X${OPTS}" == "X" ]; then
    echo "You did not define OPTS (export OPTS=gcc-relwithdebinfo), not loading a virtualenv!"
else
    if [ -e "${DIR}/venv/dune-${OPTS}/bin/activate" ]; then
        source "${DIR}/venv/dune-${OPTS}/bin/activate"
    else
        echo "WARNING: missing virtualenv for OPTS=${OPTS}, did you call setup.sh?"
    fi
fi


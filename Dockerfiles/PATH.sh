export OPTS=gcc-relwithdebinfo
export INSTALL_PREFIX=/data/dune
export PATH=${INSTALL_PREFIX}/bin:$PATH
export LD_LIBRARY_PATH=${INSTALL_PREFIX}/lib64:${INSTALL_PREFIX}/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=${INSTALL_PREFIX}/lib64/pkgconfig:${INSTALL_PREFIX}/lib/pkgconfig:${INSTALL_PREFIX}/share/pkgconfig:$PKG_CONFIG_PATH
export CMAKE_FLAGS="-DCMAKE_DISABLE_FIND_PACKAGE_MPI=TRUE -DMINIMAL_DEBUG_LEVEL=grave -DDUNE_PYTHON_VIRTUALENV_SETUP=1 -DDUNE_PYTHON_VIRTUALENV_PATH=${INSTALL_PREFIX}/venv/dune-gdt-python-bindings"
source "${INSTALL_PREFIX}/venv/dune-gdt-python-bindings/bin/activate"


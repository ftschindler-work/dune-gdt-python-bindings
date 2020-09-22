```bash
# This file is part of the dune-gdt-python-bindings project:
#   https://github.com/ftschindler-work/dune-gdt-python-bindings
# Copyright holders: Felix Schindler
# License: BSD 2-Clause License (http://opensource.org/licenses/BSD-2-Clause)
# Authors:
#   Felix Schindler (2020)
```

# The `dune-gdt-python-bindings` project

serves to demonstrate the use of [dune-gdt](https://github.com/dune-community/dune-gdt)s Python bindings.
There are at least three use-cases of this project, which are further detailed below:

* to quickly test the Python bindings (pre-built bindings, persistent notebooks)
* for an interactive session (pre-built + custom bindings, persistent notebooks and source)
* for extended development (persistent sources, notebooks and bindings)

In the first two scenarios, the pre-built binaries and shared objects (i.e. Python modules)
from the docker container are used. The second scenario allows to create custom bindings which
however need to be compiled after each container restart (the sources remain persistent).
The last scenario uses persistent sources and bindings which need not be recompiled after a container
restart, however requiring manual setup and some compute resources (>= 8G RAM).


## To quickly test the Python bindings

This scenario uses the [ftschindlerwork/dune-gdt-python-bindings](https://hub.docker.com/r/ftschindlerwork/dune-gdt-python-bindings)
docker image associated with this project to provide all pre-built bindings. Thus, no changes
to the C++ sources have any effect and only the `notebooks/` subdirectory remains persistent.

* make sure you can sudo run docker [as explained here](https://github.com/dune-community/Dockerfiles),

* execute

  ```bash
  git clone https://github.com/ftschindler-work/dune-gdt-python-bindings.git
  ./dune-gdt-python-bindings/docker_run.sh
  ```

* and follow the instructions to

* have a look at the examples and tutorials available in the [`notebooks/`](https://github.com/ftschindler-work/dune-gdt-python-bindings/tree/master/notebooks) subdirectory.

Note that all changes within the `notebooks/` subdirectory remain persistent.


## For an interactive session

This scenario also uses the [ftschindlerwork/dune-gdt-python-bindings](https://hub.docker.com/r/ftschindlerwork/dune-gdt-python-bindings)
docker image associated with this project to provide all pre-built bindings but allows to
create custom bindings by overwriting the pre-built bindings with those compiled from the
current C++ sources (using the pre-configured QtCreator IDE as detailed in the instructions).
Note that custom bindings need to be compiled after each start of the container, else the
pre-built ones are used without further notice. All changes within the project directory (C++ sources
and notebooks) remain persistent.

* make all submodules available (for your changes to DUNE and pyMOR to remain persistent)

  ```bash
  git clone https://github.com/ftschindler-work/dune-gdt-python-bindings.git
  cd dune-gdt-python-bindings
  git submodule update --init --recursive
  ```

* execute
  
  ```bash
  ./docker_run.sh /bin/bash
  ```

* and follow the instructions.


## For extended development

This scenario uses the [dunecommunities docker infrastructure](https://github.com/dune-community/Dockerfiles)
and one of the [dunecommunities docker images](https://hub.docker.com/u/dunecommunity) to allow to
completely create all bindings from scratch. The C++ sources, the notebooks as well as the built results are
persistent, but the QtCreator IDE has to be configures manually once.

* get the helper scripts:

  ```bash
  git clone https://github.com/dune-community/Dockerfiles.git dune-dockerfiles
  ```

* make all submodules available (for your changes to DUNE and pyMOR to remain persistent)

  ```bash
  git clone https://github.com/ftschindler-work/dune-gdt-python-bindings.git
  cd dune-gdt-python-bindings
  git submodule update --init --recursive
  ```

* choose a base container image, e.g. `debian-qtcreator` or `arch-minimal-interactive` and
  start the container (from the directory containing `dune-dockerfiles` and `dune-gdt-python-bindings`)

  ```bash
  ./dune-dockerfiles/docker_run.sh arch-minimal-interactive dune-gdt-python-bindings /bin/bash
  ```

### First setup

Within the container proceed with

* define the release type (use `clang-debug.ninja` for a debug build, slow but lots of helpful warnings
  and assertions or `clang-relwithdebinfo.ninja` for a release build, fast without warnings or assertions)

  ```bash
  export OPTS=clang-relwithdebinfo.ninja
  ```

* build everything

  ```bash
  cd ~/dune-gdt-python-bindings
  ./setup.sh
  ```

* build results are in `~/dune-gdt-python-bindings/envs/${DXT_ENVIRONMENT}/build-${OPTS}/`

It does make sense to repeat this process for both a debug and a release build before configuring QtCreator
for the first time.

* configure QtCreator, all changes are kept persistent in your home due to the `docker_run.sh` script

  - start `qtcreator &> /dev/null &`, note the `xhost` permissions as [explained here](https://github.com/dune-community/Dockerfiles)
  - configure Plugins to disable most that you don't need, in particular `ClangCodeModel` and `Code analyzer`
    for the much faster old behaviour, or enable those for the new fancy (but CPU and RAM heavy) behaviour
  - in `Tools > Options > Kits > default` choose `CMake Generator` as `Ninja` + `CodeBlocks` and ensure an empty
    `Environment` and `CMake Configuration`
  - create a new session and open `dune/dune-xt/CMakeLists.txt` and `dune/dune-gdt/CMakeLists.txt` and
    configure the appropriate release type (e.g. debug and relwithdebinfo) and point it to the respective
    build directory (see above)
  - for each project, configure the `all`, `bindings_no_ext` and `install_python` targets and make sure that
    `dune-xt` is built as a dependency of `dune-gdt`


### Daily work

* Start the container and open QtCreator

  ```bash
  ./dune-dockerfiles/docker_run.sh arch-minimal-interactive dune-gdt-python-bindings /bin/bash
  cd ~/dune-gdt-python-bindings && source envs/${DXT_ENVIRONMENT}/PATH.sh && qtcreator &> /dev/null &
  ```

* open another Teminal and start the jupyter notebook server (note that each release type has its own
  virtualenv!)

  ```bash
  ./dune-dockerfiles/docker_exec.sh arch-minimal-interactive dune-gdt-python-bindings /bin/bash
  export OPTS=clang-relwithdebinfo.ninja && cd ~/dune-gdt-python-bindings && source envs/${DXT_ENVIRONMENT}/PATH.sh
  ./start_notebook_server.py
  ```

* open your favorite browser (though it usually makes sense to use another browser than your default)
  and point it to the printed URL starting with `http://127.0.0.1:18592/?token=`


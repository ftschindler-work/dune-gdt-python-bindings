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

## To quickly test the Python bindings

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

(e.g. to create your own bindings), instead

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

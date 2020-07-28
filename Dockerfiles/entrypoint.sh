#!/bin/bash
#
# This file is part of the dune-gdt-python-bindings project:
#   https://github.com/ftschindler-work/dune-gdt-python-bindings
# Copyright holders: Felix Schindler
# License: BSD 2-Clause License (http://opensource.org/licenses/BSD-2-Clause)
# Authors:
#   Felix Schindler (2020)

export LANG=en_US.UTF-8
echo "127.0.0.1 ${HOSTNAME}" >> /etc/hosts

if [ "X$@" == "X" ]; then
  exec gosu $USERNAME_ /bin/bash
elif [ "X$@" == "notebooks" ]; then
  exec gosu $USERNAME_ /bin/bash -c "./start_notebook_server"
else
  exec gosu $USERNAME_ "$@"
fi

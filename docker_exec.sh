#!/bin/bash
#
# This file is part of the dune-gdt-python-bindings project:
#   https://github.com/ftschindler-work/dune-gdt-python-bindings
# Copyright holders: Felix Schindler
# License: BSD 2-Clause License (http://opensource.org/licenses/BSD-2-Clause)
# Authors:
#   Felix Schindler (2020)

CID_FILE=/tmp/ftschindlerwork_dune-gdt-python-bindings.cid

sudo docker exec -it $(cat ${CID_FILE}) gosu user /bin/bash


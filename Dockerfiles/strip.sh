#!/bin/bash

cd /data/dune/build
for ii in $(find . -name \*.a -o -name \*.so); do
        strip -g --strip-unneeded -p $ii
done

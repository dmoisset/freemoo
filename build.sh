#!/bin/sh
./configure || exit 1
cd reverse-engineering
echo "Compiling reverse-engineering tools"
make || exit 1
cd ..

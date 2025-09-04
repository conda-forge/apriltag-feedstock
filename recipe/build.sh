#!/bin/bash
set -ex

# As documented in https://conda-forge.org/docs/maintainer/knowledge_base/#finding-numpy-in-cross-compiled-python-packages-using-cmake
Python3_INCLUDE_DIR="$(python -c 'import sysconfig; print(sysconfig.get_path("include"))')"
Python3_NumPy_INCLUDE_DIR="$(python -c 'import numpy;print(numpy.get_include())')"

cmake -G Ninja -B build \
    ${CMAKE_ARGS} \
    -D BUILD_SHARED_LIBS=ON \
    -D BUILD_PYTHON_WRAPPER=ON \
    -D BUILD_TESTING=ON \
    -D CMAKE_REQUIRE_FIND_PACKAGE_Python3:BOOL=ON \
    -D Python3_EXECUTABLE:PATH=${PYTHON}" \
    -D Python3_INCLUDE_DIR:PATH=${Python3_INCLUDE_DIR}" \
    -D Python3_NumPy_INCLUDE_DIR=${Python3_NumPy_INCLUDE_DIR}"
cmake --build build --target install

ctest --no-tests=error --output-on-failure --verbose --test-dir build/test/

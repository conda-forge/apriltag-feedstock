#!/bin/bash
set -ex

cmake -G Ninja -B build \
    ${CMAKE_ARGS} \
    -D BUILD_SHARED_LIBS=ON \
    -D BUILD_PYTHON_WRAPPER=ON \
    -D BUILD_TESTING=ON \
    -D CMAKE_REQUIRE_FIND_PACKAGE_Python3:BOOL=ON \
    -D Python3_EXECUTABLE:PATH=${PYTHON}
cmake --build build --target install

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != "1" ]]; then
    ctest --no-tests=error --output-on-failure --verbose --test-dir build/test/
fi

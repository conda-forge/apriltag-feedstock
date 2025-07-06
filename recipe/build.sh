#!/bin/bash
set -ex

# CMAKE_REQUIRE_FIND_PACKAGE_Python3 is used to early fail at CMake configuration if Python3 can't be found,
# see https://cmake.org/cmake/help/latest/variable/CMAKE_REQUIRE_FIND_PACKAGE_PackageName.html
cmake -G Ninja -B build \
    ${CMAKE_ARGS} \
    -D Python3_EXECUTABLE:PATH=${PYTHON} \
    -D CMAKE_REQUIRE_FIND_PACKAGE_Python3=ON \
    -D BUILD_SHARED_LIBS=ON \
    -D BUILD_PYTHON_WRAPPER=ON \
    -D BUILD_TESTING=ON
cat ./build/CMakeCache.txt
cmake --build build --target install

ctest --no-tests=error --output-on-failure --verbose --test-dir build/test/

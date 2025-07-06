#!/bin/bash
set -ex

# See https://conda-forge.org/docs/maintainer/knowledge_base/#finding-numpy-in-cross-compiled-python-packages-using-cmake
Python_INCLUDE_DIR="$(python -c 'import sysconfig; print(sysconfig.get_path("include"))')"
Python_NumPy_INCLUDE_DIR="$(python -c 'import numpy;print(numpy.get_include())')"
CMAKE_ARGS="${CMAKE_ARGS} -DPython3_EXECUTABLE:PATH=${PYTHON}"
CMAKE_ARGS="${CMAKE_ARGS} -DPython3_INCLUDE_DIR:PATH=${Python_INCLUDE_DIR}"
CMAKE_ARGS="${CMAKE_ARGS} -DPython3_NumPy_INCLUDE_DIR=${Python_NumPy_INCLUDE_DIR}"

# if cross-compiling, hardcode the SOABI to help CMake
# see https://github.com/conda-forge/htcondor-feedstock/pull/213/commits/c740e27124aa91a36e6a10e6f411d345582440ac
if [ "${build_platform}" != "${target_platform}" ]; then
  PYTHON_EXTENSION_SUFFIX=$(${PYTHON}${PY_VER}-config --extension-suffix | cut -d. -f2)
  CMAKE_ARGS="${CMAKE_ARGS} -DPython3_SOABI:STRING=${PYTHON_EXTENSION_SUFFIX}"
fi

echo "==============> CMAKE_ARGS: ${CMAKE_ARGS}"

# CMAKE_REQUIRE_FIND_PACKAGE_Python3 is used to early fail at CMake configuration if Python3 can't be found,
# see https://cmake.org/cmake/help/latest/variable/CMAKE_REQUIRE_FIND_PACKAGE_PackageName.html
cmake -G Ninja -B build \
    ${CMAKE_ARGS} \
    -D CMAKE_REQUIRE_FIND_PACKAGE_Python3=ON \
    -D BUILD_SHARED_LIBS=ON \
    -D BUILD_PYTHON_WRAPPER=ON \
    -D BUILD_TESTING=ON
cat ./build/CMakeCache.txt
cmake --build build --target install

ctest --no-tests=error --output-on-failure --verbose --test-dir build/test/

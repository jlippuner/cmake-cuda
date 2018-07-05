cmake_minimum_required(VERSION 2.8.8 FATAL_ERROR)

# set Release build type as default
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release" CACHE STRING
    "Configuration type (one of Debug, RelWithDebInfo, Release, MinSizeRel)"
    FORCE)
endif()

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/CMakeModules/")

project(Example CXX)

# enable warnings
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra")

# enable C++11
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

# generate debugging symbols for release and debug
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g")

# explicitly set DEBUG flag in Debug mode
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG")

# to make shared libraries we need position independent code
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")

find_package(CUDA REQUIRED)
include_directories(${CUDA_INCLUDE_DIRS})
set(EXAMPLE_EXTERNAL_LIBS "${EXAMPLE_EXTERNAL_LIBS};${CUDA_LIBRARIES}")
set(CUDA_SEPARABLE_COMPILATION On)
set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS};-gencode arch=compute_52,code=sm_52)
set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS};--ptxas-options=-v)
set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS};--maxrregcount 32)

macro(add_Example_library library sources)
  add_library(${library} OBJECT ${sources})
  set(EXAMPLE_LIBS "${EXAMPLE_LIBS};$<TARGET_OBJECTS:${library}>" PARENT_SCOPE)
endmacro()

set(CPP_SOURCES
  example.cpp
)

add_Example_library(lib ${CPP_SOURCES})

set(CUDA_SOURCES
  example.cu
)

cuda_add_library(Example_CUDA ${CUDA_SOURCES})
CUDA_COMPUTE_SEPARABLE_COMPILATION_OBJECT_FILE_NAME(Example_CUDA_link Example_CUDA "${Example_CUDA_SEPARABLE_COMPILATION_OBJECTS}")
set(EXAMPLE_LIBS "${EXAMPLE_LIBS};${Example_CUDA_SEPARABLE_COMPILATION_OBJECTS};${Example_CUDA_link}")

# create static library that will be used to link tests and SWIG library
add_library(Example_static
  ${EXAMPLE_LIBS}
)

# create shared library that can be used to link other C++ applications
add_library(Example SHARED
  ${EXAMPLE_LIBS}
)

set_target_properties(Example_static Example
  PROPERTIES LINKER_LANGUAGE CXX
)

add_executable(test_exec "exec.cpp")
target_link_libraries(test_exec
  Example_static
  ${EXAMPLE_EXTERNAL_LIBS}
)

# the compiler flags
message(STATUS "")
message(STATUS "")
message(STATUS "Configuration options:")
message(STATUS "")
message(STATUS "          CMAKE_CXX_FLAGS: " ${CMAKE_CXX_FLAGS})
message(STATUS "     CMAKE_CXX_LINK_FLAGS: " ${CMAKE_CXX_LINK_FLAGS})
message(STATUS "    CMAKE_CXX_FLAGS_DEBUG: " ${CMAKE_CXX_FLAGS_DEBUG})
message(STATUS "  CMAKE_CXX_FLAGS_RELEASE: " ${CMAKE_CXX_FLAGS_RELEASE})
message(STATUS "")
message(STATUS "          CUDA_NVCC_FLAGS:  ${CUDA_NVCC_FLAGS}")
message(STATUS "")
message(STATUS "")

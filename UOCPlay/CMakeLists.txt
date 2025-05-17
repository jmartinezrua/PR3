cmake_minimum_required(VERSION 3.10)
project(UOCPlay)

set(CMAKE_C_STANDARD 11)

include_directories(include)
file(GLOB LIB_SOURCES "src/*.c")

add_library(UOCPlay STATIC ${LIB_SOURCES})
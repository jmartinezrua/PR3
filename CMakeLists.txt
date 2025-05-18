cmake_minimum_required(VERSION 3.10)
project(UOC20242)

set(CMAKE_C_STANDARD 11)

# Agregar subproyecto de la biblioteca
add_subdirectory(UOCPlay build/UOCPlay)

# Archivos fuente del ejecutable
file(GLOB APP_SOURCES "src/*.c" "test/src/*.c")

# Crear el ejecutable
add_executable(UOC20242 ${APP_SOURCES})

# Incluir cabeceras necesarias
target_include_directories(UOC20242 PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/test/include
    ${CMAKE_CURRENT_SOURCE_DIR}/UOCPlay/include
)

# Enlazar con la biblioteca estática
target_link_libraries(UOC20242 UOCPlay)

# This is a comment

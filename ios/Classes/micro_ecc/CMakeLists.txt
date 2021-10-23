
   
cmake_minimum_required(VERSION 3.7 FATAL_ERROR)
project(micro_ecc VERSION 1.0.0 LANGUAGES C)

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/out/${CMAKE_SYSTEM_NAME}/library)

add_library(micro_ecc SHARED uECC.c)


set_target_properties(micro_ecc PROPERTIES
    PUBLIC_HEADER uECC.h
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "micro_ecc"
    OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Hex_Identity_ID_Goes_Here"
)

# add_executable(micro_ecc_test hello.c)
cmake_minimum_required(VERSION 3.7 FATAL_ERROR)
project(flutter_micro_ecc_android VERSION 1.0.0 LANGUAGES C)

add_library(micro_ecc SHARED ../ios/Classes/micro_ecc/uECC.c)

set_target_properties(micro_ecc PROPERTIES
    PUBLIC_HEADER uECC.h
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "micro_ecc"
)

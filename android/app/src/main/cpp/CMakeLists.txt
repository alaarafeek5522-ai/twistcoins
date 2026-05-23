cmake_minimum_required(VERSION 3.22.1)
project("twistcoins_guard")

add_library(
    guard
    SHARED
    guard.c
)

find_library(log-lib log)
find_library(android-lib android)

target_link_libraries(
    guard
    ${log-lib}
    ${android-lib}
)

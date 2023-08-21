cmake_minimum_required(VERSION 3.7.0)
project(luasocket)


aux_source_directory(./src DIR_SRCS)

list(REMOVE_ITEM DIR_SRCS "./src/wsocket.c")

option(LUA_SOCKET_STATIC "build static library" OFF)
if(LUA_SOCKET_STATIC)
    add_library(${PROJECT_NAME} STATIC ${DIR_SRCS})
else()
    add_library(${PROJECT_NAME} SHARED ${DIR_SRCS})
    set_target_properties(${PROJECT_NAME} PROPERTIES PREFIX "")
endif()
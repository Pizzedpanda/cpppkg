# This is a copy of <CPPPKG_PATH>/external/cpppkg_sdk_import.cmake

# This can be dropped into an external project to help locate pico-sdk and cpppkg
# It should be include()ed prior to project()

if (DEFINED ENV{CPPPKG_PATH} AND (NOT CPPPKG_PATH))
    set(CPPPKG_PATH $ENV{CPPPKG_PATH})
    message("Using CPPPKG_PATH from environment ('${CPPPKG_PATH}')")
endif ()

if (DEFINED ENV{CPPPKG_FETCH_FROM_GIT} AND (NOT CPPPKG_FETCH_FROM_GIT))
    set(CPPPKG_FETCH_FROM_GIT $ENV{CPPPKG_FETCH_FROM_GIT})
    message("Using CPPPKG_FETCH_FROM_GIT from environment ('${CPPPKG_FETCH_FROM_GIT}')")
endif ()

if (DEFINED ENV{CPPPKG_FETCH_FROM_GIT_PATH} AND (NOT CPPPKG_FETCH_FROM_GIT_PATH))
    set(CPPPKG_FETCH_FROM_GIT_PATH $ENV{CPPPKG_FETCH_FROM_GIT_PATH})
    message("Using CPPPKG_FETCH_FROM_GIT_PATH from environment ('${CPPPKG_FETCH_FROM_GIT_PATH}')")
endif ()

if (NOT CPPPKG_PATH)
    if (CPPPKG_FETCH_FROM_GIT)
        include(FetchContent)
        set(FETCHCONTENT_BASE_DIR_SAVE ${FETCHCONTENT_BASE_DIR})
        if (CPPPKG_FETCH_FROM_GIT_PATH)
            get_filename_component(FETCHCONTENT_BASE_DIR "${CPPPKG_FETCH_FROM_GIT_PATH}" REALPATH BASE_DIR "${CMAKE_SOURCE_DIR}")
        endif ()
        FetchContent_Declare(
                cpppkg
                GIT_REPOSITORY https://github.com/Pizzedpanda/cpppkg
                GIT_TAG master
        )
        if (NOT cpppkg)
            message("Downloading cpppkg")
            FetchContent_Populate(cpppkg)
            set(CPPPKG_PATH ${cpppkg_SOURCE_DIR})
        endif ()
        set(FETCHCONTENT_BASE_DIR ${FETCHCONTENT_BASE_DIR_SAVE})
    else ()
        if (PICO_SDK_PATH AND EXISTS "${PICO_SDK_PATH}/../cpppkg")
            set(CPPPKG_PATH ${PICO_SDK_PATH}/../cpppkg)
            message("Defaulting CPPPKG_PATH as sibling of PICO_SDK_PATH: ${CPPPKG_PATH}")
        else()
            message(FATAL_ERROR
                    "cpppkg location was not specified. Please set CPPPKG_PATH or set CPPPKG_FETCH_FROM_GIT to on to fetch from git."
                    )
        endif()
    endif ()
endif ()

set(CPPPKG_PATH "${CPPPKG_PATH}" CACHE PATH "Path to cpppkg libraries")
set(CPPPKG_FETCH_FROM_GIT "${CPPPKG_FETCH_FROM_GIT}" CACHE BOOL "Set to ON to fetch copy of cpppkg from git if not otherwise locatable")
set(CPPPKG_FETCH_FROM_GIT_PATH "${CPPPKG_FETCH_FROM_GIT_PATH}" CACHE FILEPATH "location to download cpppkg")

get_filename_component(CPPPKG_PATH "${CPPPKG_PATH}" REALPATH BASE_DIR "${CMAKE_BINARY_DIR}")
if (NOT EXISTS ${CPPPKG_PATH})
    message(FATAL_ERROR "Directory '${CPPPKG_PATH}' not found")
endif ()

set(CPPPKG_PATH ${CPPPKG_PATH} CACHE PATH "Path to cpppkg libraries" FORCE)

add_subdirectory(${CPPPKG_PATH} cpppkg)

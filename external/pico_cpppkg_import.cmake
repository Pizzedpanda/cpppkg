# This is a copy of <PICO_CPPPKG_PATH>/external/pico_cpppkg_sdk_import.cmake

# This can be dropped into an external project to help locate pico-sdk and pico_cpppkg
# It should be include()ed prior to project()

if (DEFINED ENV{PICO_CPPPKG_PATH} AND (NOT PICO_CPPPKG_PATH))
    set(PICO_CPPPKG_PATH $ENV{PICO_CPPPKG_PATH})
    message("Using PICO_CPPPKG_PATH from environment ('${PICO_CPPPKG_PATH}')")
endif ()

if (DEFINED ENV{PICO_CPPPKG_FETCH_FROM_GIT} AND (NOT PICO_CPPPKG_FETCH_FROM_GIT))
    set(PICO_CPPPKG_FETCH_FROM_GIT $ENV{PICO_CPPPKG_FETCH_FROM_GIT})
    message("Using PICO_CPPPKG_FETCH_FROM_GIT from environment ('${PICO_CPPPKG_FETCH_FROM_GIT}')")
endif ()

if (DEFINED ENV{PICO_CPPPKG_FETCH_FROM_GIT_PATH} AND (NOT PICO_CPPPKG_FETCH_FROM_GIT_PATH))
    set(PICO_CPPPKG_FETCH_FROM_GIT_PATH $ENV{PICO_CPPPKG_FETCH_FROM_GIT_PATH})
    message("Using PICO_CPPPKG_FETCH_FROM_GIT_PATH from environment ('${PICO_CPPPKG_FETCH_FROM_GIT_PATH}')")
endif ()

if (NOT PICO_CPPPKG_PATH)
    if (PICO_CPPPKG_FETCH_FROM_GIT)
        include(FetchContent)
        set(FETCHCONTENT_BASE_DIR_SAVE ${FETCHCONTENT_BASE_DIR})
        if (PICO_CPPPKG_FETCH_FROM_GIT_PATH)
            get_filename_component(FETCHCONTENT_BASE_DIR "${PICO_CPPPKG_FETCH_FROM_GIT_PATH}" REALPATH BASE_DIR "${CMAKE_SOURCE_DIR}")
        endif ()
        FetchContent_Declare(
                pico_cpppkg
                GIT_REPOSITORY https://github.com/Pizzedpanda/cpppkg
                GIT_TAG master
        )
        if (NOT pico_cpppkg)
            message("Downloading pico_cpppkg")
            FetchContent_Populate(pico_cpppkg)
            set(PICO_CPPPKG_PATH ${pico_cpppkg_SOURCE_DIR})
        endif ()
        set(FETCHCONTENT_BASE_DIR ${FETCHCONTENT_BASE_DIR_SAVE})
    else ()
        if (PICO_SDK_PATH AND EXISTS "${PICO_SDK_PATH}/../cpppkg")
            set(PICO_CPPPKG_PATH ${PICO_SDK_PATH}/../cpppkg)
            message("Defaulting PICO_CPPPKG_PATH as sibling of PICO_SDK_PATH: ${PICO_CPPPKG_PATH}")
        else()
            message(FATAL_ERROR
                    "pico_cpppkg location was not specified. Please set PICO_CPPPKG_PATH or set PICO_CPPPKG_FETCH_FROM_GIT to on to fetch from git."
                    )
        endif()
    endif ()
endif ()

set(PICO_CPPPKG_PATH "${PICO_CPPPKG_PATH}" CACHE PATH "Path to pico_cpppkg libraries")
set(PICO_CPPPKG_FETCH_FROM_GIT "${PICO_CPPPKG_FETCH_FROM_GIT}" CACHE BOOL "Set to ON to fetch copy of pico_cpppkg from git if not otherwise locatable")
set(PICO_CPPPKG_FETCH_FROM_GIT_PATH "${PICO_CPPPKG_FETCH_FROM_GIT_PATH}" CACHE FILEPATH "location to download pico_cpppkg")

get_filename_component(PICO_CPPPKG_PATH "${PICO_CPPPKG_PATH}" REALPATH BASE_DIR "${CMAKE_BINARY_DIR}")
if (NOT EXISTS ${PICO_CPPPKG_PATH})
    message(FATAL_ERROR "Directory '${PICO_CPPPKG_PATH}' not found")
endif ()

set(PICO_CPPPKG_PATH ${PICO_CPPPKG_PATH} CACHE PATH "Path to pico_cpppkg libraries" FORCE)

add_subdirectory(${PICO_CPPPKG_PATH} pico_cpppkg)


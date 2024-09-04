add_library(pico_cpppkg_included INTERFACE)
target_compile_definitions(pico_cpppkg_included INTERFACE
        -DPICO_cpppkg=1
        )

pico_add_platform_library(pico_cpppkg_included)

# note as we're a .cmake included by the SDK, we're relative to the pico-sdk build
add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/src ${CMAKE_BINARY_DIR}/pico_cpppkg/src)

if (PICO_cpppkg_TESTS_ENABLED OR PICO_cpppkg_TOP_LEVEL_PROJECT)
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/test ${CMAKE_BINARY_DIR}/pico_cpppkg/test)
endif ()


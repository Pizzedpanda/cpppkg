if (NOT TARGET pico_DHT11)
    add_library(pico_DHT11 INTERFACE)
    target_sources(pico_DHT11 INTERFACE
            ${CMAKE_CURRENT_LIST_DIR}/DHT11.cpp
    )

    target_include_directories(pico_DHT11 INTERFACE ${CMAKE_CURRENT_LIST_DIR}/include)
    target_link_libraries(pico_DHT11 INTERFACE pico_stdlib hardware_spi hardware_interp )
endif()
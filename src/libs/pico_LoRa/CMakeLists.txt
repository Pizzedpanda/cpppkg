if (NOT TARGET pico_LoRa)
    add_library(pico_LoRa INTERFACE)
    target_sources(pico_LoRa INTERFACE
            ${CMAKE_CURRENT_LIST_DIR}/LoRa.cpp
	    ${CMAKE_CURRENT_LIST_DIR}/Print.cpp
    )

    target_include_directories(pico_LoRa INTERFACE ${CMAKE_CURRENT_LIST_DIR}/include)
    target_link_libraries(pico_LoRa INTERFACE pico_stdlib hardware_spi hardware_interp )
endif()
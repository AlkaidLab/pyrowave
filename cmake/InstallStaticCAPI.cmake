# SPDX-License-Identifier: GPL-3.0-only

function(pyrowave_install_static_c_api)
    # Include the existing dependency objects in the installed archive rather
    # than exporting Granite's source-tree-only targets and headers.
    get_target_property(_pending pyrowave-c-api-static LINK_LIBRARIES)
    get_target_property(_build_interface pyrowave-c-api-static INTERFACE_LINK_LIBRARIES)
    set(_visited)
    set(_system_links)
    while(_pending)
        list(POP_FRONT _pending _dependency)
        if(_dependency MATCHES "^\\$<(BUILD_INTERFACE|LINK_ONLY):([^<>]+)>$")
            set(_dependency "${CMAKE_MATCH_2}")
        endif()
        if(NOT TARGET "${_dependency}")
            list(APPEND _system_links "${_dependency}")
            continue()
        endif()
        get_target_property(_alias "${_dependency}" ALIASED_TARGET)
        if(_alias)
            set(_dependency "${_alias}")
        endif()
        if(_dependency IN_LIST _visited)
            continue()
        endif()
        list(APPEND _visited "${_dependency}")
        get_target_property(_type "${_dependency}" TYPE)
        if(_type STREQUAL "STATIC_LIBRARY" OR _type STREQUAL "OBJECT_LIBRARY")
            target_sources(pyrowave-c-api-static PRIVATE "$<TARGET_OBJECTS:${_dependency}>")
            get_target_property(_links "${_dependency}" LINK_LIBRARIES)
        elseif(_type STREQUAL "INTERFACE_LIBRARY")
            get_target_property(_links "${_dependency}" INTERFACE_LINK_LIBRARIES)
        else()
            message(FATAL_ERROR "The installed static C API requires static dependencies: ${_dependency}")
        endif()
        if(_links)
            list(APPEND _pending ${_links})
        endif()
    endwhile()
    if(_system_links)
        list(REMOVE_DUPLICATES _system_links)
    endif()
    set_property(TARGET pyrowave-c-api-static PROPERTY INTERFACE_LINK_LIBRARIES
            "$<BUILD_INTERFACE:${_build_interface}>;${_system_links}")

    install(TARGETS pyrowave-c-api-static EXPORT pyrowave-staticConfig
            ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})
    install(EXPORT pyrowave-staticConfig NAMESPACE Pyrowave::
            DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/pyrowave-static)
    install(DIRECTORY
            "${PYROWAVE_GRANITE_SOURCE_DIR}/third_party/khronos/vulkan-headers/include/vulkan"
            "${PYROWAVE_GRANITE_SOURCE_DIR}/third_party/khronos/vulkan-headers/include/vk_video"
            DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/pyrowave)
    install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/NOTICE.md"
            DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/licenses/pyrowave)
    install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/LICENSES"
            DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/licenses/pyrowave)
    install(FILES "${PYROWAVE_GRANITE_SOURCE_DIR}/LICENSE"
            DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/licenses/pyrowave/Granite)
    install(FILES "${PYROWAVE_GRANITE_SOURCE_DIR}/third_party/volk/LICENSE.md"
            DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/licenses/pyrowave/volk)
    install(FILES "${PYROWAVE_GRANITE_SOURCE_DIR}/third_party/khronos/vulkan-headers/LICENSE.md"
            DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/licenses/pyrowave/Vulkan-Headers)
endfunction()

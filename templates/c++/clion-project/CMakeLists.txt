cmake_minimum_required(VERSION 3.16)

set(PROJECT_NAME "PROJECT-NAME")
set(PROJECT_VERSION "0.0.0")


set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

############################
##  Project configuration ##
############################

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -pedantic")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D DEBUG -D LOCAL -D _GLIBCXX_DEBUG -D _GLIBCXX_DEBUG_PEDANTIC -D _FORTIFY_SOURCE=2")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address -fsanitize=undefined -fno-sanitize-recover=all -fstack-protector")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fstack-clash-protection -fstack-protector-all")

project(${PROJECT_NAME} VERSION ${PROJECT_VERSION} LANGUAGES CXX)
file(GLOB_RECURSE "${PROJECT_NAME}_SRC_FILES" CONFIGURE_DEPENDS
        "src/*.h"
        "src/*.cpp")

add_executable(${PROJECT_NAME} ${${PROJECT_NAME}_SRC_FILES})

############################
##  Modules and scripts   ##
############################

# Standard CMake modules

include(CTest)                          # Must be called before adding tests but after calling project(). This automatically calls enable_testing() and configures ctest targets when using Make/Ninja
include(CMakeDependentOption)           # This is a really useful scripts that creates options that depends on other options. It can even be used with generator expressions !
include(GNUInstallDirs)                 # This will define the default values for installation directories (all platforms even if named GNU)
include(InstallRequiredSystemLibraries) # Tell CMake that the `install` target needs to install required system libraries (eg: Windows SDK)
include(CMakePackageConfigHelpers)      # Helper to create relocatable packages

###############
##  Options  ##
###############

option(ENABLE_INSTALL
        "Should ${PROJECT_NAME} be added to the install list? Useful if included using add_subdirectory." ON)

set(${PROJECT_NAME}_INSTALL_CMAKEDIR "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}"
        CACHE STRING "Path to install ${PROJECT_NAME} Config*.cmake files to.")

###############
## Packaging ##
###############

if (ENABLE_INSTALL)
    # Use version checking helper provided by CMake so that users can
    # safely use a version number in their find_package calls
    write_basic_package_version_file(
            ${PROJECT_NAME}ConfigVersion.cmake
            VERSION ${PROJECT_VERSION}
            COMPATIBILITY SameMajorVersion)

    install(
            TARGETS ${PROJECT_NAME}
            EXPORT ${PROJECT_NAME}_Targets
            INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

    install(DIRECTORY src
            DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
            FILES_MATCHING PATTERN *.h)

    # This time, install all the exported targets under the
    # ${PROJECT_NAME}_Targets name.
    install(
            EXPORT ${PROJECT_NAME}_Targets
            NAMESPACE ${PROJECT_NAME}::
            FILE ${PROJECT_NAME}Targets.cmake
            DESTINATION ${${PROJECT_NAME}_INSTALL_CMAKEDIR})

    # So far we only installed the exported targets, now install the package config files.
    #
    # If you do not list headers in the PUBLIC_HEADER property, you will need to copy them using
    # `install(FILES)` or `install(DIRECTORY)` too.
    #
    # In that case, you can use CMAKE_INSTALL_INCLUDEDIR as the base destination path.
    install(FILES
            ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
            DESTINATION ${${PROJECT_NAME}_INSTALL_CMAKEDIR})
endif ()
find_package(Arcus 1.1 REQUIRED)

set(extra_cmake_args "")
set(cmake_generator "${CMAKE_GENERATOR}")
if(BUILD_OS_WINDOWS)
    set(extra_cmake_args -DArcus_DIR=${CMAKE_PREFIX_PATH}/lib-mingw/cmake/Arcus
                         -DCMAKE_LIBRARY_PATH=${CMAKE_PREFIX_PATH}/lib-mingw)
    set(cmake_generator "MinGW Makefiles")
elseif (BUILD_OS_OSX)
    if (CMAKE_OSX_DEPLOYMENT_TARGET)
        list(APPEND extra_cmake_args
            -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET})
    endif()
    if (CMAKE_OSX_SYSROOT)
        list(APPEND extra_cmake_args
            -DCMAKE_OSX_SYSROOT=${CMAKE_OSX_SYSROOT})
    endif()
endif()

if (USE_CURAENGINE_ARTIFACT)
  if (BUILD_OS_WINDOWS)
    ExternalProject_Add(CuraEngine
      URL https://dl.cloudsmith.io/public/ultimaker/cura-public/raw/files/cura-curaengine-mingw-w64_4.5.0-1.zip
      BUILD_IN_SOURCE 1
      CONFIGURE_COMMAND ""
      BUILD_COMMAND ""
      INSTALL_COMMAND ${CMAKE_COMMAND} -E copy ${3rdParty_SUBDIR}/* ${CMAKE_INSTALL_PREFIX}
    )
  else()
    message(FATAL_ERROR "Using CuraEngine artifact is only supported on Windows.")
  endif()
else()
  # Build CuraEngine
  ExternalProject_Add(CuraEngine
    GIT_REPOSITORY https://github.com/ultimaker/CuraEngine
    GIT_TAG origin/${CURAENGINE_BRANCH_OR_TAG}
    GIT_SHALLOW 1
    STEP_TARGETS update
    CMAKE_GENERATOR "${cmake_generator}"
    CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
               -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX}
               -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
               -DCURA_ENGINE_VERSION=${CURA_VERSION}
               -DENABLE_MORE_COMPILER_OPTIMIZATION_FLAGS=${CURAENGINE_ENABLE_MORE_COMPILER_OPTIMIZATION_FLAGS}
               -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON
               ${extra_cmake_args}
  )
endif()

SetProjectDependencies(TARGET CuraEngine)

add_dependencies(update CuraEngine-update)

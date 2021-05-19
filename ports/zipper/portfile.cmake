find_program(GIT git)

set(GIT_URL "https://github.com/sebastiandev/zipper.git")
set(GIT_REV "155e17347b64f7182985a2772ebb179184e4f518")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/zipper)
file(MAKE_DIRECTORY ${SOURCE_PATH})

set(ZLIB_LIB_PATH ${VCPKG_ROOT_DIR}/packages/zlib_${TARGET_TRIPLET}/lib/zlib.lib)
set(ZLIB_INCLUDE_PATH ${VCPKG_ROOT_DIR}/packages/zlib_${TARGET_TRIPLET}/include)

if(NOT EXISTS "${SOURCE_PATH}/.git")
  # vcpkg_from_github doesn't fetch submodules
  #
  # Note: Zipper uses a minizip fork that isn't packaged yet in vcpkg.
  #    https://github.com/nmoinvaz/minizip
  message(STATUS "Cloning and fetching submodules")
  vcpkg_execute_required_process(
    COMMAND ${GIT} clone --recursive ${GIT_URL} ${SOURCE_PATH}
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME clone
  )

  message(STATUS "Checkout revision ${GIT_REV}")
  vcpkg_execute_required_process(
    COMMAND ${GIT} checkout ${GIT_REV}
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME checkout
  )
endif()

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DZLIB_LIBRARY:FILEPATH=${ZLIB_LIB_PATH}
    -DZLIB_INCLUDE_DIR:PATH=${ZLIB_INCLUDE_PATH}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

# NB: Paths are relative to ${CURRENT_PACKAGES_DIR}
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share/zipper)

# Copy over dependencies for all Targets zipper exports
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/zipperd.dll DESTINATION ${CURRENT_INSTALLED_DIR}/debug/bin)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/zipper.dll DESTINATION ${CURRENT_INSTALLED_DIR}/bin)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Zipper-test.exe DESTINATION ${CURRENT_INSTALLED_DIR}/tools/zipper)

file(REMOVE_RECURSE
  ${CURRENT_PACKAGES_DIR}/debug/include
  ${CURRENT_PACKAGES_DIR}/debug/share
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/zipper RENAME copyright)
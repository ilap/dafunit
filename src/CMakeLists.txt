set (PKGNAME dafunit)
set (PKGNAME_VERSION 0)
set (PKGNAME_SOVERSION 1)

#set (PREFIX ${CMAKE_INSTALL_PREFIX})
#set (DOLLAR "$")

find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.18.0" MINIMUM)
include(ValaPrecompile)

configure_file (${CMAKE_SOURCE_DIR}/${PKGNAME}.pc.cmake ${CMAKE_CURRENT_BINARY_DIR}/${PKGNAME}.pc)

install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKGNAME}.vapi DESTINATION ${CMAKE_INSTALL_PREFIX}/share/vala/vapi)
install (FILES ${CMAKE_SOURCE_DIR}/${PKGNAME}.deps DESTINATION ${CMAKE_INSTALL_PREFIX}/share/vala/vapi)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKGNAME}.pc DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/pkgconfig/)

################################################################################
# Sources
################################################################################
set (VALA_SOURCES
    AbstractTestCase.vala
    Assert.vala
    AsyncHelpers.vala
    SignalWaiter.vala
)

set (PKG_DEPS glib-2.0 gio-2.0 gee-0.8)
################################################################################

find_package (PkgConfig)
find_package (GObjectIntrospection 0.9.12)
include (GObjectIntrospectionMacros)

pkg_check_modules(DEPS REQUIRED ${PKG_DEPS})

set (CFLAGS ${DEPS_CFLAGS} ${DEPS_CFLAGS_OTHER})
add_definitions (${CFLAGS} "-DGETTEXT_PACKAGE=\"dafunit\"")
set (LIBS  ${DEPS_LIBRARIES})
set(LIB_PATHS ${DEPS_LIBRARY_DIRS})
link_directories(${LIB_PATHS})

vala_precompile(VALA_C
    ${VALA_SOURCES}
PACKAGES
    ${PKG_DEPS}
    posix
OPTIONS
    --thread
GENERATE_VAPI
    ${PKGNAME}
GENERATE_HEADER
    ${PKGNAME}
)

add_library (${PKGNAME} SHARED  ${VALA_C})
target_link_libraries(${PKGNAME} ${LIBS})

set_target_properties (${PKGNAME} PROPERTIES
    VERSION ${PKGNAME_VERSION}
    SOVERSION ${PKGNAME_SOVERSION}
)

install (TARGETS ${PKGNAME} DESTINATION ${CMAKE_INSTALL_PREFIX}/lib)

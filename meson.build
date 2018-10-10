project('dafunit', ['vala', 'c'],
    version : '0.1',
    license: 'GPL-3.0'
)

project_deps = [ 
	dependency('glib-2.0'),
	dependency('gio-2.0')
]

subdir('lib')

daf_deps = [project_deps]

daf_lib = library(
  meson.project_name(), 
  sources,
  vala_header: meson.project_name() + '.h',
  vala_vapi: meson.project_name() + '.vapi',
  vala_gir: meson.project_name() + '-' + meson.project_version () + '.gir',
  dependencies: daf_deps,
  install: true,
  #install_dir: ['lib64', 'include', 'share/vala/vapi', 'share/gir-1.0'])
  install_dir: [true, true, true, true]
)

daf_dep = declare_dependency(
      link_with: daf_lib,
      dependencies: daf_deps,
      include_directories: include_directories('.'),
)

pkg = import('pkgconfig')
pkg.generate(libraries : daf_lib,
                 version : meson.project_version(),
                 name : meson.project_name(),
                 filebase : meson.project_name(),
                 description : 'DaF\'s Unit Test Module',
)


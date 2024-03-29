# Project name, programming language and version
project (
    'io.github.alexkdeveloper.radio',
    'vala', 'c',
    version: '1.0.0'
)

gnome = import('gnome')
i18n = import ('i18n')

# Project arguments
add_global_arguments (
    '-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name ()),
    language: 'c'
)
add_global_arguments(
    ['--vapidir', meson.current_source_dir() / 'vapi'],
    language: 'vala'
)

conf = configuration_data()
# Get the package data directory under Meson
pkgdatadir = join_paths([ get_option('prefix'),
                          get_option('datadir'),
                          meson.project_name() ])

conf.set_quoted('PKGDATADIR', pkgdatadir)
conf.set_quoted('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))

# Other configs
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
add_global_arguments('-DDATADIR="' + get_option('datadir') + '"', language: 'c')
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

# Arguments for C
c_args = [
  '-include', 'config.h',
  '-w'
]

# Arguments for Vala
vala_args = ['--target-glib=2.50', meson.source_root() + '/vapi/config.vapi']

# Listing dependencies
dependencies = [
    dependency ('gio-2.0'),
    dependency ('gtk4'),
    dependency ('libadwaita-1'),
    dependency ('gstreamer-player-1.0'),
    dependency ('libpulse'),
    dependency ('libpulse-mainloop-glib'),
    dependency ('gobject-2.0'),
    dependency ('gee-0.8'),
    dependency ('libsoup-2.4'),
    dependency ('json-glib-1.0')
]

subdir ('src')

# Executable
executable (
    meson.project_name (),
    sources,
    dependencies: dependencies, 
    c_args: c_args, vala_args: vala_args,
    install: true
)

subdir ('data')
subdir('po')

gnome.post_install(
  glib_compile_schemas: true,
  gtk_update_icon_cache: true,
  update_desktop_database: true
)

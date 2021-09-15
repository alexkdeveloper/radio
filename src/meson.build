radio_sources = [
  'main.vala',
  'window.vala',
]

radio_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
  dependency('gstreamer-1.0'),
]

gnome = import('gnome')

radio_sources += gnome.compile_resources('radio-resources',
  'radio.gresource.xml',
  c_name: 'radio'
)

executable('radio', radio_sources,
  vala_args: '--target-glib=2.50',  dependencies: radio_deps,
  install: true,
)

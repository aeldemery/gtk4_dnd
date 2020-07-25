project ('github.aeldemery.gtk4_dnd', 
    'vala', 'c',
)

sources = files(
    'src/Main.vala',
    'src/CanvasItem.vala',
    'src/MainWindow.vala',
    'src/ColorSwatch.vala',
    'src/CssButton.vala',
)

dependencies = [
    dependency ('glib-2.0'),
    dependency ('gobject-2.0'),
    dependency ('gtk4'),
    meson.get_compiler('c').find_library('m', required: false),
]


sources += import( 'gnome' ).compile_resources(
    'project-resources',
    'data/' + meson.project_name() + '.gresource.xml',
    source_dir: 'data',
)

executable (
    meson.project_name(),
    sources: sources,
    dependencies: dependencies,
    install: true,
)
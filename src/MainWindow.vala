public class Gtk4Demo.MainWindow : Gtk.ApplicationWindow {
    public MainWindow (Gtk.Application app) {
        Object (application: app);
    }

    const string[] colors = {
        "red", "green", "blue", "magenta", "orange", "gray", "black", "yellow",
        "white", "gray", "brown", "pink", "cyan", "bisque", "gold", "maroon",
        "navy", "orchid", "olive", "peru", "salmon", "silver", "wheat"
    };

    construct {
        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/github/aeldemery/gtk4_dnd/dnd.css");
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), provider, 800);

        title = "Drag-and-Drop 2nd Incarnation";
        default_width = 640;
        default_height = 520;

        var main_vbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        var fixed = new Gtk.Fixed ();
        fixed.hexpand = true;
        fixed.vexpand = true;
        fixed.add_css_class ("frame");

        int x = 40;
        int y = 40;

        for (int i = 0; i < 4; i++) {
            var canvas_item = new CanvasItem ();
            fixed.put (canvas_item, x, y);

            x += 150;
            y += 100;
        }

        var h_sw = new Gtk.ScrolledWindow ();
        h_sw.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
        h_sw.vscrollbar_policy = Gtk.PolicyType.NEVER;

        var colors_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        colors_box.add_css_class ("linked");
        foreach (var color in colors) {
            var swatch = new ColorSwatch (color);
            colors_box.append (swatch);
        }
        colors_box.append (new CssButton ("rainbow1"));
        colors_box.append (new CssButton ("rainbow2"));
        colors_box.append (new CssButton ("rainbow3"));

        h_sw.set_child (colors_box);

        main_vbox.append (fixed);
        main_vbox.append (h_sw);

        this.set_child (main_vbox);
    }
}
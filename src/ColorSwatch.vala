public class Gtk4Demo.ColorSwatch : Gtk.Widget {
    Gdk.RGBA color { get; set; default = { 1, 1, 1, 1 }; }

    public ColorSwatch (string color_str) {
        // I don't know why the member variable color don't get parsed,
        // I have to create a local variable and copy it back to color
        Gdk.RGBA c = {};
        c.parse (color_str);
        color = c;

        var source = new Gtk.DragSource ();
        // source.prepare.connect (drag_prepare);
        source.content = new Gdk.ContentProvider.for_value (color);
        this.add_controller (source);
        this.set_css_name ("colorswatch");
    }

    construct {
    }

    /**
     * The ::prepare signal is emitted when a drag is about to be initiated.
     * It returns the * GdkContentProvider to use for the drag that is about to start.
     * The default handler for this signal returns the value of the “content” property,
     * so if you set up that property ahead of time, you don't need to connect to this signal.
     */
    //  Gdk.ContentProvider drag_prepare (Gtk.DragSource source, double x, double y) {
    //      return new Gdk.ContentProvider.for_value (color);
    //  }

    protected override void snapshot (Gtk.Snapshot snapshot) {
        var w = this.get_width ();
        var h = this.get_height ();

        snapshot.append_color (color, { { 0, 0 }, { w, h } });
    }

    protected override void measure (Gtk.Orientation orientation,
                                     int for_size,
                                     out int minimum_size,
                                     out int natural_size,
                                     out int minimum_baseline,
                                     out int natural_baseline) {
        if (orientation == Gtk.Orientation.HORIZONTAL) {
            minimum_size = natural_size = 48;
        } else {
            minimum_size = natural_size = 32;
        }
        minimum_baseline = natural_baseline = -1;
    }
}
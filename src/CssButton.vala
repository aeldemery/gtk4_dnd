public class Gtk4Demo.CssButton : Gtk.Widget {
    private Gtk.Image image;
    private string css_class;

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    construct {
        image = new Gtk.Image ();
        image.set_size_request (48, 32);

        var source = new Gtk.DragSource ();
        source.prepare.connect (drag_prepare);
        image.add_controller (source);

        image.set_parent (this);
    }

    public CssButton (string css_class) {
        this.css_class = css_class;
        image.add_css_class (css_class);
    }

    protected override void dispose () {
        image.unparent ();
        
        base.dispose();
    }

    Gdk.ContentProvider drag_prepare (Gtk.DragSource source, double x, double y) {
        var paintable = new Gtk.WidgetPaintable (image);
        source.set_icon (paintable, 0, 0);
        return new Gdk.ContentProvider.for_value (css_class);
    }
}
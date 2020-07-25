public class Gtk4Demo.CanvasItem : Gtk.Widget {
    private Gtk.Label label;
    private Gtk.Entry entry;
    private Gtk.Scale scale;
    private Gtk.Fixed fixed;

    double angle = 0;
    double delta = 0;

    public double center { get; set; default = 0; }

    static uint item_id;

    construct {
        ++item_id;
        var layout = new Gtk.BoxLayout (Gtk.Orientation.VERTICAL);
        layout.spacing = 5;
        this.set_layout_manager (layout);
        this.set_css_name ("item");

        label = new Gtk.Label (@"Item $item_id");
        label.name = @"item$item_id";
        label.add_css_class ("canvasitem");
        label.add_css_class ("frame");

        Gdk.RGBA color;
        color.parse ("yellow");
        set_label_color (color);

        entry = new Gtk.Entry ();
        entry.visible = false;
        entry.width_chars = 12;
        entry.text = label.label;
        entry.changed.connect ((editable) => {
            label.label = editable.get_text ();
            apply_transform ();
        });

        fixed = new Gtk.Fixed ();
        fixed.put (label, 0, 0);

        scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 360, 1);
        scale.draw_value = false;
        scale.set_value (Math.fmod (this.angle, 360));
        scale.visible = false;
        scale.value_changed.connect ((range) => {
            this.angle = range.get_value ();
            apply_transform ();
        });

        var rotate_gesture = new Gtk.GestureRotate ();
        rotate_gesture.angle_changed.connect ((gesture, ang, delt) => {
            this.delta = this.angle / Math.PI * 180;
            apply_transform ();
        });
        rotate_gesture.end.connect ((gesture, sequence) => {
            this.angle = this.angle + this.delta;
            this.delta = 0;
        });
        this.add_controller (rotate_gesture);

        var dest = new Gtk.DropTarget (GLib.Type.INVALID, Gdk.DragAction.COPY);
        dest.set_gtypes ({ typeof (Gdk.RGBA), typeof (string) });
        dest.on_drop.connect ((destination, value, x, y) => {
            if (value.type () == typeof (Gdk.RGBA)) {
                set_label_color ((Gdk.RGBA)value);
            } else if (value.type () == typeof (string)) {
                set_label_css ((string) value);
            }
        });
        label.add_controller (dest);

        var click_gesture = new Gtk.GestureClick ();
        click_gesture.released.connect ((gest, n_press, x, y) => {
            if (entry.visible == true && scale.visible == true) {
                entry.visible = false;
                scale.visible = false;
            } else {
                entry.visible = true;
                scale.visible = true;
                entry.grab_focus ();
            }
        });
        fixed.add_controller (click_gesture);

        fixed.set_parent (this);
        entry.set_parent (this);
        scale.set_parent (this);
    }

    public void start_editing () {
        entry.visible = true;
        scale.visible = true;
        entry.grab_focus ();
    }

    public void stop_editing () {
        entry.visible = false;
        scale.visible = false;
    }

    protected override void dispose () {
        fixed.unparent ();
        entry.unparent ();
        scale.unparent ();

        base.dispose ();
    }

    void apply_transform () {
        var x = label.get_allocated_width () / 2.0f;
        var y = label.get_allocated_height () / 2.0f;
        center = Math.sqrt (x * x + y * y);

        var transform = new Gsk.Transform ();
        transform = transform.translate ({ (float) center, (float) center });
        transform = transform.rotate ((float) angle + (float) delta);
        transform = transform.translate ({ -x, -y });

        fixed.set_child_transform (label, transform);
    }

    void set_label_color (Gdk.RGBA color) {
        var color_str = color.to_string ();
        var css_str = @"* { background: $color_str; }";

        var context = label.get_style_context ();
        var provider = context.get_data<Gtk.CssProvider>("style-provider");
        if (provider != null) {
            context.remove_provider (provider);
        }

        var old_class = label.get_data<string>("css-class");
        if (old_class != null) {
            label.remove_css_class (old_class);
        }

        provider = new Gtk.CssProvider ();
        provider.load_from_buffer (css_str.data);

        label.get_style_context ().add_provider (provider, 800);

        context.set_data<Gtk.CssProvider>("style-provider", provider);
    }

    void set_label_css (string css_class) {
        var context = label.get_style_context ();
        var provider = context.get_data<Gtk.CssProvider>("style-provider");
        if (provider != null) {
            context.remove_provider (provider);
        }

        var old_css_class = label.get_data<string>("css-class");
        if (old_css_class != null) {
            label.remove_css_class (old_css_class);
        }

        label.set_data<string>("css-class", css_class);
        label.add_css_class (css_class);
    }

    protected override void map () {
        base.map ();
        apply_transform ();
    }

    public Gdk.Paintable get_drag_icon () {
        return new Gtk.WidgetPaintable (fixed);
    }
}
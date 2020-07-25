public class Gtk4Demo.MainWindow : Gtk.ApplicationWindow {

    Gtk.Fixed fixed;

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

        fixed = new Gtk.Fixed ();
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

        ///////////////////////////////
        var source = new Gtk.DragSource ();
        source.prepare.connect ((source_origin, x, y) => {
            print ("Drag Prepare\n");
            var fixed_widget = source_origin.get_widget ();
            var picked_widget = fixed_widget.pick (x, y, Gtk.PickFlags.DEFAULT);
            var item = picked_widget.get_ancestor (typeof (CanvasItem));
            if (item == null) return null;
            fixed_widget.set_data<CanvasItem>("dragged-item", (CanvasItem) item);
            return new Gdk.ContentProvider.for_value (item);
        });
        source.drag_begin.connect ((source_origin, drag) => {
            print ("Drag Begin\n");
            var fixed_widget = source_origin.get_widget ();
            var item = fixed_widget.get_data<CanvasItem>("dragged-item");
            var paintable = item.get_drag_icon ();
            source_origin.set_icon (paintable, (int) item.center, (int) item.center);
            item.set_opacity (0.3);
        });
        source.drag_end.connect ((source_origin, drag, delete_data) => {
            print ("Drag End\n");
            var fixed_widget = source_origin.get_widget ();
            var item = fixed_widget.get_data<CanvasItem>("dragged-item");
            item.set_opacity (1.0);
            fixed_widget.set_data ("dragged-item", null);
        });
        source.drag_cancel.connect ((source_origin, drag, reason) => {
            print ("Drag Cancel\n");
            return false;
        });
        fixed.add_controller (source);

        var target = new Gtk.DropTarget (typeof (CanvasItem), Gdk.DragAction.MOVE);
        target.on_drop.connect ((drop_target, value, x, y) => {
            print ("Drag Drop\n");
            var item = (CanvasItem) value;
            print ("%p\n", item);
            var fixed_parent = (Gtk.Fixed)drop_target.get_widget ();
            print ("x = %f, y = %f\n", x, y);
            fixed_parent.move (item, x, y);
            return true;
        });
        fixed.add_controller (target);

        var gesture_click = new Gtk.GestureClick ();
        gesture_click.set_button (0);
        gesture_click.pressed.connect ((gesture, n_press, x, y) => {
            print ("Gesture Pressed\n");
            var fixed_widget = gesture.get_widget ();
            var picked_widget = fixed_widget.pick (x, y, Gtk.PickFlags.DEFAULT);
            var item = picked_widget.get_ancestor (typeof (CanvasItem));

            if (gesture.get_current_button () == Gdk.BUTTON_SECONDARY) {
                var menu = new Gtk.Popover ();
                menu.set_parent (fixed_widget);
                menu.has_arrow = false;
                menu.pointing_to = { (int) x, (int) y, 1, 1 };

                var menu_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
                menu.set_child (menu_box);

                var button = new Gtk.Button.with_label ("New");
                button.has_frame = false;
                button.clicked.connect (new_item_cb);
                menu_box.append (button);

                menu_box.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

                button = new Gtk.Button.with_label ("Edit");
                button.has_frame = false;
                button.sensitive = item != null && item != fixed_widget;
                button.clicked.connect (edit_item_cb);
                menu_box.append (button);

                menu_box.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

                button = new Gtk.Button.with_label ("Delete");
                button.has_frame = false;
                button.sensitive = item != null && item != fixed_widget;
                button.clicked.connect (delete_item_cb);
                menu_box.append (button);

                menu.popup ();
            }
        });
        fixed.add_controller (gesture_click);

        this.set_child (main_vbox);
    }

    void new_item_cb (Gtk.Button btn) {
        var popover = (Gtk.Popover)btn.get_ancestor (typeof (Gtk.Popover));
        Gdk.Rectangle rect = {};
        rect = popover.pointing_to;
        var item = new CanvasItem ();
        fixed.put (item, rect.x, rect.y);
        popover.popdown ();
    }

    void edit_item_cb (Gtk.Button btn) {
        var popover = (Gtk.Popover)btn.get_ancestor (typeof (Gtk.Popover));
        popover.popdown ();
        Gdk.Rectangle rect = {};
        rect = popover.pointing_to;

        var picked_widget = fixed.pick (rect.x, rect.y, Gtk.PickFlags.DEFAULT);
        var item = (CanvasItem) picked_widget.get_ancestor (typeof (CanvasItem));
        if (item != null) {
            item.start_editing ();
        }
    }

    void delete_item_cb (Gtk.Button btn) {
        var popover = (Gtk.Popover)btn.get_ancestor (typeof (Gtk.Popover));
        popover.popdown ();
        Gdk.Rectangle rect = {};
        rect = popover.pointing_to;

        var picked_widget = fixed.pick (rect.x, rect.y, Gtk.PickFlags.DEFAULT);
        var item = (CanvasItem) picked_widget.get_ancestor (typeof (CanvasItem));
        if (item != null) {
            fixed.remove(item);
        }
    }
}
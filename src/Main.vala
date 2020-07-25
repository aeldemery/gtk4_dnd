int main (string[] args) {
    Intl.setlocale ();
    var dnd_app = new Gtk4Demo.DNDApp ();
    return dnd_app.run (args);
}

public class Gtk4Demo.DNDApp : Gtk.Application {
    public DNDApp () {
        Object (
            application_id: "github.aeldemery.gtk4_dnd",
            flags : GLib.ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var win = active_window;
        if (win == null) {
            win = new Gtk4Demo.MainWindow (this);
        }
        win.present ();
    }
}
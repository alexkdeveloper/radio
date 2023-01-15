
using Gtk;
using Gst;

namespace Radio {

    public class MainWindow : Adw.ApplicationWindow {

private Box box;
private Box search_box;
private dynamic Element player;
private ListBox list_box;
private SearchEntry entry_search;
private Button play_button;
private Button stop_button;
private Button record_button;
private Button stop_record_button;
private Label current_station;
private Recorder recorder;
private Adw.ToastOverlay overlay;
private string item;
private string sub_item;

        public MainWindow(Adw.Application application) {
            GLib.Object(application: application,
                         title: "Radio",
                         resizable: true,
                         default_height: 500);
        }

        construct {
        var search_button = new Gtk.Button ();
            search_button.set_icon_name ("edit-find-symbolic");
            search_button.vexpand = false;
        play_button = new Gtk.Button();
            play_button.set_icon_name ("media-playback-start-symbolic");
            play_button.vexpand = false;
        stop_button = new Gtk.Button();
            stop_button.set_icon_name ("media-playback-stop-symbolic");
            stop_button.vexpand = false;
        record_button = new Gtk.Button();
            record_button.set_icon_name ("media-record-symbolic");
            record_button.vexpand = false;
        stop_record_button = new Gtk.Button();
            stop_record_button.set_icon_name ("process-stop-symbolic");
            stop_record_button.vexpand = false;
        var menu_button = new Gtk.MenuButton();
            menu_button.set_icon_name ("open-menu-symbolic");
            menu_button.vexpand = false;

        play_button.set_tooltip_text(_("Play"));
        stop_button.set_tooltip_text(_("Stop"));
        record_button.set_tooltip_text(_("Start recording"));
        stop_record_button.set_tooltip_text(_("Stop recording"));
        search_button.set_tooltip_text (_("Search"));

        record_button.clicked.connect(on_record_clicked);
        stop_record_button.clicked.connect(on_stop_record_clicked);
        play_button.clicked.connect(on_play_station);
        stop_button.clicked.connect(on_stop_station);
        search_button.clicked.connect(()=>{
               on_search_clicked();
            });
        var headerbar = new Adw.HeaderBar();
        headerbar.pack_start(search_button);
        headerbar.pack_end(menu_button);
        headerbar.pack_end(record_button);
        headerbar.pack_end(stop_record_button);
        headerbar.pack_end(stop_button);
        headerbar.pack_end(play_button);
        var open_directory_action = new GLib.SimpleAction ("open", null);
        open_directory_action.activate.connect (on_open_directory_clicked);
        var go_to_website_action = new GLib.SimpleAction ("website", null);
        go_to_website_action.activate.connect(on_start_browser_clicked);
        var about_action = new GLib.SimpleAction ("about", null);
        about_action.activate.connect (about);
        var quit_action = new GLib.SimpleAction ("quit", null);
        var app = GLib.Application.get_default();
        quit_action.activate.connect(()=>{
               app.quit();
            });
        app.add_action(open_directory_action);
        app.add_action(go_to_website_action);
        app.add_action(about_action);
        app.add_action(quit_action);
        var menu = new GLib.Menu();
        var item_website = new GLib.MenuItem (_("Go to the website radio-browser.info"), "app.website");
        var item_open = new GLib.MenuItem (_("Open the Records folder"), "app.open");
        var item_about = new GLib.MenuItem (_("About Radio"), "app.about");
        var item_quit = new GLib.MenuItem (_("Quit"), "app.quit");
        menu.append_item (item_website);
        menu.append_item (item_open);
        menu.append_item (item_about);
        menu.append_item (item_quit);
        var popover = new PopoverMenu.from_model(menu);
        menu_button.set_popover(popover);
        set_widget_visible(stop_record_button, false);
        set_widget_visible(stop_button,false);

        list_box = new Gtk.ListBox ();
        list_box.vexpand = true;
        list_box.add_css_class("boxed-list");
        list_box.row_selected.connect(on_select_item);
        var scroll = new Gtk.ScrolledWindow () {
            propagate_natural_height = true,
            propagate_natural_width = true
        };
        var clamp = new Adw.Clamp(){
            tightening_threshold = 100,
            margin_top = 5,
            margin_bottom = 5
        };
        clamp.set_child(list_box);

        scroll.set_child(clamp);

        entry_search = new SearchEntry();
        entry_search.hexpand = true;

        var start_search_button = new Button();
        start_search_button.set_icon_name("edit-find-symbolic");
        start_search_button.add_css_class("flat");
        search_box = new Box(Orientation.HORIZONTAL,5);
        search_box.margin_start = 30;
        search_box.margin_end = 30;
        search_box.append(entry_search);
        search_box.append(start_search_button);
        search_box.hide();
        start_search_button.clicked.connect(()=>{
            on_start_search_clicked();
        });
        current_station = new Label(_("Welcome!"));
        current_station.add_css_class("title-4");
	current_station.wrap = true;
        current_station.wrap_mode = WORD;
   box = new Box(Orientation.VERTICAL,5);
   box.margin_top = 10;
   box.append (search_box);
   box.append (current_station);
   box.append (scroll);

          overlay = new Adw.ToastOverlay();
          overlay.set_child(box);
          var main_box = new Box(Orientation.VERTICAL, 0);
          main_box.append(headerbar);
          main_box.append(overlay);
          set_content(main_box);

        player = ElementFactory.make ("playbin", "play");
        recorder = Recorder.get_default ();
        record_button.set_sensitive(false);
        show_stations();

    var event_controller = new Gtk.EventControllerKey ();
        event_controller.key_pressed.connect ((keyval, keycode, state) => {
            if (Gdk.ModifierType.CONTROL_MASK in state && keyval == Gdk.Key.q) {
                app.quit();
            }

             if (Gdk.ModifierType.CONTROL_MASK in state && (keyval == Gdk.Key.f || keyval == Gdk.Key.s)) {
                 on_search_clicked();
            }

            return false;
        });
        ((Gtk.Widget)this).add_controller(event_controller);
 }

 private void on_play_station(){
    var selection = list_box.get_selected_row();
           if (!selection.is_selected()) {
               set_toast(_("Please choose a station"));
               return;
           }
 player.uri = sub_item;
 player.set_state (State.PLAYING);
 current_station.set_text(_("Now playing: ")+item);
 set_widget_visible(play_button,false);
 set_widget_visible(stop_button,true);
 record_button.set_sensitive(true);
}

private void on_stop_station(){
 player.set_state (State.READY);
 current_station.set_text(_("Stopped"));
 set_widget_visible(play_button,true);
 set_widget_visible(stop_button,false);
 if(recorder.is_recording){
     on_stop_record_clicked();
 }
 record_button.set_sensitive(false);
}

private void on_record_clicked(){
    var selection = list_box.get_selected_row();
    if (!selection.is_selected()) {
        set_toast(_("Please choose a station"));
        return;
    }
try {
   recorder.start_recording();
 } catch (Gst.ParseError e) {
    alert("",e.message);
    return;
 }
 set_widget_visible(record_button,false);
 set_widget_visible(stop_record_button,true);
}

private void on_stop_record_clicked(){
   recorder.stop_recording();
   set_widget_visible(record_button,true);
   set_widget_visible(stop_record_button,false);
}

   private void on_start_browser_clicked(){
       var start_browser_dialog = new Adw.MessageDialog(this, _("Do you want to visit the website radio-browser.info?"), "");
            start_browser_dialog.add_response("cancel", _("_Cancel"));
            start_browser_dialog.add_response("ok", _("_OK"));
            start_browser_dialog.set_default_response("ok");
            start_browser_dialog.set_close_response("cancel");
            start_browser_dialog.set_response_appearance("ok", SUGGESTED);
            start_browser_dialog.show();
            start_browser_dialog.response.connect((response) => {
                if (response == "ok") {
                    Gtk.show_uri(this, "https://www.radio-browser.info/", Gdk.CURRENT_TIME);
                }
                start_browser_dialog.close();
            });
       }
   
   private void on_open_directory_clicked(){
      Gtk.show_uri(this, "file://"+Environment.get_user_data_dir(), Gdk.CURRENT_TIME);
  }  

  private void on_start_search_clicked(){
         if(entry_search.text.length>=3){
                 show_stations();
              }else{
                 set_toast(_("Enter 3 or more characters"));
            }
    }

    private void on_search_clicked(){
           if(search_box.is_visible()){
                  search_box.hide();
               }else{
                  search_box.show();
                  entry_search.grab_focus();
               }
        }

   private void on_select_item () {
           var selection = list_box.get_selected_row();
           if (!selection.is_selected()) {
               return;
           }
          GLib.Value value_item = "";
          GLib.Value value_sub_item = "";
          selection.get_property("title", ref value_item);
          selection.get_property("subtitle", ref value_sub_item);
          item = value_item.get_string();
          sub_item = value_sub_item.get_string();
          recorder.station_name = item;
       }

   private void show_stations () {
          for (
            var child = (Gtk.ListBoxRow) list_box.get_last_child ();
                child != null;
                child = (Gtk.ListBoxRow) list_box.get_last_child ()
        ) {
            list_box.remove(child);
        }
        var list_title = new GLib.List<string>();
        var list_sub_title = new GLib.List<string>();
          try{
          var client = new Client();
          var stations = client.get_stations ("/json/stations");
             foreach (var station in stations) {
                if(search_box.is_visible()){
                    if(station.name.down().contains(entry_search.get_text().down())){
                       list_title.append(station.name);
                       list_sub_title.append(station.url_resolved);
                    }
                    }else{
                       list_title.append(station.name);
                       list_sub_title.append(station.url_resolved);
                }
                if(list_title.length()==100){
                   break;
                }
            }
        } catch (DataError err) {
            stderr.printf (err.message);
        }
        for(int i=0;i<100;i++){
             var row = new Adw.ActionRow () {
                title = list_title.nth_data(i),
                subtitle = list_sub_title.nth_data(i)
                };
           if(list_sub_title.nth_data(i) != ""){
               list_box.append(row);
            }
        }
    }

   private void set_widget_visible (Gtk.Widget widget, bool visible) {
         widget.visible = !visible;
         widget.visible = visible;
  }

    private void about () {
	        var win = new Adw.AboutWindow () {
                application_name = "Radio",
                application_icon = "com.github.alexkdeveloper.radio",
                version = "1.0.0",
                copyright = "Copyright © 2023 Alex Kryuchkov",
                license_type = License.GPL_3_0,
                developer_name = "Alex Kryuchkov",
                developers = {"Alex Kryuchkov https://github.com/alexkdeveloper"},
                translator_credits = _("translator-credits"),
                website = "https://github.com/alexkdeveloper/radio",
                issue_url = "https://github.com/alexkdeveloper/radio/issues"
            };
            win.set_transient_for (this);
            win.show ();
        }
   private void set_toast (string str){
       var toast = new Adw.Toast(str);
       toast.set_timeout(3);
       overlay.add_toast(toast);
   }
   private void alert (string heading, string body){
            var dialog_alert = new Adw.MessageDialog(this, heading, body);
            if (body != "") {
                dialog_alert.set_body(body);
            }
            dialog_alert.add_response("ok", _("_OK"));
            dialog_alert.set_response_appearance("ok", SUGGESTED);
            dialog_alert.response.connect((_) => { dialog_alert.close(); });
            dialog_alert.show();
        }
   }
}

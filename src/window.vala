/* window.vala
 *
 * Copyright 2021 Alex
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
using Gtk;
using Gst;
namespace Radio {
	[GtkTemplate (ui = "/com/github/alexkdeveloper/radio/window.ui")]
public class Window : Gtk.ApplicationWindow {
	    [GtkChild]
		unowned Stack stack;
		[GtkChild]
        unowned ScrolledWindow list_page;
        [GtkChild]
        unowned Box edit_page;
        [GtkChild]
        unowned Gtk.ListStore list_store;
        [GtkChild]
        unowned TreeView tree_view;
        [GtkChild]
        unowned Entry entry_name;
        [GtkChild]
        unowned Entry entry_url;
        [GtkChild]
        unowned Button back_button;
        [GtkChild]
        unowned Button add_button;
        [GtkChild]
        unowned Button delete_button;
        [GtkChild]
        unowned Button edit_button;
        [GtkChild]
        unowned Button play_button;
        [GtkChild]
        unowned Button stop_button;
        [GtkChild]
        unowned Button ok_button;
        private List<string> list;
        private dynamic Element player;
        private string directory_path;
        private string item;
        private int mode;
		public Window (Gtk.Application app) {
			GLib.Object (application: app);
			set_widget_visible(back_button,false);
            set_widget_visible(stop_button,false);
			entry_name.set_icon_from_icon_name (EntryIconPosition.SECONDARY, "edit-clear-symbolic");
        entry_name.icon_press.connect ((pos, event) => {
        if (pos == EntryIconPosition.SECONDARY) {
              entry_name.set_text("");
           }
        });
        entry_url.set_icon_from_icon_name (EntryIconPosition.SECONDARY, "edit-clear-symbolic");
        entry_url.icon_press.connect ((pos, event) => {
        if (pos == EntryIconPosition.SECONDARY) {
              entry_url.set_text("");
           }
        });
            back_button.clicked.connect(on_back_clicked);
            add_button.clicked.connect(on_add_clicked);
            delete_button.clicked.connect(on_delete_dialog);
            edit_button.clicked.connect(on_edit_clicked);
            play_button.clicked.connect(on_play_station);
            stop_button.clicked.connect(on_stop_station);
            ok_button.clicked.connect(on_ok_clicked);
            tree_view.cursor_changed.connect(on_select_item);
			player = ElementFactory.make ("playbin", "play");
            directory_path = Environment.get_home_dir()+"/.stations_for_radio_app";
   GLib.File file = GLib.File.new_for_path(directory_path);
   if(!file.query_exists()){
     try{
        file.make_directory();
     }catch(Error e){
        stderr.printf ("Error: %s\n", e.message);
     }
     create_default_stations();
   }
   show_stations();
		}
		private void on_play_station(){
         var selection = tree_view.get_selection();
           selection.set_mode(SelectionMode.SINGLE);
           TreeModel model;
           TreeIter iter;
           if (!selection.get_selected(out model, out iter)) {
               alert("Choose a station");
               return;
           }
      string uri;
        try {
            FileUtils.get_contents (directory_path+"/"+item, out uri);
        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }
      player.uri = uri;
      player.set_state (State.PLAYING);
      set_widget_visible(play_button,false);
      set_widget_visible(stop_button,true);
   }

   private void on_stop_station(){
      player.set_state (State.READY);
      set_widget_visible(play_button,true);
      set_widget_visible(stop_button,false);
   }

   private void on_select_item () {
           var selection = tree_view.get_selection();
           selection.set_mode(SelectionMode.SINGLE);
           TreeModel model;
           TreeIter iter;
           if (!selection.get_selected(out model, out iter)) {
               return;
           }
           TreePath path = model.get_path(iter);
           var index = int.parse(path.to_string());
           if (index >= 0) {
               item = list.nth_data(index);
           }
       }

   private void on_add_clicked () {
              stack.visible_child = edit_page;
              set_buttons_on_edit_page();
              mode = 1;
              if(!is_empty(entry_name.get_text())){
                    entry_name.set_text("");
              }
              if(!is_empty(entry_url.get_text())){
                    entry_url.set_text("");
              }
  }

   private void on_edit_clicked(){
         var selection = tree_view.get_selection();
           selection.set_mode(SelectionMode.SINGLE);
           TreeModel model;
           TreeIter iter;
           if (!selection.get_selected(out model, out iter)) {
               alert("Choose a station");
               return;
           }
        stack.visible_child = edit_page;
        set_buttons_on_edit_page();
        mode = 0;
        entry_name.set_text(item);
        string url;
        try {
            FileUtils.get_contents (directory_path+"/"+item, out url);
        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }
        entry_url.set_text(url);
   }

   private void on_ok_clicked(){
         if(is_empty(entry_name.get_text())){
		    alert("Enter the name");
                    entry_name.grab_focus();
                    return;
		}
		if(is_empty(entry_url.get_text())){
		   alert("Enter the url");
                   entry_url.grab_focus();
                   return;
		}
        switch(mode){
            case 0:
		GLib.File select_file = GLib.File.new_for_path(directory_path+"/"+item);
		GLib.File edit_file = GLib.File.new_for_path(directory_path+"/"+entry_name.get_text().strip());
		if (select_file.get_basename() != edit_file.get_basename() && !edit_file.query_exists()){
                FileUtils.rename(select_file.get_path(), edit_file.get_path());
                if(!edit_file.query_exists()){
                    alert("Rename failed");
                    return;
                }
                try {
                 FileUtils.set_contents (edit_file.get_path(), entry_url.get_text().strip());
              } catch (Error e) {
                     stderr.printf ("Error: %s\n", e.message);
            }
            }else{
                if (select_file.get_basename() != edit_file.get_basename()) {
                    alert("A station with the same name already exists");
                    entry_name.grab_focus();
                    return;
                }
                try {
                 FileUtils.set_contents (edit_file.get_path(), entry_url.get_text().strip());
              } catch (Error e) {
                     stderr.printf ("Error: %s\n", e.message);
             }
            }
            show_stations();
            break;
            case 1:
	GLib.File file = GLib.File.new_for_path(directory_path+"/"+entry_name.get_text().strip());
        if(file.query_exists()){
            alert("A station with the same name already exists");
            entry_name.grab_focus();
            return;
        }
        try {
            FileUtils.set_contents (file.get_path(), entry_url.get_text().strip());
        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }
        if(!file.query_exists()){
           alert("Add failed");
           return;
        }else{
           show_stations();
        }
        break;
      }
      on_back_clicked();
   }

   private void on_back_clicked(){
       stack.visible_child = list_page;
       set_buttons_on_list_page();
   }

   private void on_delete_dialog(){
       var selection = tree_view.get_selection();
           selection.set_mode(SelectionMode.SINGLE);
           TreeModel model;
           TreeIter iter;
           if (!selection.get_selected(out model, out iter)) {
               alert("Choose a station");
               return;
           }
           GLib.File file = GLib.File.new_for_path(directory_path+"/"+item);
         var dialog_delete_station = new Gtk.MessageDialog(this, Gtk.DialogFlags.MODAL,Gtk.MessageType.QUESTION, Gtk.ButtonsType.OK_CANCEL, "Delete station "+file.get_basename()+" ?");
         dialog_delete_station.set_title("Question");
         Gtk.ResponseType result = (ResponseType)dialog_delete_station.run ();
         dialog_delete_station.destroy();
         if(result==Gtk.ResponseType.OK){
         FileUtils.remove (directory_path+"/"+item);
         if(file.query_exists()){
            alert("Delete failed");
         }else{
             show_stations();
         }
      }
   }

   private void show_stations () {
           list_store.clear();
           list = new GLib.List<string> ();
            try {
            Dir dir = Dir.open (directory_path, 0);
            string? name = null;
            while ((name = dir.read_name ()) != null) {
                list.append(name);
            }
        } catch (FileError err) {
            stderr.printf (err.message);
        }
         TreeIter iter;
           foreach (string item in list) {
               list_store.append(out iter);
               list_store.set(iter, Columns.TEXT, item);
           }
       }

   private void set_widget_visible (Gtk.Widget widget, bool visible) {
         widget.no_show_all = !visible;
         widget.visible = visible;
  }

   private void set_buttons_on_list_page(){
       set_widget_visible(back_button,false);
       set_widget_visible(add_button,true);
       set_widget_visible(delete_button,true);
       set_widget_visible(edit_button,true);
   }

   private void set_buttons_on_edit_page(){
       set_widget_visible(back_button,true);
       set_widget_visible(add_button,false);
       set_widget_visible(delete_button,false);
       set_widget_visible(edit_button,false);
   }

   private bool is_empty(string str){
        return str.strip().length == 0;
      }

       private enum Columns {
           TEXT, N_COLUMNS
       }
   private void create_default_stations(){
          string[] name_station = {"NonStopPlay","Classical Music","Fip Radio","Jazz Legends","Joy Radio","Live-icy","Music Radio","Radio Electron","Dubstep","Trancemission"};
          string[] url_station = {"http://stream.nonstopplay.co.uk/nsp-128k-mp3","http://stream.srg-ssr.ch/m/rsc_de/mp3_128","http://direct.fipradio.fr/live/fip-midfi.mp3","http://jazz128legends.streamr.ru/","http://airtime.joyradio.cc:8000/airtime_192.mp3","http://live-icy.gss.dr.dk:8000/A/A05H.mp3","http://ice-the.musicradio.com/CapitalXTRANationalMP3","http://radio-electron.ru:8000/128","http://air.radiorecord.ru:8102/dub_320","http://air.radiorecord.ru:8102/tm_320"};
          for(int i=0;i<10;i++){
            try {
                 FileUtils.set_contents (directory_path+"/"+name_station[i], url_station[i]);
              } catch (Error e) {
                     stderr.printf ("Error: %s\n", e.message);
             }
          }
   }
   private void alert (string str){
          var dialog_alert = new Gtk.MessageDialog(this, Gtk.DialogFlags.MODAL, Gtk.MessageType.INFO, Gtk.ButtonsType.OK, str);
          dialog_alert.set_title("Message");
          dialog_alert.run();
          dialog_alert.destroy();
       }
	}
}

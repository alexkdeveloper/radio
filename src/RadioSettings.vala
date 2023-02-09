public abstract class RadioSettings {
    public static Settings settings = null;
    public static bool is_show_favorite_stations_at_startup;
    public static bool is_not_load_stations_at_startup;
    public static bool is_play_last_station_at_startup;

    public static void init () {
        settings = new Settings ("io.github.alexkdeveloper.radio");
        is_show_favorite_stations_at_startup = settings.get_boolean ("show-favorite-stations-at-startup");
        is_not_load_stations_at_startup = settings.get_boolean ("not-load-stations-at-startup");
        is_play_last_station_at_startup = settings.get_boolean ("play-last-station-at-startup");
    }
}

public abstract class RadioSettings {
    public static Settings settings = null;
    public static bool is_default_start_favorite_stations;
    public static bool is_not_load_stations_at_startup;

    public static void init () {
        settings = new Settings ("io.github.alexkdeveloper.radio");
        is_default_start_favorite_stations = settings.get_boolean ("default-start-favorite-stations");
        is_not_load_stations_at_startup = settings.get_boolean ("not-load-stations-at-startup");
    }
}

public abstract class RadioSettings {
    public static Settings settings = null;
    public static bool is_default_start_favorite_stations;

    public static void init () {
        settings = new Settings ("io.github.alexkdeveloper.radio");
        is_default_start_favorite_stations = settings.get_boolean ("default-start-favorite-stations");
    }
}

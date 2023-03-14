using Gee;

public errordomain DataError {
    PARSE_DATA,
    NO_CONNECTION
}

private const string[] DEFAULT_BOOTSTRAP_SERVERS = {
    "de1.api.radio-browser.info",
    "at1.api.radio-browser.info",
    "nl1.api.radio-browser.info"
};

public class Station : Object {
    public string name { get; set; }
    public string url { get; set; }
}

public bool EqualCompareString (string a, string b) {
    return a == b;
}

public int RandomSortFunc (string a, string b) {
    return Random.int_range (-1, 1);
}

public class Client : Object {
    private string current_server;
    private string USER_AGENT = @"io.github.alexkdeveloper.radio";
    private Soup.Session _session;
    private ArrayList<string> randomized_servers;
    public Client() throws DataError {
        Object();
        _session = new Soup.Session ();
        _session.user_agent = USER_AGENT;
        _session.timeout = 3;
        string[] servers;
        string _servers = GLib.Environment.get_variable ("RADIO_API");
        if ( _servers != null ){
            servers = _servers.split(":");
        } else {
            servers = DEFAULT_BOOTSTRAP_SERVERS;
        }
        randomized_servers = new ArrayList<string>.wrap (servers, EqualCompareString);
        randomized_servers.sort (RandomSortFunc);
        current_server = @"https://$(randomized_servers[0])";
        debug (@"Chosen radio-browser.info server: $current_server");
    }

    private Station jnode_to_station (Json.Node node) {
        return Json.gobject_deserialize (typeof (Station), node) as Station;
    }

    private ArrayList<Station> jarray_to_stations (Json.Array data) {
        var stations = new ArrayList<Station> ();

        data.foreach_element ((array, index, element) => {
            Station s = jnode_to_station (element);
            stations.add (s);
        });

        return stations;
    }

    public ArrayList<Station> get_stations (string resource) throws DataError {
        debug (@"RB $resource");

        var message = new Soup.Message ("GET", @"$current_server/$resource");
        Json.Node rootnode;

        var response_code = _session.send_message (message);
        debug (@"response from radio-browser.info: $response_code");
        var body = (string) message.response_body.data;
        if (body == null) {
            throw new DataError.NO_CONNECTION (@"unable to read response");
        }
        try {
            rootnode = Json.from_string (body);
        } catch (Error e) {
            throw new DataError.PARSE_DATA (@"unable to parse JSON response: $(e.message)");
        }
        var rootarray = rootnode.get_array ();

        var stations = jarray_to_stations (rootarray);
        return stations;
    }

     public ArrayList<Station> search (string text) throws DataError {
        var resource = @"json/stations/search?limit=200&offset=0";
        if (text != null && text != "") {
            resource += @"&name=$(text)";
        }
        return get_stations (resource);
    }
  }

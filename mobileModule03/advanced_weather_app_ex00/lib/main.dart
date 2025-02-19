import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  String? _currentlyData;
  String? _todayData;
  String? _weeklyData;

  TabController? _tabController;
  String _selectedLocation = '';
  String query = '';
  bool _hasInternet = true;
  String _errorMessage = "";

  Future<void> _searchCity(String query) async {
    final url =
        'https://nominatim.openstreetmap.org/search?format=json&q=$query';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _searchResults = data;
        _errorMessage = "";
      });
    } else {
      setState(() {
        _errorMessage = "An error occurred while retrieving city data.";
      });
    }
  }

  void _setDatas(double lat, double lon) {
    _getCurrentlyData(lat, lon);
    _getTodayData(lat, lon);
    _getWeeklyData(lat, lon);
  }

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi);
  }

  void checkConnectionStatus() async {
    bool isConnected = await checkInternetConnection();
    _hasInternet = isConnected;
  }

  Future<void> _getCurrentlyData(double lat, double lon) async {
    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _currentlyData =
            "Temperature: ${data['current_weather']['temperature']}°C\n"
            "Wind Speed: ${data['current_weather']['windspeed']} km/h";
      });
    } else {
      setState(() {
        _currentlyData = "Weather data could not be fetched.";
      });
    }
  }

  Future<void> _getTodayData(double lat, double lon) async {
    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon'
        '&hourly=temperature_2m,windspeed_10m&timezone=auto';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List<dynamic> hourlyTimes = data['hourly']['time'];
      List<dynamic> temperatures = data['hourly']['temperature_2m']; // Sıcaklık
      List<dynamic> windSpeeds = data['hourly']['windspeed_10m']; // Rüzgar hızı

      String weatherInfo = "";

      for (int i = 0; i < hourlyTimes.length; i++) {
        weatherInfo += "${hourlyTimes[i].split("T")[1]}"
            "        ${temperatures[i]}°C"
            "        ${windSpeeds[i]} km/h\n";
      }

      setState(() {
        _todayData = weatherInfo;
      });
    } else {
      setState(() {
        _todayData = "Weather data could not be fetched.";
      });
    }
  }

  Future<void> _getWeeklyData(double lat, double lon) async {
    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&daily=weathercode,temperature_2m_max,temperature_2m_min&timezone=auto';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final daily = data['daily'];

      // Hava durumu kodlarını metne çevirmek için yardımcı fonksiyon
      String getWeatherCondition(int code) {
        switch (code) {
          case 0:
            return "Açık";
          case 1:
          case 2:
          case 3:
            return "Parçalı Bulutlu";
          case 45:
          case 48:
            return "Sisli";
          case 51:
          case 53:
          case 55:
            return "Hafif Yağmurlu";
          case 56:
          case 57:
          case 66:
          case 67:
            return "Donan Yağmur";
          case 61:
          case 63:
          case 65:
            return "Yağmurlu";
          case 71:
          case 73:
          case 75:
            return "Karlı";
          case 77:
            return "Kar Taneleri";
          case 80:
          case 81:
          case 82:
            return "Sağanak Yağışlı";
          case 85:
          case 86:
            return "Kar Fırtınası";
          case 95:
          case 96:
          case 99:
            return "Gök Gürültülü Fırtına";
          default:
            return "Bilinmeyen";
        }
      }

      // 7 günlük veriyi formatla
      String formattedData = "";
      for (int i = 0; i < daily['time'].length; i++) {
        formattedData +=
            "${daily['time'][i]}: Min ${daily['temperature_2m_min'][i]}°C, "
            "Max ${daily['temperature_2m_max'][i]}°C, "
            "${getWeatherCondition(daily['weathercode'][i])}\n";
      }

      setState(() {
        _weeklyData = formattedData;
      });
    } else {
      setState(() {
        _weeklyData = "Weather data could not be fetched.";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void onQueryChanged(String newQuery) {
    setState(() {
      query = newQuery;
    });
  }

  void setErrorMessage(String value) {
    setState(() {
      _errorMessage = value;
    });
  }

  String getErrorMessages() {
    checkConnectionStatus();
    if (!_hasInternet) {
      return ("The service connection is lost, please check your internet connection on try again later.");
    } else if (_errorMessage.isNotEmpty) {
      return (_errorMessage);
    } else if (_currentlyData == "Weather data could not be fetched." ||
        _todayData == "Weather data could not be fetched." ||
        _weeklyData == "Weather data could not be fetched.") {
      return ("Weather data could not be fetched.");
    }
    return ("");
  }

  Widget currentlyTabObject() {
    if (getErrorMessages().isNotEmpty) {
      return (Center(
        child: Column(
          children: [
            Text(
              getErrorMessages(),
              style: const TextStyle(fontSize: 24, color: Colors.red),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ));
    } else {
      return (Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (_currentlyData != null)
              Column(
                children: [
                  Text(
                    _selectedLocation,
                    style: const TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    _currentlyData!,
                    style: const TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  )
                ],
              )
            else
              const Center(
                child: Text(
                  "Location",
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              )
          ],
        ),
      ));
    }
  }

  Widget todayTabObject() {
    if (getErrorMessages().isNotEmpty) {
      return (Center(
        child: Column(
          children: [
            Text(
              getErrorMessages(),
              style: const TextStyle(fontSize: 24, color: Colors.red),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ));
    } else {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (_todayData != null)
                Column(children: [
                  Text(
                    _selectedLocation,
                    style: const TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    _todayData!,
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ])
              else
                const Center(
                  child: Text(
                    "Location",
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      );
    }
  }

  Widget weeklyTabObject() {
    if (getErrorMessages().isNotEmpty) {
      return (Center(
        child: Column(
          children: [
            Text(
              getErrorMessages(),
              style: const TextStyle(fontSize: 24, color: Colors.red),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ));
    } else {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (_todayData != null)
                Column(children: [
                  Text(
                    _selectedLocation,
                    style: const TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    _weeklyData!,
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ])
              else
                const Center(
                  child: Text(
                    "Location",
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Padding(
        // padding: const EdgeInsets.all(8.0),
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  if (value.length > 2) {
                    _searchCity(value);
                  }
                },
                decoration: InputDecoration(
                  hintText: "Search city...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.blue[800],
                  borderRadius:
                      const BorderRadius.only(topRight: Radius.circular(10))),
              child: IconButton(
                  icon: const Icon(
                    Icons.arrow_outward_sharp,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (_searchResults.isNotEmpty) {
                      final result = _searchResults[0];
                      final lat = double.parse(result['lat']);
                      final lon = double.parse(result['lon']);
                      _setDatas(lat, lon);
                      _searchController.text = "";
                      _searchResults.clear();
                      _selectedLocation = result['display_name'];
                      _errorMessage = "";
                    } else {
                      if (_searchController.text.isEmpty) {
                        setErrorMessage("Search for a location");
                      } else {
                        setErrorMessage(
                            "Could not find any result for the supplied addresss or coordinates.");
                      }
                    }
                  }),
            )
          ],
        ),
        // ),
      ),
      body: Column(
        children: [
          _searchResults.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount:
                        _searchResults.length >= 5 ? 5 : _searchResults.length,
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      return ListTile(
                        title: result['display_name'].contains(',')
                            ? Wrap(
                                children: [
                                  const Icon(
                                    Icons.location_city,
                                  ),
                                  Text(
                                    result['display_name'].substring(
                                        0, result['display_name'].indexOf(',')),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  Text(
                                    result['display_name'].substring(
                                        result['display_name'].indexOf(',')),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  const Divider(
                                    thickness: 2,
                                  ),
                                ],
                              )
                            : Wrap(children: [
                                Text(
                                  result['display_name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const Divider(
                                  thickness: 2,
                                ),
                              ]),
                        onTap: () {
                          final lat = double.parse(result['lat']);
                          final lon = double.parse(result['lon']);
                          _setDatas(lat, lon);
                          _searchController.text = "";
                          _searchResults.clear();
                          _selectedLocation = result['display_name'];
                        },
                      );
                    },
                  ),
                )
              : Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      currentlyTabObject(),
                      todayTabObject(),
                      weeklyTabObject(),
                    ],
                  ),
                ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.sunny), text: "Currently"),
            Tab(icon: Icon(Icons.calendar_today), text: "Today"),
            Tab(icon: Icon(Icons.calendar_month), text: "Weekly"),
          ],
          labelStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}

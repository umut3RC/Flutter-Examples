import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  WeatherScreenState createState() => WeatherScreenState();
}

class WeatherScreenState extends State<WeatherScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  String? _currentlyData;
  String? _todayData;
  String? _weeklyData;

  double _todayMinTemp = 1000.0;
  double _todayMaxTemp = -1000.0;
  final List<double> _allTodayTemps = [];
  final List<Widget> _todayHourlyData = [];

  final List<double> _minWeekTemps = [];
  final List<double> _maxWeekTemps = [];
  double _weekMinTemp = 1000.0;
  double _weekMaxTemp = -1000.0;
  final List<String> _dateOfWeek = [];
  final List<Widget> _weekBottomDatas = [];

  TabController? _tabController;

  String _selectedLocation = '';
  String _selectedCity = '';
  String _selectedRegion = '';
  String _selectedCountry = '';

  String query = '';
  bool _hasInternet = true;
  String _errorMessage = "";

  Future<void> _searchCity(String query) async {
    final url =
        'https://nominatim.openstreetmap.org/search?format=json&addressdetails=1&q=$query';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _searchResults = data;
        // final address = _searchResults[0]['address'];
        // final city = address['city'] ?? address['town'] ?? address['village'] ?? 'Unknown City';
        // final state = address['state'] ?? 'Unknown State';
        // final country = address['country'] ?? 'Unknown Country';

        _errorMessage = "";
      });
    } else {
      setState(() {
        _errorMessage = "An error occurred while retrieving city data.";
      });
    }
  }

  void _setDatas(final res) {
    final lat = double.parse(res['lat']);
    final lon = double.parse(res['lon']);

    final address = res['address'];
    _selectedCity = address['city'] ??
        address['town'] ??
        address['village'] ??
        'Unknown City';
    _selectedRegion = address['region'] ?? 'Unknown Region';
    _selectedCountry = address['country'] ?? 'Unknown Country';

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
        _currentlyData = "${data['current_weather']['temperature']}°C\n"
            "${data['current_weather']['windspeed']} km/h\n"
            "${data['current_weather']['weathercode']}";
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
        '&forecast_days=1&hourly=temperature_2m,windspeed_10m,weather_code&timezone=auto';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List<dynamic> hourlyTimes = data['hourly']['time'];
      List<dynamic> temperatures = data['hourly']['temperature_2m']; // Sıcaklık
      List<dynamic> windSpeeds = data['hourly']['windspeed_10m']; // Rüzgar hızı
      List<dynamic> weatherCodes = data['hourly']['weather_code'];

      String weatherInfo = "";

      double minTempVal = 10000.0;
      double maxTempVal = -10000.0;
      double tmp = 0.0;

      _allTodayTemps.clear();
      _todayHourlyData.clear();
      for (int i = 0; i < hourlyTimes.length; i++) {
        weatherInfo += "${hourlyTimes[i].split("T")[1]}"
            "        ${temperatures[i]}°C"
            "        ${windSpeeds[i]} km/h || ";

        tmp = double.parse(temperatures[i].toString());
        _allTodayTemps.add(tmp);

        if (tmp > maxTempVal) {
          maxTempVal = tmp;
        } else if (tmp < minTempVal) {
          minTempVal = tmp;
        }

        _todayHourlyData
            .add(getTodayHourlyBottomData(i, temperatures[i], windSpeeds[i], weatherCodes[i]));
      }

      setState(() {
        _todayData = weatherInfo;
        _todayMinTemp = minTempVal;
        _todayMaxTemp = maxTempVal;
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

      String formattedData = "";

      double minTempVal = 10000.0;
      double maxTempVal = -10000.0;
      double tmp = 0.0;
      _minWeekTemps.clear();
      _maxWeekTemps.clear();
      _dateOfWeek.clear();
      _weekBottomDatas.clear();
      for (int i = 0; i < daily['time'].length; i++) {
        formattedData +=
            "${daily['time'][i]}: Min ${daily['temperature_2m_min'][i]}°C, "
            "Max ${daily['temperature_2m_max'][i]}°C, "
            "${getWeatherCondition(daily['weathercode'][i])}\n";
        _dateOfWeek.add(
            "${daily['time'][i].toString().split('-')[2]}/${daily['time'][i].toString().split('-')[1]}");
        tmp = double.parse(daily['temperature_2m_max'][i].toString());
        _maxWeekTemps.add(tmp);
        if (tmp > maxTempVal) {
          maxTempVal = tmp;
        }

        tmp = double.parse(daily['temperature_2m_min'][i].toString());
        _minWeekTemps.add(tmp);
        if (tmp < minTempVal) {
          minTempVal = tmp;
        }

        _weekBottomDatas.add(getWeeklyBottomData(
            _dateOfWeek[i],
            daily['weathercode'][i],
            double.parse(daily['temperature_2m_min'][i].toString()),
            double.parse(daily['temperature_2m_max'][i].toString())));
      }
      setState(() {
        _weeklyData = formattedData;
        _weekMinTemp = minTempVal;
        _weekMaxTemp = maxTempVal;
      });
    } else {
      setState(() {
        _weeklyData = "Weather data could not be fetched.";
      });
    }
  }

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

  Widget getWeatherIcon(String code, double iconSize) {
    switch (code) {
      case "Açık":
        return Icon(
          Icons.sunny,
          color: Colors.white,
          size: iconSize,
        );
      case "Parçalı Bulutlu":
        return Icon(
          Icons.cloud,
          color: Colors.white,
          size: iconSize,
        );
      case "Sisli":
        return Icon(
          Icons.foggy,
          color: Colors.white,
          size: iconSize,
        );
      case "Hafif Yağmurlu":
        return Icon(
          Icons.cloudy_snowing,
          color: Colors.white,
          size: iconSize,
        );
      case "Donan Yağmur":
        return Icon(
          Icons.cloudy_snowing,
          color: Colors.white,
          size: iconSize,
        );
      case "Yağmurlu":
        return Icon(
          Icons.water_drop,
          color: Colors.white,
          size: iconSize,
        );
      case "Karlı":
        return Icon(
          Icons.ac_unit,
          color: Colors.white,
          size: iconSize,
        );
      case "Kar Taneleri":
        return Icon(
          Icons.ac_unit,
          color: Colors.white,
          size: iconSize,
        );
      case "Sağanak Yağışlı":
        return Icon(
          Icons.thunderstorm,
          color: Colors.white,
          size: iconSize,
        );
      case "Kar Fırtınası":
        return Icon(
          Icons.ac_unit,
          color: Colors.white,
          size: iconSize,
        );
      case "Gök Gürültülü Fırtına":
        return Icon(
          Icons.thunderstorm,
          color: Colors.white,
          size: iconSize,
        );
      default:
        return Icon(
          Icons.help,
          color: Colors.white,
          size: iconSize,
        );
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
      List<String> splited = _currentlyData?.split('\n') ?? [];
      String tempText = "";
      String? windSpeedText = "";
      int weatherCode = 0;
      if (splited.length > 2) {
        tempText = splited[0];
        windSpeedText = splited[1];
        if (splited[2].trim().isNotEmpty) {
          weatherCode = int.tryParse(splited[2].trim()) ?? 0;
        }
      }
      return (Center(
          child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity, // Ekranı kaplasın
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (_currentlyData != null)
                Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      _selectedCity,
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      _selectedRegion,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      _selectedCountry,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 75),
                    Text(
                      tempText,
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      getWeatherCondition(weatherCode),
                      style: const TextStyle(fontSize: 25, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    getWeatherIcon(getWeatherCondition(weatherCode), 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.air, color: Colors.white),
                        Text(
                          windSpeedText,
                          style: const TextStyle(
                              fontSize: 24, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  ],
                )
              else
                const Center(
                  child: Text(
                    "Location",
                    style: TextStyle(fontSize: 15, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                )
            ],
          ),
        ],
      )));
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
      List<String> splited = _currentlyData?.split('\n') ?? [];
      String tempText = "";
      String? windSpeedText = "";
      int weatherCode = 0;
      if (splited.length > 2) {
        tempText = splited[0];
        windSpeedText = splited[1];
        if (splited[2].trim().isNotEmpty) {
          weatherCode = int.tryParse(splited[2].trim()) ?? 0;
        }
      }
      if (_todayData == null) {
        return (const Center(
          child: Text(
            "Search location",
            style: TextStyle(fontSize: 24, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ));
      } else {
        return SafeArea(
          child: Column(
            children: [
              // Üstte 2 text
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Text(
                      _selectedCity,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "$_selectedRegion, $_selectedCountry",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      "- Today temperatures -",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: LineChart(
                    LineChartData(
                      minY: _todayMinTemp,
                      maxY: _todayMaxTemp,
                      minX: 0,
                      maxX: _allTodayTemps.length.toDouble() - 1.0,
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 3,
                            getTitlesWidget: (value, meta) {
                              return Text('${value.toDouble()}°',
                                  style: const TextStyle(color: Colors.white));
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 2,
                            getTitlesWidget: (value, meta) {
                              String text = "";

                              if (value.toInt() < 10) {
                                text = "0${value.toInt()}.00";
                              } else {
                                text = "${value.toInt()}.00";
                              }
                              return Text(
                                text,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(
                          bottom: BorderSide(color: Colors.white, width: 2),
                          left: BorderSide(color: Colors.white, width: 2),
                          right: BorderSide(color: Colors.transparent),
                          top: BorderSide(color: Colors.transparent),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: false,
                          color: Colors.blueAccent,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blueAccent.withOpacity(0.3),
                          ),
                          spots: _allTodayTemps.asMap().entries.map((entry) {
                            int x = entry.key;
                            double y = entry.value;
                            return FlSpot(x.toDouble(), y);
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              buildBottomScrollingText(true),
            ],
          ),
        );
      }
    }
  }

  Widget buildBottomScrollingText(bool isHourly) {
    ScrollController _scrollController = ScrollController();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 0, left: 10),
      child: SizedBox(
        height: 75,
        child: ScrollbarTheme(
          data: ScrollbarThemeData(
            thumbColor: MaterialStateProperty.all(Colors.white.withAlpha(150)),
            thickness: MaterialStateProperty.all(8),
            radius: const Radius.circular(10),
          ),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                if (isHourly) ..._todayHourlyData else ..._weekBottomDatas
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget getTodayHourlyBottomData(
      int hourIndex, double temp, double windSpeed, int weatherCode) {
    String realHour = "";

    if (hourIndex < 10) {
      realHour = "0$hourIndex.00";
    } else {
      realHour = "$hourIndex.00";
    }

    return (Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.75),
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              realHour,
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
            Row(
              children: [
                getWeatherIcon(getWeatherCondition(weatherCode), 15),
                Text(
                  "$temp°C",
                  style: const TextStyle(fontSize: 15, color: Colors.white),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.air,
                  color: Colors.white,
                  size: 15,
                ),
                Text(
                  "${windSpeed}km/h",
                  style:
                      const TextStyle(fontSize: 15, color: Colors.yellowAccent),
                ),
              ],
            )
          ],
        )));
  }

  Widget weeklyTabObject() {
    //---------------------------------------------weeeeeeeeeeeeeeeeeeeeeeekkkkkkkkkkkkk
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
      List<String> splited = _currentlyData?.split('\n') ?? [];
      String tempText = "";
      String? windSpeedText = "";
      int weatherCode = 0;
      if (splited.length > 2) {
        tempText = splited[0];
        windSpeedText = splited[1];
        if (splited[2].trim().isNotEmpty) {
          weatherCode = int.tryParse(splited[2].trim()) ?? 0;
        }
      }
      if (_todayData == null) {
        return (const Center(
          child: Text(
            "Search location",
            style: TextStyle(fontSize: 24, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ));
      } else {
        return SafeArea(
          child: Column(
            children: [
              // Üstte 2 text
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Text(
                      _selectedCity,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "$_selectedRegion, $_selectedCountry",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.circle,
                          color: Colors.redAccent,
                          weight: 12,
                        ),
                        Text(
                          "Max Temperature",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.redAccent,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Icon(Icons.circle,
                            color: Colors.blueAccent, weight: 12),
                        Text(
                          "Min Temperature",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.blueAccent,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: LineChart(
                    LineChartData(
                      minY: _weekMinTemp,
                      maxY: _weekMaxTemp,
                      minX: 0,
                      maxX: _minWeekTemps.length.toDouble() - 1.0,
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 2,
                            getTitlesWidget: (value, meta) {
                              return Text('${value.toDouble()}°',
                                  style: const TextStyle(color: Colors.white));
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              String text = _dateOfWeek[value.toInt()];
                              return Text(
                                text,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(
                          bottom: BorderSide(color: Colors.white, width: 2),
                          left: BorderSide(color: Colors.white, width: 2),
                          right: BorderSide(color: Colors.transparent),
                          top: BorderSide(color: Colors.transparent),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: false,
                          color: Colors.blueAccent,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          spots: [
                            for (int i = 0; i < _minWeekTemps.length; i++)
                              FlSpot(i.toDouble(), _minWeekTemps[i])
                          ],
                        ),
                        LineChartBarData(
                          isCurved: false,
                          color: Colors.redAccent,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          spots: [
                            for (int i = 0; i < _maxWeekTemps.length; i++)
                              FlSpot(i.toDouble(), _maxWeekTemps[i])
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              buildBottomScrollingText(false),
            ],
          ),
        );
      }
    }
  }

  Widget getWeeklyBottomData(
      String currentDate, int weatherCode, double minTemp, double maxTemp) {
    return (Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.75),
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              currentDate,
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
            getWeatherIcon(getWeatherCondition(weatherCode), 15),
            Text(
              "$maxTemp°C max",
              style: const TextStyle(fontSize: 12, color: Colors.redAccent),
            ),
            Text(
              "$minTemp°C min",
              style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
            ),
          ],
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_outward_sharp,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (_searchResults.isNotEmpty) {
                    final result = _searchResults[0];
                    _setDatas(result);
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
                },
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Arkaplan resmi (tüm ekranı kaplayacak şekilde)
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg-4.png",
              fit: BoxFit.cover, // Resmi ekrana sığdır
            ),
          ),
          // Diğer widget'lar
          Column(
            children: [
              _searchResults.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: _searchResults.length >= 5
                            ? 5
                            : _searchResults.length,
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          return ListTile(
                            title: result['display_name'].contains(',')
                                ? Wrap(
                                    children: [
                                      const Icon(
                                        Icons.location_city,
                                        color: Colors.blue,
                                      ),
                                      Text(
                                        result['display_name'].substring(
                                            0,
                                            result['display_name']
                                                .indexOf(',')),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.white),
                                      ),
                                      Text(
                                        result['display_name'].substring(
                                            result['display_name']
                                                .indexOf(',')),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.white),
                                      ),
                                      const Divider(
                                        thickness: 2,
                                      ),
                                    ],
                                  )
                                : Wrap(
                                    children: [
                                      Text(
                                        result['display_name'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      const Divider(
                                        thickness: 2,
                                      ),
                                    ],
                                  ),
                            onTap: () {
                              _setDatas(result);
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
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        // color: Colors.transparent,
        color: const Color.fromARGB(150, 255, 255, 255),
        elevation: 0,
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

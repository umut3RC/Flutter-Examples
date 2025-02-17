// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Geocoding Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const GeocodingScreen(),
//     );
//   }
// }
//
// class GeocodingScreen extends StatefulWidget {
//   const GeocodingScreen({super.key});
//
//   @override
//   _GeocodingScreenState createState() => _GeocodingScreenState();
// }
//
// class _GeocodingScreenState extends State<GeocodingScreen> {
//   List<String> suggestions = [];
//   final TextEditingController _searchBarController = TextEditingController();
//
//   Future<void> fetchSuggestions(String input) async {
//     final url = Uri.parse(
//         'https://nominatim.openstreetmap.org/search?q=$input&format=json&addressdetails=1');
//
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body) as List;
//         setState(() {
//           suggestions =
//               data.map((item) => item['display_name'] as String).toList();
//         });
//       } else {
//         setState(() {
//           suggestions = ["Sonuç bulunamadı."];
//         });
//       }
//     } catch (e) {
//       setState(() {
//         suggestions = ["Hata: $e"];
//       });
//     }
//   }
//
//   void ClearField() {
//     setState(() {
//       _searchBarController?.text = '';
//       fetchSuggestions('');
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 onChanged: (input) {
//                   if (input.isNotEmpty) {
//                     fetchSuggestions(input);
//                   } else {
//                     setState(() {
//                       suggestions.clear();
//                     });
//                   }
//                 },
//                 controller: _searchBarController,
//                 decoration: InputDecoration(
//                   contentPadding: const EdgeInsets.all(10),
//                   hintText: 'Search Location',
//                   prefixIcon: const Icon(Icons.search),
//                   suffixIcon: IconButton(
//                     icon: const Icon(Icons.clear),
//                     onPressed: () {
//                       ClearField();
//                     },
//                   ),
//                 ),
//                 // onSubmitted: onEntered,
//               ),
//             ),
//             Container(
//               decoration: BoxDecoration(
//                   color: Colors.blue[800],
//                   borderRadius:
//                       const BorderRadius.only(topRight: Radius.circular(10))),
//               child: IconButton(
//                   icon: const Icon(
//                     Icons.arrow_outward_sharp,
//                     color: Colors.white,
//                   ),
//                   onPressed: () {
//                     // onEntered(query);
//                   }),
//             ),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 itemCount: suggestions.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(suggestions[index]),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
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
  String _locationData = ' ';
  String query = '';

  Future<void> _searchCity(String query) async {
    final url =
        'https://nominatim.openstreetmap.org/search?format=json&q=$query';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _searchResults = data;
      });
    }
  }

  void _setDatas(double lat, double lon) {
    _getCurrentlyData(lat, lon);
    _getTodayData(lat, lon);
    _getWeeklyData(lat, lon);
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
    }
  }

  Future<void> _getTodayData(double lat, double lon) async {
    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon'
        '&hourly=temperature_2m,windspeed_10m&timezone=auto';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List<dynamic> hourlyTimes =
          data['hourly']['time']; // Saatlik zaman verisi
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
        _weeklyData = "Hava durumu verileri alınamadı.";
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

  void onEntered(String value) {
    setState(() {
      _locationData = value;
    });
  }

  void ClearField() {
    setState(() {
      query = '';
    });
  }

  Widget CurrentlyTabObject() {
    return (Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (_currentlyData != null)
            Column(
              children: [
                Text(
                  _selectedLocation!,
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

  Widget TodayTabObject() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (_todayData != null)
              Column(children: [
                Text(
                  _selectedLocation!,
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

  Widget WeeklyTabObject() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (_todayData != null)
              Column(children: [
                Text(
                  _selectedLocation!,
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
                  prefixIcon: Icon(Icons.search),
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
                    }
                  }),
            )
          ],
        ),
        // ),
      ),
      body: Column(
        children: [
          _searchResults.length > 0
              ? Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      return ListTile(
                        title: Text(result['display_name']),
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
                      CurrentlyTabObject(),
                      TodayTabObject(),
                      WeeklyTabObject(),
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

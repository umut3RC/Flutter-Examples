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

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  String? _weatherData;

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

  Future<void> _getWeather(double lat, double lon) async {
    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _weatherData =
            "Temperature: ${data['current_weather']['temperature']}°C\n"
            "Wind Speed: ${data['current_weather']['windspeed']} km/h";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather App"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Enter city name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value.length > 2) {
                  _searchCity(value);
                }
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return ListTile(
                    title: Text(result['display_name']),
                    onTap: () {
                      final lat = double.parse(result['lat']);
                      final lon = double.parse(result['lon']);
                      _getWeather(lat, lon);
                    },
                  );
                },
              ),
            ),
            if (_weatherData != null)
              Center(
                child: Text(
                  _weatherData!,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

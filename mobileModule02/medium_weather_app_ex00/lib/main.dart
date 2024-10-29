import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      home: TabScreen(),
    );
  }
}

class TabScreen extends StatefulWidget {
  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  TextEditingController? _Fieldcontroller;
  String query = '';

  String _locationMessage = "Konum bilgisi alınamadı";
  final String _denidedText =
      "Geolocation is not available, please enable it in your App settings";
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _Fieldcontroller = TextEditingController();
    _determinePosition();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _Fieldcontroller?.dispose();
    super.dispose();
  }

  void onQueryChanged(String newQuery) {
    setState(() {
      query = newQuery;
    });
  }

  void onEntered(String value) {
    setState(() {
      _locationMessage = value;
    });
  }

  void ClearField() {
    setState(() {
      query = '';
      _Fieldcontroller?.text = '';
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Konum servisinin etkin olup olmadığını kontrol edin
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationMessage = "Konum servisleri etkin değil.";
        _isOnline = false;
      });
      return;
    }

    // Konum izni kontrol et
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationMessage = "Konum izni reddedildi.";
          _isOnline = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationMessage = "Konum izni kalıcı olarak reddedildi.";
        _isOnline = false;
      });
      return;
    }

    // Konumu al
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _locationMessage = "${position.latitude} ${position.longitude}";
    });
  }

  Widget CurrentTabObject() {
    return (Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Currently', style: TextStyle(fontSize: 24)),
          if (_isOnline)
            Text(_locationMessage, style: const TextStyle(fontSize: 24))
          else
            Text(_denidedText,
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, color: Colors.red))
        ],
      ),
    ));
  }

  Widget TodayTabObject() {
    return (Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Today', style: TextStyle(fontSize: 24)),
          if (_isOnline)
            Text(_locationMessage, style: const TextStyle(fontSize: 24))
          else
            Text(_denidedText,
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, color: Colors.red))
        ],
      ),
    ));
  }

  Widget WeeklyTabObject() {
    return (Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Weekly', style: TextStyle(fontSize: 24)),
          if (_isOnline)
            Text(_locationMessage, style: const TextStyle(fontSize: 24))
          else
            Text(_denidedText,
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, color: Colors.red))
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: onQueryChanged,
                controller: _Fieldcontroller,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  hintText: 'Search Location',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      ClearField();
                    },
                  ),
                ),
                onSubmitted: onEntered,
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
                    onEntered(query);
                  }),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                CurrentTabObject(),
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
//       title: 'Konum Uygulaması',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const LocationScreen(),
//     );
//   }
// }
//
// class LocationScreen extends StatefulWidget {
//   const LocationScreen({super.key});
//
//   @override
//   State<LocationScreen> createState() => _LocationScreenState();
// }
//
// class _LocationScreenState extends State<LocationScreen> {
//   String _locationMessage = "Konum bilgisi alınamadı";
//   final String _denidedText = "Geolocation is not available, please enable it in your App settings";
//   bool  _isOnline = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _determinePosition();
//   }
//
//   Future<void> _determinePosition() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     // Konum servisinin etkin olup olmadığını kontrol edin
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       setState(() {
//         _locationMessage = "Konum servisleri etkin değil.";
//         _isOnline = false;
//       });
//       return;
//     }
//
//     // Konum izni kontrol et
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         setState(() {
//           _locationMessage = "Konum izni reddedildi.";
//           _isOnline = false;
//         });
//         return;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       setState(() {
//         _locationMessage = "Konum izni kalıcı olarak reddedildi.";
//         _isOnline = false;
//       });
//       return;
//     }
//
//     // Konumu al
//     Position position = await Geolocator.getCurrentPosition();
//     setState(() {
//       _locationMessage =
//       "Enlem: ${position.latitude}, Boylam: ${position.longitude}";
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Konum Uygulaması"),
//       ),
//       body: Center(
//         child: Text(
//           _locationMessage,
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }

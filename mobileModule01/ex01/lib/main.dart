import 'package:flutter/material.dart';

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
  String _locationData = ' ';
  String query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _Fieldcontroller = TextEditingController();
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
      _Fieldcontroller?.text = '';
    });
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
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Currently', style: TextStyle(fontSize: 24)),
                      Text(_locationData, style: const TextStyle(fontSize: 24)),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Today', style: TextStyle(fontSize: 24)),
                      Text(_locationData, style: const TextStyle(fontSize: 24)),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Weekly', style: TextStyle(fontSize: 24)),
                      Text(_locationData, style: const TextStyle(fontSize: 24)),
                    ],
                  ),
                ),
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

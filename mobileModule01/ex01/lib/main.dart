import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tab Example',
      home: TabScreen(),
    );
  }
}

class TabScreen extends StatefulWidget {
  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String  _locationData = ' ';
  String query = '';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Column(
        children: [
          Column(
            children: [
      Container(
      child: TextField(
        onChanged: onQueryChanged,
        decoration: InputDecoration(
          labelText: 'Search',
          prefixIcon: Icon(Icons.search),
        ),
        onSubmitted: onEntered,
      ),
    ),
            ],
          ),
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
/*
class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  String query = '';

  void onQueryChanged(String newQuery) {
    setState(() {
      query = newQuery;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: TextField(
        onChanged: onQueryChanged,
        decoration: InputDecoration(
          labelText: 'Search',
          prefixIcon: Icon(Icons.search),
        ),
        onSubmitted: (value){
          print('');
        },
      ),
    );
  }
}*/
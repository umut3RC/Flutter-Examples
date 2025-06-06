import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Services/auth_service.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  int _lastSentimentIndex = 0;
  String _lastSentimentText = 'Happy';
  List<Map<String, dynamic>> _userNotes = [];
  late TabController _tabController;

  Future<List<Map<String, dynamic>>> fetchUserNotes() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("Kullanıcı giriş yapmamış.");
      return [];
    }

    final String userEmail = currentUser.email!;

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance
            .collection('notes')
            .where('usermail', isEqualTo: userEmail)
            .orderBy('date', descending: true)
            .get();

    // Veriyi hem data hem de doc ID ile al
    return snapshot.docs
        .map(
          (doc) => {
            'id': doc.id, // belge ID
            ...doc.data() as Map<String, dynamic>,
          },
        )
        .toList();
  }

  Future<void> deleteNoteById(String docId) async {
    await FirebaseFirestore.instance.collection('notes').doc(docId).delete();
    RefreshEntries();
    print("Silindi: $docId");
  }

  Future<void> getAllEntries() async {
    final notes = await fetchUserNotes();
    setState(() {
      _userNotes = notes;
    });
  }

  void RefreshEntries() {
    getAllEntries();
  }

  Widget CreateEntryObj(
    String title,
    DateTime etime,
    int icn,
    int _index,
    String docid,
  ) {
    return (ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.cyan[100]),
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title),
                      Text(etime.toString()),
                      GetSentimentIcon(icn),
                      Text(_userNotes[_index]['text'].toString()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              deleteNoteById(docid);
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Close'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
      child: Column(
        children: [
          Text(etime.toString()),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [GetSentimentIcon(icn), Text(title)],
            ),
          ),
        ],
      ),
    ));
  }

  Future<void> PushNewEntryData(String title, int icn, String text) async {
    CollectionReference usersRef = FirebaseFirestore.instance.collection(
      'notes',
    );
    await usersRef.add({
      'date': DateTime.now(),
      'icon': icn,
      'text': text,
      'title': title,
      'usermail': FirebaseAuth.instance.currentUser?.email,
    });
  }

  String GetSentimentText(int newStatus) {
    switch (newStatus) {
      case 0:
        return "Happy";
      case 1:
        return "Satisfied";
      case 2:
        return "Unhappy";
      default:
        return ("Happy");
    }
  }

  Widget GetSentimentIcon(int newStatus) {
    switch (newStatus) {
      case 0:
        return Icon(Icons.sentiment_very_satisfied);
      case 1:
        return Icon(Icons.sentiment_satisfied);
      case 2:
        return Icon(Icons.sentiment_dissatisfied);
      default:
        return (Icon(Icons.sentiment_very_satisfied));
    }
  }

  Widget CreateEntryList() {
    if (_userNotes.isNotEmpty) {
      return (Column(
        children: [
          Container(
            color: Colors.lightBlueAccent,
            child: Column(
              children: [
                Text(
                  'Your Last Diary Entries',
                  style: TextStyle(color: Colors.deepPurple, fontSize: 25),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _userNotes.length > 2 ? 2 : _userNotes.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: CreateEntryObj(
                        _userNotes[index]['title'].toString(),
                        (_userNotes[index]['date'] as Timestamp).toDate(),
                        int.parse(_userNotes[index]['icon'].toString()),
                        index,
                        _userNotes[index]['id'].toString(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          Container(
            color: Colors.lightBlueAccent,
            child: Column(
              children: [
                Text(
                  'Your feel for your 7 entries',
                  style: TextStyle(color: Colors.deepPurple, fontSize: 25),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _userNotes.length > 7 ? 7 : _userNotes.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: CreateEntryObj(
                        _userNotes[index]['title'].toString(),
                        (_userNotes[index]['date'] as Timestamp).toDate(),
                        int.parse(_userNotes[index]['icon'].toString()),
                        index,
                        _userNotes[index]['id'].toString(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ));
    } else {
      return (Center(child: Text('Lest Create Your First Note!')));
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    RefreshEntries();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget testRest(int i) {
    return (Text('AAAAAAAAAAAAAAAAaaa' + i.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Column(
          children: [
            Text("Welcome ${FirebaseAuth.instance.currentUser?.displayName}"),
            Text(
              'Total entries:${_userNotes.length}',
              style: TextStyle(fontSize: 10.0),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body:
           Column(
             children: [
               Expanded(
                 child: TabBarView(
                   controller: _tabController,
                   children: [],
                 ),
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
            Tab(icon: Icon(Icons.home), text: "Home"),
            Tab(icon: Icon(Icons.calendar_month), text: "Calendar"),
          ],
          labelStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}

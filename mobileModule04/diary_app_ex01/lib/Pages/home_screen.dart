import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Services/auth_service.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  int _lastSentimentIndex = 0;
  String _lastSentimentText = 'Happy';
  List<Map<String, dynamic>> _userNotes = [];

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
            .orderBy('date', descending: true) // İsteğe bağlı sıralama
            .get();

    // Verileri map'e dönüştür
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
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
  Widget CreateEntryObj(String title, String etime, int icn) {
    return (ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.cyan[100]),
      ),
      onPressed: () {
        print("büttürgeç");
      },
      child: Column(
        children: [
          Text(etime.toString()),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [GetSentimentIcon(icn), Text(title)],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Row(
          children: [
            Text("Welcome ${FirebaseAuth.instance.currentUser?.displayName}"),
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
      body: Center(
        child: Column(
          children: [
            Text("How are you feeling today?", style: TextStyle(fontSize: 24)),
            SizedBox(height: 20.0),
            TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.cyanAccent),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    final titleController = TextEditingController();
                    final contentController = TextEditingController();
                    // int tempSentimentIndex = _lastSentimentIndex;
                    // String tempSentimentText = _lastSentimentText;

                    return StatefulBuilder(
                      builder: (
                        BuildContext context,
                        StateSetter setModalState,
                      ) {
                        void setIconSentiment(int status) {
                          setModalState(() {
                            _lastSentimentIndex = status;
                            _lastSentimentText = GetSentimentText(status);
                            print(_lastSentimentIndex);
                          });
                        }

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
                              TextField(
                                controller: titleController,
                                decoration: InputDecoration(labelText: "Title"),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () => setIconSentiment(0),
                                    icon: Icon(Icons.sentiment_very_satisfied),
                                  ),
                                  IconButton(
                                    onPressed: () => setIconSentiment(1),
                                    icon: Icon(Icons.sentiment_satisfied),
                                  ),
                                  IconButton(
                                    onPressed: () => setIconSentiment(2),
                                    icon: Icon(Icons.sentiment_dissatisfied),
                                  ),
                                ],
                              ),
                              Text(_lastSentimentText),
                              // Güncellenen text buraya
                              TextField(
                                controller: contentController,
                                decoration: InputDecoration(labelText: "Text"),
                                maxLines: 10,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (titleController.text.isNotEmpty &&
                                      contentController.text.isNotEmpty) {
                                    PushNewEntryData(
                                      titleController.text,
                                      _lastSentimentIndex,
                                      contentController.text,
                                    );
                                    RefreshEntries();
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text("Add"),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: Text("Create an entry"),
            ),
            TextButton(
              onPressed: () {
                getAllEntries();
              },
              child: Text('Refresh'),
            ),
            SizedBox(height: 20.0),
            Expanded(
              child:
                  _userNotes.isNotEmpty
                      ? ListView.builder(
                        itemCount: _userNotes.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: CreateEntryObj(_userNotes[index]['title'].toString(),_userNotes[index]['date'].toString(),int.parse(_userNotes[index]['icon'].toString())),
                          );
                        },
                      )
                      : Center(child: Text('Hiç not yok')),
            ),

            // ),
          ],
        ),
      ),
    );
  }
}

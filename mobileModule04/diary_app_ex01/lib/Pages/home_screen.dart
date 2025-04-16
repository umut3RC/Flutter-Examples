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

  Widget CreateEntryObj() {
    return (Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.cyan[100]),
            ),
            onPressed: () {
              print("büttürgeç");
            },
            child: Column(
              children: [
                Text("date April 1, 2025 at 11:11:11"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sentiment_satisfied),
                    Text("Test Title"),
                  ],
                ),
              ],
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
      'icon': 0,
      'text': text,
      'title': title,
      'usermail': FirebaseAuth.instance.currentUser?.email,
    });
  }

  void setIconSentiment(int status) {
    setState(() {
      _lastSentimentIndex = status;
      _lastSentimentText = GetSentimentText(status);
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
                      int tempSentimentIndex = _lastSentimentIndex;
                      String tempSentimentText = _lastSentimentText;

                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setModalState) {
                          void setIconSentiment(int status) {
                            setModalState(() {
                              tempSentimentIndex = status;
                              tempSentimentText = GetSentimentText(status);
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                Text(tempSentimentText), // Güncellenen text buraya
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
                                        tempSentimentIndex,
                                        contentController.text,
                                      );
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
            SizedBox(height: 20.0),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //Tüm günlük girdileri al sırala
                  children: [
                    CreateEntryObj(),
                    SizedBox(height: 20.0),
                    CreateEntryObj(),
                    SizedBox(height: 20.0),
                    CreateEntryObj(),
                    SizedBox(height: 20.0),
                    CreateEntryObj(),
                    SizedBox(height: 20.0),
                    CreateEntryObj(),
                    SizedBox(height: 20.0),
                    CreateEntryObj(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

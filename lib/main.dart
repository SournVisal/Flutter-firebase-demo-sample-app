import 'package:flutter/material.dart';
import 'package:test_android/board.dart';
import 'SnackBarDemo.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

void main ()
{
  runApp(
    MaterialApp(
      title: 'Flutter Firebase',
      home: Home(),
    )
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Board> boardMessage = List();
  Board board;

  final FirebaseDatabase database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  DatabaseReference databaseReference;

  @override
  void initState() {
    // TODO: implement initState

    board = Board("", "");
    databaseReference = database.reference().child('comminuty_board');
    databaseReference.onChildAdded.listen(_onEntryAdded);
    databaseReference.onChildChanged.listen(_onEntryChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Firebase',
          style : TextStyle(
            color: Colors.black54
          ),
        ),
        backgroundColor: Colors.grey[300],
        actions: <Widget>[
          SnackBarDemo(),
          IconButton(
            icon: Icon(Icons.add_box),
            onPressed: () {
              database.reference().child("message").set({
                "firstname": "Geek",
                "lastname": "Visal"
              });
              debugPrint("Hello world");
            },
          )
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Flexible( 
              flex: 0,
              child: Form(
                key: formkey,
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.subject),
                      title: TextFormField(
                        initialValue: '',
                        onSaved: (val) => board.subject = val,
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.message),
                      title: TextFormField(
                        initialValue: '',
                        onSaved: (val) => board.body = val,
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    FlatButton(
                      child: Text('Submit',
                        style: TextStyle(
                          color: Colors.white
                        ),
                      ),
                      color: Colors.blueAccent,
                      onPressed: () {
                        handleSummit();
                      },
                    )
                  ],
                ),
              ),
            ),
            Flexible(
              child: FirebaseAnimatedList(
                query: databaseReference,
                itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation, int index) {
                  return new Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text(boardMessage[index].subject[0]),
                      ),
                      title: Text(boardMessage[index].subject),
                      subtitle: Text(boardMessage[index].body),
                    ),
                  );
                }
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onEntryAdded(Event event) {
    setState(() {
      boardMessage.add(Board.fromSnaphot(event.snapshot));
    });
  }

  void handleSummit () {
    final FormState form = formkey.currentState;

    if (form.validate()) {
      form.save();
      form.reset();

      databaseReference.push().set(board.toJson());
    }
  }

  void _onEntryChanged(Event event) {
    var oldEntry = boardMessage.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      boardMessage[boardMessage.indexOf(oldEntry)] = Board.fromSnaphot(event.snapshot);
    });
  }
}

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.lightBlue,
      ),
      home: MyHomePage(title: 'Credence'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _number = 0;
  String _nick = "";

  List<List<String>> _roles = [
    ["Jester", "Attempts to get himself executed by the town"],
    ["Serial Killer", "Lone wolf who gets to attack each night"],
  ];

  List<List<String>> _roleSelected = [
    ["Town", "You're just a plain townee who has no night powers. Vote to lynch all the evildoers!"],
    ["Mafia", "You're part of an organized crime unit, who want to crush all the townee dissidents and all those who oppose you."],
  ];

  String join_game_id = "";
  String join_game_nick = "";

  int numberConnected = 0;

  List<int> _numOfEachRole = [];

  var uuid = new Uuid();

  final numController =  TextEditingController();
  final nickController = TextEditingController();
  final _joinIdController = TextEditingController();
  final _joinNickController = TextEditingController();

  @override
  void dispose(){
    numController.dispose();
    nickController.dispose();
    _joinIdController.dispose();
    _joinNickController.dispose();
    super.dispose();
  }
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.

  Scaffold _genericScaffold(Text title, Column body, FloatingActionButton btn){
    return Scaffold(
      appBar: AppBar(
        title : title,
      ),
      body : Center(
        child : Padding(
          padding : const EdgeInsets.all(16.0),
          child : body,
        )
      ),
      floatingActionButton: btn,
    );
  }

  void _createGame(){
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context){
            return Scaffold(
              appBar : AppBar(
                title : const Text('Create Game'),
              ),
              body : Center(
                child : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child : Column(
                    children: <Widget>[
                      Text(
                        "num of people:",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      TextField(
                        controller: numController,
                        keyboardType: TextInputType.number
                      ),
                      SizedBox(height: 100),
                      Text(
                        "nick:",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      TextField(
                        controller: nickController,
                      )
                    ],
                  )
                )
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: (){
                  setState(() {
                    _number = int.parse(numController.text);
                    _nick = nickController.text;
                  });
                  _determineRoles();
                },
                tooltip: 'Increment',
                child: Icon(Icons.done),
              ),
              resizeToAvoidBottomPadding: false,
            );
          }
        )
      );
  }

  void _determineRoles(){
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext build){
          return _genericScaffold(const Text("Create Game"), Column(
            children: <Widget>[
              Text(
                "roles:",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),

              Flexible(
                fit: FlexFit.loose,
                child : ListView.builder(
                  itemCount: _roles.length,
                  itemBuilder: (context, i){
                    return ListTile(
                      title: Text(_roles[i][0]),
                      trailing: new Icon(
                        _roleSelected.contains(_roles[i]) ? Icons.done : Icons.clear,
                        color : _roleSelected.contains(_roles[i]) ? Colors.lightBlue : null,
                      ),
                      onTap: () {
                        setState(() {
                            if(_roleSelected.contains(_roles[i])){
                            _roleSelected.remove(_roles[i]);
                            } else{
                            _roleSelected.add(_roles[i]);
                            }
                        });
                      }
                    );
                  },
                )
              )
            ],
          ), 
            FloatingActionButton(
              onPressed: (){
                _numOfEachRole = [];
                for(int i = 0; i < _roleSelected.length; i++){
                  _numOfEachRole.add(1);
                }
                _determineNumberRoles();
              },
              child : Icon(Icons.done),
            )
          );
        }
      )
    );
  }

  Widget _buildNumberRoles(int i){
    return ListTile(
      title: Text(_roleSelected[i][0]),
      trailing: new Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(_numOfEachRole[i].toString()),
          Icon(
            Icons.add,
            color : Colors.lightBlue,
          ),
        ],
      ),
      onTap: () {
        // if numOfEachRole total < number

        if(_numOfEachRole.reduce((a, b) => a + b) < _number){
          setState(() {
          _numOfEachRole[i]++;
          });
        } else{
          showDialog(
            context : context,
            builder: (BuildContext context){
              return AlertDialog(
                title: new Text("Reached limit"),
                content: new Text("You have reached your own self-imposed limit on how much people are to play. If you want to add more of a certain role, then go back to change the number of people playing."),
              );
            }
          );
        }
      }
    );
  }

  void _determineNumberRoles(){
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context){
          return _genericScaffold(const Text("Create Game"), Column(
            children: <Widget>[
              Text(
                "roles:",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),


              Flexible(
                fit: FlexFit.loose,
                child : ListView.builder(
                  itemCount: _roleSelected.length,
                  itemBuilder: (context, i){
                    return _buildNumberRoles(i);
                  },
                )
              )
            ],
          ), FloatingActionButton(
            onPressed: (){
              // run the uuid generation here
              _determineGameId(uuid.v4());
            },
            child : Icon(
              Icons.done
            ),
          ));
        }
      )
    );
  }

  void _determineGameId(String uuid){
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context){
          return _genericScaffold(Text("Create Game"), Column(
            children: <Widget>[
              Text(
                "You're all set!",
                style: TextStyle(
                  fontSize : 48,
                )
              ),
              SizedBox(
                height: 100.0,
              ),
              Text(
                "Unique ID:",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                uuid,
                style: TextStyle(
                  fontSize: 12.0,

                )
              ),
              SizedBox(
                height : 25
              ),
              Text(
                "Share this id with your friends so that they can join. (sorry for id length but im lazy and this is the default).",
                style: TextStyle(
                  fontSize : 12.0,
                  fontStyle: FontStyle.italic,
                )
              )
              

            ],
          ), FloatingActionButton(
            onPressed: () {
              // create the game
              List<String> finalRoles = new List<String>();
              List<String> roleDesc = new List<String>();
              for(int i = 0; i < _roleSelected.length; i++){
                for(int j = 0; j < _numOfEachRole[i]; j++){
                  finalRoles.add(_roleSelected[i][0]);
                  roleDesc.add(_roleSelected[i][1]);
                }
              }
              Firestore.instance.collection('games').document().setData({
                'creator' : _nick,
                'number' : _number,
                'connected' : 1,
                'completed' : false,
                'uuid' : uuid,
                'roles' : finalRoles,
                'role_desc' : roleDesc
              });
            },
            child : Icon(
              Icons.check
            )
          ));
        }
      )
    );
  }

  void _joinGame(){
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context){
          return _genericScaffold(
            Text(
              "Join Game"
            ), Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Unique ID:",
                  style : TextStyle(
                    fontSize: 24
                  )
                ),
                TextField(
                  controller : _joinIdController,
                ),
                Text(
                  "Nick:",
                  style : TextStyle(
                    fontSize: 24
                  )
                ),
                TextField(
                  controller : _joinNickController, 
                ),
              ],
            ), FloatingActionButton(
              onPressed: (){
                setState(() {
                  join_game_id = _joinIdController.text;
                  join_game_nick = _joinNickController.text;
                });
                _gameQueue();
              },
              child : Icon(
                Icons.done
              )
            ));
        }
      )
    );
  }

  void _gameQueue(){
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder : (BuildContext context){
          return _genericScaffold(
            Text("Game Queue"),
            Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("waiting on other peeps..."),
              StreamBuilder(
                stream : Firestore.instance.collection('games').where('uuid', isEqualTo: join_game_id).snapshots(),
                builder : (BuildContext context, AsyncSnapshot snapshot){
                  numberConnected += snapshot.data.documents.forEach((doc) => doc["connected"]);
                }
              )
            ]),
            FloatingActionButton(
            onPressed: (){

            },
          ));
        }
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ButtonTheme(
              minWidth: 200.0,
              child : RaisedButton(
                child : const Text(
                  "Create Game",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                color: Colors.blue,
                splashColor: Colors.deepPurple,
                elevation: 4.0,
                onPressed: _createGame,
              ),
            ),
            ButtonTheme(
              minWidth: 200.0,
              child : RaisedButton(
                child : const Text(
                  "Join Game",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                color: Colors.blue,
                splashColor: Colors.deepPurple,
                onPressed: (){
                  _joinGame();
                },
              ),   
            ),
            ButtonTheme(
              minWidth: 200.0,
              child : RaisedButton(
                child : const Text(
                  "Stats",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                color: Colors.blue,
                splashColor: Colors.deepPurple,
                onPressed: (){

                },
              ),
            ),
          ]
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          
        },
        tooltip: 'Info',
        child: Icon(Icons.info),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

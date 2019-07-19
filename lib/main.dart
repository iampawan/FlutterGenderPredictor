import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:data_connection_checker/data_connection_checker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _nameController = TextEditingController();
  var result;

  StreamSubscription<DataConnectionStatus> listener;

  predictGender(String name) async {
    DataConnectionStatus status = await checkInternet();
    if (status == DataConnectionStatus.connected) {
      var url = "https://api.genderize.io/?name=$name";
      var res = await http.get(url);
      var body = jsonDecode(res.body);

      result = "Gender: ${body['gender']}, Probability: ${body['probability']}";
      setState(() {});
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("No Internet"),
                content: Text("Check your internet connection."),
              ));
    }
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  checkInternet() async {
    print("The statement 'this machine is connected to the Internet' is: ");
    print(await DataConnectionChecker().hasConnection);
    // returns a bool

    // We can also get an enum value instead of a bool
    print("Current status: ${await DataConnectionChecker().connectionStatus}");
    // prints either DataConnectionStatus.connected
    // or DataConnectionStatus.disconnected

    // This returns the last results from the last call
    // to either hasConnection or connectionStatus
    print("Last results: ${DataConnectionChecker().lastTryResults}");

    // actively listen for status updates
    // this will cause DataConnectionChecker to check periodically
    // with the interval specified in DataConnectionChecker().checkInterval
    // until listener.cancel() is called
    listener = DataConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case DataConnectionStatus.connected:
          print('Data connection is available.');
          break;
        case DataConnectionStatus.disconnected:
          print('You are disconnected from the internet.');
          break;
      }
    });

    return await DataConnectionChecker().connectionStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gender Predictor"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              "Enter a name to predict it's gender.",
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Name",
                ),
              ),
            ),
            RaisedButton(
              onPressed: () => predictGender(_nameController.text),
              child: Text("Predict"),
            ),
            if (result != null) Text(result)
          ],
        ),
      ),
    );
  }
}

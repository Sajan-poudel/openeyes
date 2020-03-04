import 'dart:core';

import 'package:flutter/material.dart';
import 'package:speech_recognition/speech_recognition.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SpeechRecognition _speechRecognization;
  bool _islistening = false;
  bool _isavailable = false;
  String resulttext = "";
  bool speakin = false;
  List<String> split;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _speechRecognization = SpeechRecognition();
    _speechRecognization.setAvailabilityHandler(
        (bool res) => setState(() => _isavailable = res));
    _speechRecognization.setRecognitionStartedHandler(
        () => setState(() => _islistening = true));
    _speechRecognization.setRecognitionResultHandler(
        (String speech) => setState(() => resulttext = speech));
    _speechRecognization.setRecognitionCompleteHandler(
        () => setState(() => _islistening = false));
    _speechRecognization
        .activate()
        .then((res) => setState(() => _isavailable = res));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("open eyes")),
        elevation: 20,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 10, left: 10, right: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text("$resulttext"),
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width * 0.05),
            child: IconButton(
              iconSize: MediaQuery.of(context).size.width * 0.98,
              icon: Icon(
                Icons.play_circle_outline,
                color: (speakin) ? Colors.green : Colors.blue,
                size: MediaQuery.of(context).size.width * 0.98,
              ),
              onPressed: () {
                if (!speakin) {
                  if (_isavailable && !_islistening)
                    _speechRecognization
                        .listen(locale: "en_US")
                        .then((result) => print('$result'));
                } else {
                  if(resulttext.contains("get me to")){
                    split = resulttext.split("get me to");
                  }else if(resulttext.contains("guide me to")){
                    split = resulttext.split("guide me to");
                  }
                  //fetchlocation(split[1]);
                  if (_islistening) {
                    _speechRecognization.stop().then((result) {
                      setState(() => _islistening = result);
                    });

                    _speechRecognization.cancel().then((result) {
                      print("object");
                      setState(() => _islistening = result);
                    });
                  }
                }
                setState(() {
                  speakin = !speakin;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}


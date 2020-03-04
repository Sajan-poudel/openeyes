import 'dart:core';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:http/http.dart' as http;

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
  SocketIO socketIO;
  @override
  void initState() {
    // TODO: implement initState
    socketIO = SocketIOManager().createSocketIO(
      'https://13.232.28.46:3000',
      '/',
    );
    socketIO.init();

    socketIO.connect();
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
                  if (resulttext.contains("get me to")) {
                    split = resulttext.split("get me to");
                  } else if (resulttext.contains("guide me to")) {
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
          FloatingActionButton(
            child: Text("data"),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Mapview()));
            },
          ),
        ],
      ),
    );
  }
}

class Mapview extends StatefulWidget {
  Mapview({Key key}) : super(key: key);

  @override
  _MapviewState createState() => _MapviewState();
}

class _MapviewState extends State<Mapview> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(12.971599, 77.594566),
          zoom: 15,
        ),
        layers: [
          new TileLayerOptions(
            urlTemplate: "https://apis.mapmyindia.com/advancedmaps/v1/ge79np57h6uwlfla4k4fzn2efrgoplnh/map_load?v=1.3"
            // urlTemplate: "https://api.tiles.mapbox.com/v4/"
            //     "{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
            // additionalOptions: {
            //   'accessToken':
            //       'pk.eyJ1Ijoic2FqYW4tcG91ZGVsIiwiYSI6ImNrMnZnbGw3ZTA0aTgzbG5xcTNpMDFzbHAifQ.Criu5-m3kWFRKo7vcZ3NYA',
            //   'id': 'mapbox.streets',
            // },
          ),
          new MarkerLayerOptions(
            markers: [
              new Marker(
                width: 80.0,
                height: 80.0,
                point: new LatLng(12.971599, 77.594566),
                builder: (ctx) => new Container(
                  child: Icon(Icons.map),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

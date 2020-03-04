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
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


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
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    // TODO: implement initState
    // socketIO = SocketIOManager().createSocketIO(
    //   'https://13.232.28.46:3000',
    //   '/',
    // );
    // socketIO.init();
    // socketIO.subscribe('receive_message', (jsonData) {
    //   //Convert the JSON data received into a Map
    //   print(jsonData);
    // });
    // socketIO.connect();
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
                  fetchlocation(split[1]);
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
                  context,
                  MaterialPageRoute(
                      builder: (context) => Mapview(12.971599, 77.594566)));
            },
          ),
          RaisedButton(
            child: Text("press here for voice"),
            onPressed: texttovoice,
          )
        ],
      ),
    );
  }

  void fetchlocation(String address) async {
    try {
      http.Response response = await http.get(
          'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(address)}.json?access_token=pk.eyJ1Ijoic2FqYW4tcG91ZGVsIiwiYSI6ImNrMnZnbGw3ZTA0aTgzbG5xcTNpMDFzbHAifQ.Criu5-m3kWFRKo7vcZ3NYA&limit=1');
      if (response.statusCode == 200 || response.statusCode == 201) {
        // final String res = response.body;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Mapview(
                jsonDecode(response.body)['features'][0]['center'][1],
                jsonDecode(response.body)['features'][0]['center'][0]),
          ),
        );
        print(response.body);
      }
    } catch (error) {
      print(error);
    }
  }

  Future texttovoice() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1);
    await _flutterTts.setVolume(1);
    // print(await _flutterTts.getVoices);
    await _flutterTts
        .speak("hello! i hope you are doing good with hackathon. Happy hack");
  }
}

class Mapview extends StatefulWidget {
  double deslatitude;
  double deslongitude;

  Mapview([double latitude, double longitude]) {
    deslatitude = latitude;
    deslongitude = longitude;
  }

  @override
  _MapviewState createState() => _MapviewState();
}

class _MapviewState extends State<Mapview> {
  double currentlat = 13.1278059;
  double currentlong = 77.5880203;

  void initState() {
    // TODO: implement initState
    super.initState();
    _getLocation().then((position) {
      setState(() {
        currentlat = position.latitude;
        currentlong = position.longitude;
      });
      print(position);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(widget.deslatitude, widget.deslongitude),
          zoom: 15,
        ),
        layers: [
          new TileLayerOptions(
            // urlTemplate: "https://apis.mapmyindia.com/advancedmaps/v1/ge79np57h6uwlfla4k4fzn2efrgoplnh/map_load?v=1.3"
            urlTemplate:
                "https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
            additionalOptions: {
              'accessToken':
                  'pk.eyJ1Ijoic2FqYW4tcG91ZGVsIiwiYSI6ImNrMnZnbGw3ZTA0aTgzbG5xcTNpMDFzbHAifQ.Criu5-m3kWFRKo7vcZ3NYA',
              'id': 'mapbox.streets',
            },
          ),
          new MarkerLayerOptions(
            markers: [
              new Marker(
                width: 300.0,
                height: 300.0,
                point: new LatLng(currentlat, currentlong),
                builder: (ctx) => new Container(
                  child: Icon(Icons.location_on, color: Colors.green,),
                ),
              ),
              new Marker(
                width: 300.0,
                height: 300.0,
                point: new LatLng(widget.deslatitude, widget.deslongitude),
                builder: (ctx) => new Container(
                  child: Icon(FontAwesomeIcons.mapPin, color: Colors.red,),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      print("Error : ${e}");
      // currentLocation = null;
    }
    return currentLocation;
  }
}

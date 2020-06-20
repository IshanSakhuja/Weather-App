import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:new_geolocation/geolocation.dart';
import 'package:dio/dio.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  internet = await DataConnectionChecker().hasConnection;
  runApp(MyApp());
}

bool internet;
double lat;
double lng;
String icon;
String weatherdesciption;
String location;
String maintemp;
String maxtemp;
String mintemp;
String humidity;
String windspeed;
String pressure;
int month;
int day;
int year;
int hour;
int minute;
int second;
bool locationpermission = false;
Map<Permission, PermissionStatus> statuses;
bool _loading;
double _progressValue;

class MyApp extends StatefulWidget {
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _loading = false;
    _progressValue = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    var currDt = DateTime.now();
    year = currDt.year; // 4
    month = currDt.month; // 4
    day = currDt.day; // 2
    hour = currDt.hour; // 15
    minute = currDt.minute;
    permission();
    getHttp();
    if (internet == true && locationpermission) {
      return MaterialApp(
        theme: ThemeData(fontFamily: 'Ishan'),
        home: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text("Weather Application"),
            ),
            body: Padding(
              padding: EdgeInsets.all(10.0),
              child: Center(
                child: Container(
                  child: Center(
                    child: FutureBuilder(
                      future: buildText(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return CircularProgressIndicator(
                            backgroundColor: Colors.blue,
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    location,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17.0,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text('Updated at: $day' +
                                      '/' +
                                      '$month' +
                                      '/' +
                                      '$year' +
                                      '  ' +
                                      '$hour' +
                                      ':' +
                                      '$minute'),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Column(
                                    children: <Widget>[
                                      Image.network(
                                          'http://openweathermap.org/img/wn/$icon.png'),
                                      Text(
                                        '$weatherdesciption',
                                        style: TextStyle(
                                          fontSize: 20.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    (double.parse(maintemp) - 273)
                                            .toStringAsFixed(2) +
                                        '°C',
                                    style: TextStyle(
                                      fontSize: 40.0,
                                      fontFamily: 'Ishan1',
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Min Temp ' +
                                            (double.parse(mintemp) - 273)
                                                .toStringAsFixed(2) +
                                            '°C',
                                        style: TextStyle(
                                          fontFamily: 'Ishan1',
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20.0,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Max Temp ' +
                                            (double.parse(maxtemp) - 273)
                                                .toStringAsFixed(2) +
                                            '°C',
                                        style: TextStyle(
                                          fontFamily: 'Ishan1',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      FlatButton(
                                        child: Column(
                                          children: <Widget>[
                                            Image.asset(
                                              'images/humidity.png',
                                              height: 25.0,
                                            ),
                                            Container(
                                              child: Text('Humidity'),
                                            ),
                                            Container(
                                              child: Text(humidity),
                                            ),
                                          ],
                                        ),
                                      ),
                                      FlatButton(
                                        child: Column(
                                          children: <Widget>[
                                            Image.asset(
                                              'images/pressure.png',
                                              height: 25.0,
                                            ),
                                            Container(
                                              child: Text('Pressure'),
                                            ),
                                            Container(
                                              child: Text(pressure),
                                            ),
                                          ],
                                        ),
                                      ),
                                      FlatButton(
                                        child: Column(
                                          children: <Widget>[
                                            Image.asset(
                                              'images/wind.png',
                                              height: 25.0,
                                            ),
                                            Container(
                                              child: Text('Wind'),
                                            ),
                                            Container(
                                              child: Text(windspeed),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    'Created by Ishan',
                                    style: TextStyle(
                                      fontSize: 10.0,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return MaterialApp(
        home: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text('Weather Application'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Text('No Internet or Location Not Granted'),
                  ),
                  SizedBox(
                    height: 20.0,
                    width: 20.0,
                  ),
                  FlatButton(
                    child: Container(
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    onPressed: () {
                      main();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  Future buildText() {
    return new Future.delayed(
        const Duration(seconds: 15), () => print('waiting'));
  }

  Future<void> permission() async {
    statuses = await [
      Permission.location,
    ].request();
    if (statuses[Permission.location].isGranted) {
      locationpermission = true;
      getLocation();
    } else {
      locationpermission = false;
      Fluttertoast.showToast(
          msg: "Permission Not Granted",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void getLocation() {
    StreamSubscription<LocationResult> subscription =
        Geolocation.currentLocation(accuracy: LocationAccuracy.best)
            .listen((result) {
      if (result.isSuccessful) {
        lat = result.location.latitude;
        lng = result.location.longitude;
      }
    });
  }

  void getHttp() async {
    try {
      Response response = await Dio().get(
          "http://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lng&appid=1a2683c5ade0a58ff92f8cb1186afb5a");
      Map<String, dynamic> user = json.decode(response.toString());
      String temp = user.toString();
      print('Printing Stuff');
      weatherdesciption =
          temp.substring(temp.indexOf('main: ') + 6, temp.indexOf(', descr'));
      icon = temp.substring(temp.indexOf('icon: ') + 6, temp.indexOf('}]'));
      maintemp = temp.substring(
          temp.indexOf('temp: ') + 6, temp.indexOf(', feels_like'));
      mintemp = temp.substring(
          temp.indexOf('temp_min: ') + 10, temp.indexOf(', temp_max'));
      maxtemp = temp.substring(
          temp.indexOf('temp_max: ') + 10, temp.indexOf(', pressure'));
      humidity = temp.substring(
          temp.indexOf('humidity: ') + 10, temp.indexOf('}, visibi'));
      pressure = temp.substring(
          temp.indexOf('pressure: ') + 10, temp.indexOf(', humi'));
      windspeed =
          temp.substring(temp.indexOf('speed: ') + 7, temp.indexOf(', deg'));
      location =
          temp.substring(temp.indexOf('name: ') + 6, temp.indexOf(', cod:'));
    } catch (e) {
      print(e);
    }
  }
}

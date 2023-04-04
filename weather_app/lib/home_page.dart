import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    position = await Geolocator.getCurrentPosition();
    getWeatherData();
    // print(
    //     "my latitude is ${position!.latitude}, longitute is ${position!.longitude}");
  }

  Position? position;
  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forcastMap;

  getWeatherData() async {
    var weather = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=${position!.latitude}&lon=${position!.longitude}&appid=e9512dbc4c83e13cb7c0f2bb18321947&units=metric"));
    print("WWw ${weather.body}");
    var forcast = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?lat=${position!.latitude}&lon=${position!.longitude}&appid=e9512dbc4c83e13cb7c0f2bb18321947&units=metric"));

    print("WWw ${forcast.body}");

    var weatherData = jsonDecode(weather.body);
    var forcastData = jsonDecode(forcast.body);

    setState(() {
      weatherMap = Map<String, dynamic>.from(weatherData);
      forcastMap = Map<String, dynamic>.from(forcastData);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    determinePosition();
    super.initState();
  }

  Widget build(BuildContext context) {
    return SafeArea(
        child: weatherMap != null
            ? Scaffold(
                appBar: AppBar(
                  title: Text("Weather App"),
                  centerTitle: true,
                ),
                body: Container(
                  padding: EdgeInsets.all(24),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${Jiffy.parse('${DateTime.now()}').format(pattern: 'MMMM do yyyy, h:mm a')}",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              "${weatherMap!["name"]}",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            )
                          ],
                        ),
                      ),
                      Image.network(
                          "https://openweathermap.org/img/wn/${weatherMap!["weather"][0]["icon"]}@2x.png"),
                      Text(
                        "${weatherMap!["main"]["temp"]}°",
                        style: TextStyle(
                            fontSize: 48, fontWeight: FontWeight.w700),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Feels Like ${weatherMap!["main"]["feels_like"]}",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              "${weatherMap!["weather"][0]["description"]}",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        " Humidity: ${weatherMap!["main"]["humidity"]} g.m-3, Pressure: ${weatherMap!["main"]["pressure"]} Pa",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        "Sunrise: ${Jiffy.parse("${DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunrise"] * 1000)}").format(pattern: "hh mm a")}, Sunset: ${Jiffy.parse("${DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunset"] * 1000)}").format(pattern: "hh mm a")}  ",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        height: 250,
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: forcastMap!.length,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: Colors.teal,
                                    borderRadius: BorderRadius.circular(15)),
                                width: 300,
                                margin: EdgeInsets.only(right: 12),
                                child: Column(
                                  children: [
                                    Text(
                                      "${Jiffy.parse("${forcastMap!["list"][index]["dt_txt"]}").format(pattern: "EEE hh mm")}",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Image.network(
                                        "https://openweathermap.org/img/wn/${forcastMap!["list"][index]["weather"][0]["icon"]}@2x.png"),
                                    Text(
                                      "Min Temp: ${forcastMap!["list"][index]["main"]["temp_min"]}°",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      "Max Temp: ${forcastMap!["list"][index]["main"]["temp_max"]}°",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      "${forcastMap!["list"][index]["weather"][0]["description"]}",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                      )
                    ],
                  ),
                ),
              )
            : Center(child: CircularProgressIndicator()));
  }
}

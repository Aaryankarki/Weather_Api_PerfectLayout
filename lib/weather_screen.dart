import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weatherapp/additional_information.dart';
import 'package:weatherapp/api_key.dart';
import 'package:weatherapp/hourly_forecast.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      final response = await http.get(Uri.parse(weatherApi));
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['cod'].toString() != '200') {
          throw "Unexpected error ";
        }
      }
      // log(data['list'][0]['main']['temp'].toString());
      // log(data['list'][0]['main']['humidity'].toString());

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    weather = getCurrentWeather();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          "Weather App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: FutureBuilder(
          future: weather,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator.adaptive());
            }
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            final data = snapshot.data;
            final temp = data!['list'][0]['main']['temp'];
            final weatherMain = data['list'][0]['weather'][0]['main'];
            final humidity = data['list'][0]['main']['humidity'];
            final pressure = data['list'][0]['main']['pressure'];
            final windSpeed = data['list'][0]['wind']['speed'];

            final timestamp = data['list'][0]['dt'];

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //main card
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 20,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  '$temp K',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Icon(
                                  weatherMain == 'Clouds' ||
                                          weatherMain == 'Rain'
                                      ? Icons.cloud
                                      : Icons.sunny,
                                  size: 68,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  weatherMain,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  //weather forecast
                  const Text(
                    "Hourly Forecast",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  // SingleChildScrollView(
                  //   scrollDirection: Axis.horizontal,
                  //   child: Row(
                  //     children: [
                  //       for (int i = 0; i < 5; i++)
                  //         HourlyForecast(
                  //           icon:
                  //               data['list'][i + 1]['weather'][0]['main'] ==
                  //                       'Clouds' ||
                  //                   data['list'][i + 1]['weather'][0]['main'] ==
                  //                       'Rain'
                  //               ? Icons.cloud
                  //               : Icons.wb_sunny,
                  //           time: data['list'][i + 1]['dt'].toString(),
                  //           temperature: data['list'][i + 1]['main']['temp']
                  //               .toString(),
                  //         ),
                  //     ],
                  //   ),
                  // ),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        final hourlyForecast = data['list'][index + 1];
                        final hourlySky =
                            data['list'][index + 1]['weather'][0]['main'];
                        final hourlyTemp = hourlyForecast['main']['temp']
                            .toString();
                        final time = DateTime.parse(hourlyForecast['dt_txt']);
                        return HourlyForecast(
                          icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                              ? Icons.cloud
                              : Icons.wb_sunny,
                          time: DateFormat.j().format(time),
                          temperature: hourlyTemp.toString(),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),

                  //additional features
                  Text(
                    "Additional Information",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 7),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AdditionalInformation(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        value: humidity.toString(),
                      ),
                      SizedBox(width: 40),
                      AdditionalInformation(
                        icon: Icons.air,
                        label: 'WindSpeed',
                        value: windSpeed.toString(),
                      ),
                      SizedBox(width: 40),
                      AdditionalInformation(
                        icon: Icons.beach_access,
                        label: 'Pressure',
                        value: pressure.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

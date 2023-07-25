import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';

class FixtureDetailScreen extends StatefulWidget {
  final Map<String, dynamic> fixtureData;

  FixtureDetailScreen({required this.fixtureData});

  @override
  _FixtureDetailScreenState createState() => _FixtureDetailScreenState();
}

class _FixtureDetailScreenState extends State<FixtureDetailScreen> {
  String? selectedWinner;
  Map<String, dynamic>? _apiData;

  @override
  void initState() {
    super.initState();
    _fetchFixtureData('592141');
  }

  Future<void> _fetchFixtureData(String id) async {
    try {
      final response = await http.get(
        Uri.parse('https://api-football-v1.p.rapidapi.com/v3/fixtures?id=$id'),
        headers: {
          'X-RapidAPI-Key':
              '13c64b1909mshd0226621badc3dap10a2dcjsn2f557fb25460',
          'X-RapidAPI-Host': 'api-football-v1.p.rapidapi.com',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _apiData = jsonDecode(response.body);
        });
      } else {
        // Handle error if API call fails
        print('Error fetching fixture data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching fixture data: $e');
    }
  }

  final ApiService apiService = ApiService();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fixture Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _apiData != null
                ? Column(
                    children: [
                      TeamsCard(
                        homeTeamLogo: widget.fixtureData['teams']['home']
                            ['logo'],
                        homeTeamName: widget.fixtureData['teams']['home']
                            ['name'],
                        awayTeamLogo: widget.fixtureData['teams']['away']
                            ['logo'],
                        awayTeamName: widget.fixtureData['teams']['away']
                            ['name'],
                        advice: widget.fixtureData['predictions']['advice'],
                      ),
                      SizedBox(height: 20),
                      FixtureCard(
                        date: _apiData!['response'][0]['fixture']['date'],
                        venueName: _apiData!['response'][0]['fixture']['venue']
                            ['name'],
                        venueCity: _apiData!['response'][0]['fixture']['venue']
                            ['city'],
                      ),
                    ],
                  )
                : CircularProgressIndicator(),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedWinner,
              onChanged: (String? newValue) {
                setState(() {
                  selectedWinner = newValue;
                });
              },
              items: [
                DropdownMenuItem(
                  value: widget.fixtureData['teams']['home']['name'],
                  child: Text(widget.fixtureData['teams']['home']['name']),
                ),
                DropdownMenuItem(
                  value: widget.fixtureData['teams']['away']['name'],
                  child: Text(widget.fixtureData['teams']['away']['name']),
                ),
                DropdownMenuItem(
                  value: 'Draw',
                  child: Text('Draw'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _submitPrediction();
              },
              child: Text('Submit Prediction'),
              style: ElevatedButton.styleFrom(
                primary: Colors.lightGreen, // Set button color to light green
                onPrimary: Colors.white, // Set text color to white
                fixedSize: Size(200, 50), // Set fixed size for the button
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitPrediction() async {
    if (selectedWinner == null) {
      // Handle case when the user hasn't selected a winner.
      return;
    }

    try {
      // Get a reference to the Firestore collection where we will store predictions
      final predictionCollection =
          FirebaseFirestore.instance.collection('predictions');

      // Create a new document to store the prediction
      final newPredictionDoc = predictionCollection.doc();

      // Create a data map to store the prediction details
      final Map<String, dynamic> predictionData = {
        'userId': _auth.currentUser!.uid,
        'fixtureId': widget.fixtureData['fixture']['id'],
        'leagueName': widget.fixtureData['league']['name'],
        'homeTeamName': widget.fixtureData['teams']['home']['name'],
        'awayTeamName': widget.fixtureData['teams']['away']['name'],
        'selectedWinner': selectedWinner,
        'timestamp':
            FieldValue.serverTimestamp(), // Store the current timestamp
      };

      // Save the prediction data to Firestore
      await newPredictionDoc.set(predictionData);

      // Show a success message or navigate back to the HomeScreen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Prediction submitted successfully!'),
        ),
      );
    } catch (e) {
      // Handle any errors that occur while saving the prediction
      print('Error submitting prediction: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit prediction. Please try again later.'),
        ),
      );
    }
  }
}

class FixtureCard extends StatelessWidget {
  final String? date;
  final String? venueName;
  final String? venueCity;

  FixtureCard({
    this.date,
    this.venueName,
    this.venueCity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Fixture Date:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            date ?? 'N/A',
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
          SizedBox(height: 20),
          Text(
            'Venue:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '$venueName, $venueCity' ?? 'N/A',
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class TeamsCard extends StatelessWidget {
  final String? homeTeamLogo;
  final String? homeTeamName;
  final String? awayTeamLogo;
  final String? awayTeamName;
  final String? advice;

  TeamsCard({
    this.homeTeamLogo,
    this.homeTeamName,
    this.awayTeamLogo,
    this.awayTeamName,
    this.advice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (homeTeamLogo != null)
                Image.network(
                  homeTeamLogo!,
                  width: 48,
                  height: 48,
                ),
              SizedBox(width: 10),
              Text(
                '$homeTeamName vs $awayTeamName',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(width: 10),
              if (awayTeamLogo != null)
                Image.network(
                  awayTeamLogo!,
                  width: 48,
                  height: 48,
                ),
            ],
          ),
          SizedBox(height: 10),
          if (advice != null)
            Text(
              advice!,
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

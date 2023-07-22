import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';

class FixtureDetailScreen extends StatefulWidget {
  final Map<String, dynamic> fixtureData;

  FixtureDetailScreen({required this.fixtureData});

  @override
  _FixtureDetailScreenState createState() => _FixtureDetailScreenState();
}

class _FixtureDetailScreenState extends State<FixtureDetailScreen> {
  String? selectedWinner;

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
            FixtureCard(
              homeTeamLogo: widget.fixtureData['teams']['home']['logo'],
              homeTeamName: widget.fixtureData['teams']['home']['name'],
              awayTeamLogo: widget.fixtureData['teams']['away']['logo'],
              awayTeamName: widget.fixtureData['teams']['away']['name'],
              advice: widget.fixtureData['predictions']['advice'],
            ),
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
  final String? homeTeamLogo;
  final String? homeTeamName;
  final String? awayTeamLogo;
  final String? awayTeamName;
  final String? advice;

  FixtureCard({
    this.homeTeamLogo,
    this.homeTeamName,
    this.awayTeamLogo,
    this.awayTeamName,
    this.advice,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
        ),
      ),
    );
  }
}

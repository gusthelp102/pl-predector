import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserPredictionsScreen extends StatelessWidget {
  final String? uid;

  UserPredictionsScreen({required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Predictions'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('predictions')
            .where('userId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final predictionDocs = snapshot.data?.docs;
          if (predictionDocs == null || predictionDocs.isEmpty) {
            return Center(child: Text('No predictions found.'));
          }

          return ListView.builder(
            itemCount: predictionDocs.length,
            itemBuilder: (context, index) {
              final predictionData =
                  predictionDocs[index].data() as Map<String, dynamic>;
              return PredictionCard(
                leagueName: predictionData['leagueName'],
                homeTeamName: predictionData['homeTeamName'],
                awayTeamName: predictionData['awayTeamName'],
                selectedWinner: predictionData['selectedWinner'],
                timestamp: predictionData['timestamp'],
              );
            },
          );
        },
      ),
    );
  }
}

class PredictionCard extends StatelessWidget {
  final String? leagueName;
  final String? homeTeamName;
  final String? awayTeamName;
  final String? selectedWinner;
  final Timestamp? timestamp;

  PredictionCard({
    this.leagueName,
    this.homeTeamName,
    this.awayTeamName,
    this.selectedWinner,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text('$homeTeamName vs $awayTeamName'),
        subtitle: Text('League: $leagueName\nSelected Winner: $selectedWinner'),
        trailing: Text(timestamp != null ? timestamp!.toDate().toString() : ''),
      ),
    );
  }
}

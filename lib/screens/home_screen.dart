import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../services/api_service.dart';
import 'fixture_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _predictions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPredictions();
  }

  Future<void> _fetchPredictions() async {
    try {
      final apiService = ApiService();
      final predictions = await apiService.getPredictionsForFiveFixtures();
      setState(() {
        _predictions = predictions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching predictions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshPredictions() async {
    try {
      final apiService = ApiService();
      final predictions = await apiService.getPredictionsForFiveFixtures();
      setState(() {
        _predictions = predictions;
      });
    } catch (e) {
      print('Error refreshing predictions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _refreshPredictions,
              child: ListView.builder(
                itemCount: _predictions.length,
                itemBuilder: (context, index) {
                  var prediction = _predictions[index];
                  prediction = prediction[0];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FixtureDetailScreen(
                            fixtureData: prediction,
                          ),
                        ),
                      );
                    },
                    child: PredictionCard(
                      leagueLogo: prediction['league']['logo'],
                      leagueName: prediction['league']['name'],
                      homeTeamLogo: prediction['teams']['home']['logo'],
                      homeTeamName: prediction['teams']['home']['name'],
                      awayTeamLogo: prediction['teams']['away']['logo'],
                      awayTeamName: prediction['teams']['away']['name'],
                      advice: prediction['predictions']['advice'],
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class PredictionCard extends StatelessWidget {
  final String? leagueLogo;
  final String? leagueName;
  final String? homeTeamLogo;
  final String? homeTeamName;
  final String? awayTeamLogo;
  final String? awayTeamName;
  final String? advice;

  PredictionCard({
    this.leagueLogo,
    this.leagueName,
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
          side: BorderSide(color: Colors.green, width: 1.5), // Green border
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              SizedBox(height: 10),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

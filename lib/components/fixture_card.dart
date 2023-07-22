import 'package:flutter/material.dart';

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
          padding: const EdgeInsets.all(12.0),
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

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiKey =
      '13c64b1909mshd0226621badc3dap10a2dcjsn2f557fb25460';
  Future<List<dynamic>> getPredictionsForFiveFixtures() async {
    final List<int> fixtureIds = [
      592141,
      592142,
      592143,
      592144,
      592145
    ]; // Replace with actual fixture IDs
    List<dynamic> allPredictions = [];

    final headers = {
      'x-rapidapi-host': 'api-football-v1.p.rapidapi.com',
      'x-rapidapi-key': apiKey,
    };

    for (int fixtureId in fixtureIds) {
      final url = Uri.parse(
          'https://api-football-v1.p.rapidapi.com/v3/predictions?fixture=$fixtureId');

      try {
        final response = await http.get(url, headers: headers);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          allPredictions.add(data);
        } else {
          throw Exception(
              'Failed to fetch predictions for fixture ID $fixtureId');
        }
      } catch (e) {
        throw Exception(
            'Failed to fetch predictions for fixture ID $fixtureId: $e');
      }
    }

    return allPredictions;
  }
}

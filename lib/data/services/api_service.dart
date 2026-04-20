import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rehab_app/data/models/exercise.dart';

class ApiService {
  static const String _host = 'exercisedb.p.rapidapi.com';
  static const String _apiKey =
      '7dc42d2980msh4c185a3f3e64321p136e50jsn354c952642c1';

  static const Map<String, String> authHeaders = {
    'x-rapidapi-key': _apiKey,
    'x-rapidapi-host': _host,
  };

  static const Exercise pinnedPushUp = Exercise(
    id: '0662',
    name: 'push-up',
    target: 'pectorals',
    bodyPart: 'chest',
  );

  Future<List<Exercise>> fetchExercises({int limit = 15}) async {
    final uri = Uri.https(_host, '/exercises', {'limit': '$limit'});

    final response = await http.get(uri, headers: authHeaders);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load exercises (status ${response.statusCode})',
      );
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    final exercises = decoded
        .whereType<Map<String, dynamic>>()
        .map(Exercise.fromJson)
        .where((e) => e.id != pinnedPushUp.id)
        .toList();

    exercises.insert(0, pinnedPushUp);
    return exercises;
  }

  static String gifUrl(String exerciseId, {int resolution = 360}) {
    return 'https://$_host/image?exerciseId=$exerciseId&resolution=$resolution';
  }
}

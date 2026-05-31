import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rehab_app/config/app_config.dart';
import 'package:rehab_app/data/models/exercise.dart';

class ApiService {
  static String get _host => AppConfig.rapidApiHost;

  static Map<String, String> get authHeaders => {
        'x-rapidapi-key': AppConfig.rapidApiKey,
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

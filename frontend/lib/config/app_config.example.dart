// Skopiuj ten plik jako app_config.dart i uzupełnij własnymi danymi.
// Plik app_config.dart jest gitignorowany i nie trafi do repozytorium.

class AppConfig {
  // Adres backendu Spring Boot:
  //   - emulator Android:  http://10.0.2.2:8080
  //   - fizyczne urządzenie: http://<IP_TWOJEJ_MASZYNY>:8080
  static const String backendUrl = 'http://TWOJE_IP:8080';

  // Klucz RapidAPI (exercisedb) — wygeneruj na rapidapi.com/justin-tooke/api/exercisedb
  static const String rapidApiKey = 'TWOJ_KLUCZ_RAPIDAPI';

  static const String rapidApiHost = 'exercisedb.p.rapidapi.com';
}

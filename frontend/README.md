# Digital Rehab — Frontend (Flutter)

Aplikacja mobilna do rehabilitacji z detekcją pozy opartą na ML Kit.

## Konfiguracja

Przed uruchomieniem skopiuj i uzupełnij plik konfiguracyjny:

```bash
cp lib/config/app_config.example.dart lib/config/app_config.dart
```

Ustaw w `app_config.dart`:
- `backendUrl` — adres IP maszyny z backendem
- `rapidApiKey` — klucz z [rapidapi.com/exercisedb](https://rapidapi.com/justin-tooke/api/exercisedb)

## Uruchomienie

```bash
flutter pub get
flutter run
```

## Architektura

```
lib/
├── config/
│   ├── app_config.dart         # Gitignorowany — uzupełnij własne dane
│   └── app_config.example.dart # Szablon konfiguracji
├── core/
│   └── theme.dart              # Motyw Dark/Glassmorphism
├── data/
│   ├── models/                 # Exercise, WorkoutSession
│   └── services/
│       └── api_service.dart    # ExerciseDB (RapidAPI)
├── ui/
│   ├── screens/
│   │   ├── welcome_screen.dart
│   │   ├── login_screen.dart
│   │   ├── main_shell.dart        # Shell klienta
│   │   ├── catalog_screen.dart    # Katalog ćwiczeń
│   │   ├── exercise_detail_screen.dart
│   │   ├── workout_history_screen.dart
│   │   ├── session_summary_screen.dart
│   │   ├── session_detail_screen.dart
│   │   ├── camera_screen.dart     # AI tracker
│   │   └── coach/                 # Panel trenera
│   │       ├── coach_main_screen.dart
│   │       ├── patient_list_screen.dart
│   │       ├── patient_detail_screen.dart
│   │       ├── plan_editor_screen.dart
│   │       └── video_review_screen.dart
│   └── widgets/
│       ├── glass_card.dart
│       ├── muscle_map.dart
│       └── pose_painter.dart
└── vision/
    ├── vision_engine.dart      # ML Kit pose detection
    └── push_up_counter.dart    # Logika liczenia powtórzeń
```

## Detekcja pozy

Kąt stawu obliczany ze wzoru:
```
angle = atan2(C.y - B.y, C.x - B.x) - atan2(A.y - B.y, A.x - B.x)
```

Automat stanów pompki:
- Faza dół: kąt łokcia < 90°
- Pełne wyprostowanie: kąt > 160° → zlicz powtórzenie

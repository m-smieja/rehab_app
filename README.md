1. Cel Projektu

Stworzenie natywnej, inteligentnej aplikacji mobilnej do rehabilitacji domowej. Aplikacja ma nie tylko służyć jako nowoczesny katalog ćwiczeń, ale przede wszystkim pełnić rolę osobistego asystenta AI, który na żywo śledzi ruchy użytkownika (Computer Vision) i automatycznie zlicza poprawnie wykonane powtórzenia.

    Motyw przewodni: Dark Modern / Glassmorphism.

    Kolorystyka tła: Głęboka czerń przechodząca w ciemny fiolet i granat (RadialGradient).

    Komponenty (GlassCard): Półprzezroczyste karty z minimalnym rozmyciem i subtelną, jasną ramką (efekt matowego szkła).

    Typografia: Potężne, czytelne i nowoczesne białe nagłówki (np. "DIGITAL REHAB").

Główne Moduły i Mechanika
Moduł 1: Dynamiczny Katalog Ćwiczeń

    Pobieranie danych z ExerciseDB 

    Wyświetlanie animacji ćwiczeń (GIF).

    Zasada krytyczna: Każde zapytanie o obraz musi zawierać dynamicznie doklejane ID oraz autoryzację w nagłówkach HTTP (klucz x-rapidapi-key i host), w przeciwnym razie serwer odrzuci połączenie.

Moduł 2: Asystent Ruchu AI (Pose Detection)

    Uruchomienie podglądu z przedniej kamery w czasie rzeczywistym.

    Rozpoznawanie punktów kluczowych ciała (szkielet) klatka po klatce przez Google ML Kit.

Moduł 3: Logika Liczenia Powtórzeń 

Silnik matematyczny obliczający na bieżąco kąt zgięcia w stawie.

    Punkty odniesienia: Ramię (P1​), Łokieć (P2​), Nadgarstek (P3​).

    Kąt (θ): Mierzony z użyciem twierdzenia cosinusów lub wektorów 2D/3D zebranych z kamery:
    θ=arccos(∣a∣⋅∣b∣a⋅b​)

    Stany licznika: * Faza zejścia: θ<90∘ (uruchamia flagę "w dół").

        Faza wyprostu: θ>160∘ i aktywna flaga (zalicza 1 powtórzenie, resetuje flagę).
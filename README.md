# Digital Rehab App

Aplikacja mobilna wspomagająca rehabilitację i ćwiczenia fizyczne z panelem klienta oraz panelem trenera/fizjoterapeuty. Zbudowana we Flutterze (frontend) i Spring Boot (backend) z bazą danych MySQL.

---

## Wymagania

| Narzędzie | Wersja |
|---|---|
| Flutter | 3.41+ |
| Dart | 3.11+ |
| Java (JDK) | 17+ |
| Docker | dowolna aktualna |
| Android SDK | API 24+ |

---

## Uruchomienie — krok po kroku

### 1. Baza danych (MySQL w Dockerze)

```bash
# Pierwsze uruchomienie
sudo docker run -d \
  --name rehab_mysql \
  -e MYSQL_ALLOW_EMPTY_PASSWORD=yes \
  -e MYSQL_DATABASE=rehab_db \
  -p 3306:3306 \
  mysql:8

# Kolejne uruchomienia (kontener już istnieje)
sudo docker start rehab_mysql
```

### 2. Backend (Spring Boot)

```bash
cd backend
chmod +x mvnw
./mvnw spring-boot:run
```

Backend startuje na `http://localhost:8080`.  
Przy pierwszym uruchomieniu **DataInitializer** automatycznie wypełnia bazę danymi demonstracyjnymi.

### 3. Frontend (Flutter)

#### Konfiguracja przed uruchomieniem

Skopiuj plik konfiguracyjny i uzupełnij własne dane:

```bash
cp frontend/lib/config/app_config.example.dart frontend/lib/config/app_config.dart
```

Edytuj `app_config.dart`:
- `backendUrl` — ustaw na IP swojej maszyny (np. `http://192.168.1.100:8080`)
  - Emulator Android: `http://10.0.2.2:8080`
  - Fizyczne urządzenie: `http://<IP_TWOJEJ_MASZYNY>:8080`
- `rapidApiKey` — wygeneruj klucz na [rapidapi.com](https://rapidapi.com/justin-tooke/api/exercisedb)

> **Jak sprawdzić IP maszyny:** `hostname -I | awk '{print $1}'`

#### Uruchomienie

```bash
cd frontend
flutter pub get
flutter run
```

Lub na konkretnym urządzeniu:

```bash
flutter devices                          # lista urządzeń
flutter run -d <ID_URZĄDZENIA>
```

---

## Dane demonstracyjne

Po pierwszym uruchomieniu backendu w bazie dostępne są konta testowe:

| Rola | Email | Hasło |
|---|---|---|
| Trener | `trener@test.com` | `trener123` |
| Klient | `klient@test.com` | `klient123` |
| Pacjent demo | `marek.kowalski@demo.pl` | `demo1234` |
| Pacjent demo | `anna.nowak@demo.pl` | `demo1234` |
| Pacjent demo | `piotr.wisniewski@demo.pl` | `demo1234` |
| Pacjent demo | `katarzyna.wojcik@demo.pl` | `demo1234` |
| Pacjent demo | `tomasz.lewandowski@demo.pl` | `demo1234` |

Pacjenci demo są przypisani do konta trenera.

---

## Struktura projektu

```
rehab_app/
├── frontend/          # Aplikacja Flutter
│   ├── lib/
│   │   ├── config/    # Konfiguracja (app_config.dart — gitignorowany)
│   │   ├── core/      # Motyw aplikacji
│   │   ├── data/      # Modele i serwisy API
│   │   ├── ui/
│   │   │   ├── screens/
│   │   │   │   ├── coach/     # Panel trenera/fizjoterapeuty
│   │   │   │   └── ...        # Ekrany klienta
│   │   │   └── widgets/
│   │   └── vision/    # Detekcja pozy (ML Kit)
│   └── pubspec.yaml
└── backend/           # API Spring Boot
    └── src/main/java/com/example/demo/
        ├── controllers/
        ├── entities/
        ├── repositories/
        └── DataInitializer.java
```

---

## API — główne endpointy

| Metoda | Endpoint | Opis |
|---|---|---|
| POST | `/api/users/newAccount` | Rejestracja |
| POST | `/api/users/login` | Logowanie |
| GET | `/trainers/{id}/clients` | Lista pacjentów trenera |
| GET | `/users/{id}/progress` | Historia ćwiczeń użytkownika |

---

## Funkcje aplikacji

### Panel klienta
- Katalog ćwiczeń (dane z ExerciseDB API)
- Śledzenie treningów z kamerą (AI detekcja pozy — ML Kit)
- Licznik powtórzeń
- Historia sesji treningowych

### Panel trenera / fizjoterapeuty
- Lista pacjentów ze statusem (aktywny / nieobecny / ból zgłoszony)
- Szczegóły pacjenta z telemetrią i planem ćwiczeń
- Przegląd wideo (w budowie)
- Wiadomości (w budowie)

---

## Znane ograniczenia

- Panel trenera używa danych poglądowych (brak pełnej integracji z backendem)
- Historia treningów przechowywana lokalnie (Hive) — nie synchronizowana z bazą
- Brak szyfrowania haseł (TODO w kodzie backendu)

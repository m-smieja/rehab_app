# System Monitorowania Rehabilitacji - Dokumentacja API & Bazy Danych

Dokumentacja techniczna backendu napisanego w **Spring Boot**. Zawiera instrukcje wdrożenia bazy danych MySQL oraz kompletny podręcznik integracji dla zespołu developerskiego Flutter (Frontend).

---

## 1. Struktura Bazy Danych (MySQL)

Baza danych opiera się na trzech głównych tabelach. Aby zachować prostotę logowania i spójność kont, relacja między **Trenerem** a **Klientem (Pacjentem)** została zrealizowana jako **relacja samoreferencyjna (self-referential)** wewnątrz jednej tabeli `users`.

### Architektura Tabel i Relacji
1. **`users`**: Przechowuje wszystkich użytkowników. Kolumna `trainer_id` jest kluczem obcym wskazującym na `id` innego użytkownika w tej samej tabeli (który musi mieć rolę `TRENER`). Dla trenerów to pole pozostaje puste (`NULL`).
2. **`exercises`**: Słownik zawierający katalog ćwiczeń (np. pompki, przysiady, ćwiczenia z gumą).
3. **`exercise_history`**: Tabela łącząca, rejestrująca każdy zakończony trening pacjenta wraz z danymi z AI (powtórzenia, celność).

### Skrypt DDL (SQL) do Utworzenia Bazy

```sql
CREATE DATABASE IF NOT EXISTS rehab_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE rehab_db;

-- 1. Tabela Użytkowników (Klienci i Trenerzy w jednym)
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(191) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL, -- Wartości: 'KLIENT' lub 'TRENER'
    trainer_id BIGINT NULL,
    CONSTRAINT fk_user_trainer FOREIGN KEY (trainer_id) REFERENCES users(id) ON DELETE SET NULL
);

-- 2. Tabela Katalogu Ćwiczeń
CREATE TABLE exercises (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL
);

-- 3. Tabela Historii Treningów (Wyniki AI)
CREATE TABLE exercise_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    exercise_id BIGINT NOT NULL,
    repetitions INT NOT NULL,
    accuracy INT NOT NULL, -- Wartość procentowa 0-100
    created_at DATETIME NOT NULL,
    CONSTRAINT fk_history_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_history_exercise FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
);
```

---

## 2. Przewodnik Integracji dla Frontendu (Flutter)

### Uwaga Dotycząca Adresów IP
* **Emulator Androida:** Aby połączyć się z backendem uruchomionym na `localhost:8080`, we Flutterze musisz wysyłać zapytania na adres: **`http://10.0.2.2:8080`**.
* **Fizyczny Telefon (USB/Wi-Fi):** Telefon nie widzi `localhost` Twojego komputera. Oba urządzenia muszą być w tej samej sieci Wi-Fi, a w kodzie Fluttera musisz podać adres IPv4 swojego komputera (sprawdź przez `ipconfig` w Windows), np. **`http://192.168.1.50:8080`**.

### Bezpieczeństwo haseł w JSON
Backend używa adnotacji `@JsonProperty(access = JsonProperty.Access.WRITE_ONLY)` na polu `password`. Oznacza to, że **frontend musi wysłać hasło podczas rejestracji/logowania, ale serwer nigdy nie odeśle hasła w odpowiedzi** (pole zostanie całkowicie wycięte z JSON-a zwrotnego dla bezpieczeństwa).

---

## 3. Specyfikacja Endpointów REST API

### Autentykacja i Konta Użytkowników

#### A. Rejestracja Nowego Konta
Tworzy profil użytkownika. Jeśli rejestruje się `KLIENT`, można od razu przypisać go do trenera, podając obiekt `trainer` z jego ID.

* **URL:** `/api/users/newAccount`
* **Metoda:** `POST`
* **Nagłówki:** `Content-Type: application/json`
* **Body (Rejestracja Trenera lub Klienta bez przypisanego trenera):**
```json
{
  "email": "jan.kowalski@example.com",
  "password": "Tajny@PasSword1",
  "role": "KLIENT" 
}
```
* **Body (Rejestracja Klienta z podpięciem pod konkretnego Trenera o ID = 1):**
```json
{
  "email": "pacjent.nowak@example.com",
  "password": "superbezpiecznehaslo",
  "role": "KLIENT",
  "trainer": {
    "id": 1
  }
}
```
* **Odpowiedzi:**
    * **`201 Created`** lub **`200 OK`**: Konto utworzone pomyślnie.
    * **`400 Bad Request`**: Błąd walidacji (niepoprawny format e-mail, hasło krótsze niż 6 znaków lub nieprawidłowa rola).
    * **`409 Conflict`**: Podany adres e-mail jest już zajęty.

---

#### B. Logowanie Użytkownika
*Uwaga: Logowanie odbywa się metodą `POST` z body, ze względów bezpieczeństwa protokołu HTTP.*

* **URL:** `/api/users/login`
* **Metoda:** `POST`
* **Nagłówki:** `Content-Type: application/json`
* **Body:**
```json
{
  "email": "jan.kowalski@example.com",
  "password": "Tajny@PasSword1"
}
```
* **Odpowiedzi:**
    * **`200 OK`**: Logowanie udane. W ciele odpowiedzi zwracany jest profil użytkownika (bez hasła!):
      ```json
      {
        "id": 5,
        "email": "jan.kowalski@example.com",
        "role": "KLIENT",
        "trainer": null
      }
      ```
    * **`400 Bad Request`**: Podany e-mail nie istnieje w systemie.
    * **`403 Forbidden`**: Podane hasło jest nieprawidłowe.

---

### Katalog Ćwiczeń i Treningi (Wyniki AI)

#### C. Pobranie Listy Ćwiczeń (Katalog)
Służy do wyświetlenia listy dostępnych ćwiczeń w aplikacji pacjenta.

* **URL:** `/api/exercises`
* **Metoda:** `GET`
* **Odpowiedź (`200 OK`):**
```json
[
  {
    "id": 1,
    "name": "Pompki klasyczne",
    "description": "Utrzymuj proste plecy, opuszczaj klatkę piersiową tuż nad podłogę."
  },
  {
    "id": 2,
    "name": "Przysiady rehabilitacyjne",
    "description": "Stopo na szerokość barków, nie wysuwaj kolan przed palce stóp."
  }
]
```

---

#### D. Zapisanie Wyniku Treningu (Wysyłka danych z modułu AI)
Wywoływane przez Flutter w momencie, gdy moduł wizyjny (kamera z AI) zakończy liczenie powtórzeń i analizę poprawności.

* **URL:** `/api/history`
* **Metoda:** `POST`
* **Nagłówki:** `Content-Type: application/json`
* **Body:**
```json
{
  "user": {
    "id": 5
  },
  "exercise": {
    "id": 1
  },
  "repetitions": 12,
  "accuracy": 88
}
```
* **Odpowiedź (`201 Created`):** Zwraca zapisany rekord z automatycznie wygenerowaną datą serwera:
```json
{
  "id": 42,
  "user": { "id": 5, "email": "jan.kowalski@example.com", "role": "KLIENT", "trainer": null },
  "exercise": { "id": 1, "name": "Pompki klasyczne", "description": "..." },
  "repetitions": 12,
  "accuracy": 88,
  "createdAt": "2026-05-16T13:15:22"
}
```

---

#### E. Historia Treningów Pacjenta
Używane, gdy Pacjent wchodzi w swój profil/zakładkę statystyk, aby zobaczyć swoje archiwalne treningi.

* **URL:** `/api/users/{id}/history` (gdzie `{id}` to ID logowanego pacjenta, np. `/api/users/5/history`)
* **Metoda:** `GET`
* **Odpowiedź (`200 OK`):** Lista treningów posegregowana od najnowszych:
```json
[
  {
    "id": 42,
    "exercise": { "id": 1, "name": "Pompki klasyczne" },
    "repetitions": 12,
    "accuracy": 88,
    "createdAt": "2026-05-16T13:15:22"
  }
]
```

---

### Panel Trenera / Fizjoterapeuty

#### F. Pobranie Listy Podopiecznych (Pacjentów)
Wywoływane po zalogowaniu się jako Trener, aby zbudować listę jego pacjentów w aplikacji.

* **URL:** `/api/trainers/{id}/clients` (gdzie `{id}` to ID zalogowanego trenera, np. `/api/trainers/1/clients`)
* **Metoda:** `GET`
* **Odpowiedź (`200 OK`):** Tablica pacjentów przypisanych do tego trenera:
```json
[
  {
    "id": 5,
    "email": "jan.kowalski@example.com",
    "role": "KLIENT"
  },
  {
    "id": 9,
    "email": "anna.nowak@example.com",
    "role": "KLIENT"
  }
]
```

---

#### G. Postępy Konkretnego Pacjenta (Widok dla Trenera)
Wywoływane, gdy Trener kliknie w konkretnego pacjenta ze swojej listy, aby skontrolować jego zaangażowanie i poprawność ćwiczeń w domu.

* **URL:** `/api/users/{id}/progress` (gdzie `{id}` to ID sprawdzanego pacjenta, np. `/api/users/5/progress`)
* **Metoda:** `GET`
* **Odpowiedź (`200 OK`):** Zwraca pełną historię ćwiczeń danego pacjenta (analogicznie do endpointu E), umożliwiając trenerowi wgląd w dane.
```json
[
  {
    "id": 42,
    "exercise": { "id": 1, "name": "Pompki klasyczne" },
    "repetitions": 12,
    "accuracy": 88,
    "createdAt": "2026-05-16T13:15:22"
  }
]
```
# Digital Rehab — Backend (Spring Boot)

REST API dla aplikacji rehabilitacyjnej. Baza danych MySQL, automatyczny seed danych demonstracyjnych.

## Wymagania

- Java 17+
- MySQL 8 (lub Docker)

## Uruchomienie

### 1. Baza danych

```bash
# Docker (zalecane)
sudo docker run -d --name rehab_mysql \
  -e MYSQL_ALLOW_EMPTY_PASSWORD=yes \
  -e MYSQL_DATABASE=rehab_db \
  -p 3306:3306 mysql:8

# lub lokalna instalacja MySQL
sudo systemctl start mysql
mysql -u root -e "CREATE DATABASE IF NOT EXISTS rehab_db;"
```

### 2. Backend

```bash
chmod +x mvnw
./mvnw spring-boot:run
```

Serwer startuje na `http://localhost:8080`.

Przy pierwszym uruchomieniu `DataInitializer` automatycznie tworzy konta demonstracyjne.

## Schemat bazy danych

### Tabela `users`

| Kolumna | Typ | Opis |
|---|---|---|
| id | BIGINT (PK) | Auto-increment |
| email | VARCHAR | Unikalny |
| password | VARCHAR | Tylko zapis (WRITE_ONLY w JSON) |
| role | VARCHAR | `KLIENT` lub `TRENER` |
| trainer_id | BIGINT (FK) | Opcjonalny — przypisany trener |

### Tabela `exercises`

| Kolumna | Typ | Opis |
|---|---|---|
| id | BIGINT (PK) | |
| name | VARCHAR | Nazwa ćwiczenia |
| body_part | VARCHAR | Część ciała |

### Tabela `exercise_history`

| Kolumna | Typ | Opis |
|---|---|---|
| id | BIGINT (PK) | |
| user_id | BIGINT (FK) | Kto ćwiczył |
| exercise_id | BIGINT (FK) | Co ćwiczył |
| repetitions | INT | Liczba powtórzeń |
| accuracy | INT | Poprawność 0–100% |
| created_at | DATETIME | Kiedy ćwiczył |

## Endpointy API

### Użytkownicy

```
POST /api/users/newAccount
```
Rejestracja. Body:
```json
{
  "email": "jan@example.com",
  "password": "haslo123",
  "role": "KLIENT",
  "trainer": { "id": 1 }  // opcjonalne — ID trenera
}
```

```
POST /api/users/login
```
Logowanie. Body:
```json
{ "email": "jan@example.com", "password": "haslo123" }
```
Zwraca obiekt użytkownika z polem `role` (`KLIENT`/`TRENER`).

```
GET /trainers/{id}/clients
```
Lista pacjentów przypisanych do trenera.

```
GET /users/{id}/progress
```
Historia ćwiczeń użytkownika.

## Konta demonstracyjne

Tworzone automatycznie przy pierwszym starcie:

| Rola | Email | Hasło |
|---|---|---|
| Trener | `trener@test.com` | `trener123` |
| Klient | `klient@test.com` | `klient123` |
| Pacjenci demo | `*.demo.pl` | `demo1234` |

## Uwagi

- Hasła przechowywane plaintext — TODO: dodać BCrypt
- Pole `password` oznaczone `@JsonProperty(WRITE_ONLY)` — nie pojawia się w odpowiedziach GET
- Adres backendu dla fizycznego urządzenia: IP maszyny w sieci lokalnej, port 8080
- Adres backendu dla emulatora Android: `http://10.0.2.2:8080`

package com.example.demo.controllers;

import com.example.demo.entities.Exercises;
import com.example.demo.entities.ExercisesHistory;
import com.example.demo.entities.Users;
import com.example.demo.repositories.ExercisesHistoryRepository;
import com.example.demo.repositories.UsersRepository;
import org.apache.commons.validator.routines.EmailValidator;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
public class UsersController {

    private static final String PASSWORD_PATTERN = "\\w{6,}";
    private final UsersRepository userRepository;
    private final ExercisesHistoryRepository exercisesHistoryRepository;

    public UsersController(UsersRepository userRepository, ExercisesHistoryRepository exercisesHistoryRepository) {
        this.userRepository = userRepository;
        this.exercisesHistoryRepository = exercisesHistoryRepository;
    }

    // Tworzenie nowego konta
    @PostMapping("/api/users/newAccount")
    public ResponseEntity<?> addNewUser(@RequestBody Users users){
        if(!EmailValidator.getInstance().isValid(users.getEmail()) || !users.getPassword().matches(PASSWORD_PATTERN)){
            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body("Niepoprawny format email lub hasła (min. 6 znaków).");
        }
        if (userRepository.findByEmail(users.getEmail()) != null){
            return ResponseEntity
                    .status(HttpStatus.CONFLICT)
                    .body("Podany adres email jest już zajęty.");
        }
        if (!users.getRole().equals("KLIENT") && !users.getRole().equals("TRENER")){
            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body("Nieprawidłowa rola. Dozwolone: KLIENT, TRENER.");
        }

        if (users.getRole().equals("KLIENT")) {
            // Sprawdzamy czy frontend przysłał obiekt trenera i czy ten obiekt ma ID
            if (users.getTrainer() != null && users.getTrainer().getId() != null) {
                Long trainerId = users.getTrainer().getId();

                // Szukamy trenera w bazie danych
                java.util.Optional<Users> dbTrainer = userRepository.findById(trainerId);

                if (dbTrainer.isEmpty()) {
                    return ResponseEntity
                            .status(HttpStatus.BAD_REQUEST)
                            .body("Nie znaleziono trenera o podanym ID: " + trainerId);
                }

                // Sprawdzamy, czy użytkownik z bazy o tym ID na pewno ma rolę TRENER
                if (!dbTrainer.get().getRole().equals("TRENER")) {
                    return ResponseEntity
                            .status(HttpStatus.BAD_REQUEST)
                            .body("Użytkownik o ID " + trainerId + " nie jest trenerem!");
                }

                // Wszystko ok, podczepiamy pełny obiekt trenera z bazy danych
                users.setTrainer(dbTrainer.get());
            } else {
                // Klient rejestruje się bez trenera (opcjonalne, pole trainer_id będzie NULL)
                users.setTrainer(null);
            }
        } else {
            // Jeśli rejestruje się TRENER, to na wszelki wypadek czyścimy pole trenera na null
            users.setTrainer(null);
        }


        Users savedUsers = userRepository.save(users);


        return ResponseEntity
                .status(HttpStatus.OK)
                .body(savedUsers);
    }

    // Logowanie
    @PostMapping("api/users/login")
    public ResponseEntity<Users> loginUser(@RequestBody Users users){
        if (users.getEmail() == null){
            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .build();
        }
        Users byEmail = userRepository.findByEmail(users.getEmail());

        if (byEmail == null){
            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .build();
        }



        if (byEmail.getPassword().equals(users.getPassword())){
            return ResponseEntity
                    .status(HttpStatus.CREATED)
                    .body(byEmail);
        }

        return ResponseEntity
                .status(HttpStatus.FORBIDDEN)
                .build();
    }

    // Lista pacjentów przypisanych do trenera
    @GetMapping("/trainers/{id}/clients")
    public ResponseEntity<List<Users>> getMyClients(@PathVariable Long id) {
        // W UserRepository musisz dopisać: List<User> findByTrainerId(Long trainerId);
        List<Users> clients = userRepository.findByTrainerId(id);
        return ResponseEntity.ok(clients);
    }

    // Postępy pacjenta widoczne dla trenera
    @GetMapping("/users/{id}/progress")
    public ResponseEntity<List<ExercisesHistory>> getClientProgress(@PathVariable Long id) {
        List<ExercisesHistory> progress = exercisesHistoryRepository.findByUserId(id);
        return ResponseEntity.ok(progress);
    }

    // TODO Ewentualnie dodać szyfrowanie haseł oraz DTO



}

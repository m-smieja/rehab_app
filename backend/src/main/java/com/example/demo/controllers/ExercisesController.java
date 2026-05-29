package com.example.demo.controllers;

import com.example.demo.entities.Exercises;
import com.example.demo.entities.ExercisesHistory;
import com.example.demo.repositories.ExercisesHistoryRepository;
import com.example.demo.repositories.ExercisesRepository;
import com.example.demo.repositories.UsersRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
public class ExercisesController {
    private final ExercisesRepository exerciseRepository;
    private final ExercisesHistoryRepository historyRepository;
    private final UsersRepository userRepository; // do wyciągania userów z ID

    public ExercisesController(ExercisesRepository exerciseRepository, ExercisesHistoryRepository historyRepository, UsersRepository userRepository) {
        this.exerciseRepository = exerciseRepository;
        this.historyRepository = historyRepository;
        this.userRepository = userRepository;
    }

    // Pobieranie listy dostępnych ćwiczeń
    @GetMapping("/api/exercises")
    public List<Exercises> getAllExercises() {
        return exerciseRepository.findAll();
    }

    // Zapisywanie wyniku treningu z telefonu
    @PostMapping("/api/history")
    public ResponseEntity<ExercisesHistory> saveHistory(@RequestBody ExercisesHistory history) {
        // Frontend wyśle JSON-a z "user": {"id": X} i "exercise": {"id": Y}
        ExercisesHistory saved = historyRepository.save(history);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    // Historia konkretnego pacjenta
    @GetMapping("/users/{id}/history")
    public ResponseEntity<List<ExercisesHistory>> getUserHistory(@PathVariable Long id) {
        List<ExercisesHistory> history = historyRepository.findByUserId(id);
        return ResponseEntity.ok(history);
    }
}

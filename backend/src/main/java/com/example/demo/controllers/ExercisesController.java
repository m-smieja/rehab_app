package com.example.demo.controllers;

import com.example.demo.entities.Exercises;
import com.example.demo.entities.ExercisesHistory;
import com.example.demo.repositories.ExercisesHistoryRepository;
import com.example.demo.repositories.ExercisesRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
public class ExercisesController {

    private final ExercisesRepository exercisesRepository;
    private final ExercisesHistoryRepository exercisesHistoryRepository;

    public ExercisesController(ExercisesRepository exercisesRepository,
                               ExercisesHistoryRepository exercisesHistoryRepository) {
        this.exercisesRepository = exercisesRepository;
        this.exercisesHistoryRepository = exercisesHistoryRepository;
    }

    @GetMapping("/api/exercises")
    public ResponseEntity<List<Exercises>> getAllExercises() {
        return ResponseEntity.ok(exercisesRepository.findAll());
    }

    @PostMapping("/api/history")
    public ResponseEntity<ExercisesHistory> addHistory(@RequestBody ExercisesHistory history) {
        history.setCreatedAt(LocalDateTime.now());
        ExercisesHistory saved = exercisesHistoryRepository.save(history);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @GetMapping("/users/{id}/history")
    public ResponseEntity<List<ExercisesHistory>> getUserHistory(@PathVariable Long id) {
        return ResponseEntity.ok(exercisesHistoryRepository.findByUserId(id));
    }
}

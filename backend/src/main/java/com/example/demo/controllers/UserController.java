package com.example.demo.controllers;

import com.example.demo.entities.Users;
import com.example.demo.repositories.UserRepository;
import org.apache.commons.validator.routines.EmailValidator;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
public class UserController {

    private static final String PASSWORD_PATTERN = "\\w{6,}";
    private final UserRepository userRepository;

    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @PostMapping("/api/users/newAccount")
    public ResponseEntity<Users> addNewUser(@RequestBody Users users) {
        if (!EmailValidator.getInstance().isValid(users.getEmail())
                || users.getPassword() == null
                || !users.getPassword().matches(PASSWORD_PATTERN)) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
        if (userRepository.findByEmail(users.getEmail()) != null) {
            return ResponseEntity.status(HttpStatus.CONFLICT).build();
        }
        if (!users.getRole().equals("KLIENT") && !users.getRole().equals("TRENER")) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
        if (users.getRole().equals("KLIENT") && users.getTrainer() != null) {
            Long trainerId = users.getTrainer().getId();
            Optional<Users> trainerOpt = userRepository.findById(trainerId);
            if (trainerOpt.isEmpty()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
            }
            if (!trainerOpt.get().getRole().equals("TRENER")) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
            }
        }
        Users saved = userRepository.save(users);
        return ResponseEntity.status(HttpStatus.OK).body(saved);
    }

    @PostMapping("/api/users/login")
    public ResponseEntity<Users> loginUser(@RequestBody Users users) {
        if (users.getEmail() == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
        Users byEmail = userRepository.findByEmail(users.getEmail());
        if (byEmail == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
        if (byEmail.getPassword().equals(users.getPassword())) {
            return ResponseEntity.status(HttpStatus.CREATED).body(byEmail);
        }
        return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
    }

    @GetMapping("/trainers/{id}/clients")
    public ResponseEntity<List<Users>> getTrainerClients(@PathVariable Long id) {
        List<Users> clients = userRepository.findByTrainerId(id);
        return ResponseEntity.ok(clients);
    }
}

package com.example.demo.controllers;

import com.example.demo.entities.Users;
import com.example.demo.repositories.UserRepository;
import org.apache.commons.validator.routines.EmailValidator;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;


@RestController
public class UserController {

    private static final String PASSWORD_PATTERN = "\\w{6,}";
    private final UserRepository userRepository;

    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @PostMapping("/api/users/newAccount")
    public ResponseEntity<Users> addNewUser(@RequestBody Users users){
        if(!EmailValidator.getInstance().isValid(users.getEmail()) || !users.getPassword().matches(PASSWORD_PATTERN)){
            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .build();
        }
        if (userRepository.findByEmail(users.getEmail()) != null){
            return ResponseEntity
                    .status(HttpStatus.CONFLICT)
                    .build();
        }
        if (!users.getRole().equals("KLIENT") && !users.getRole().equals("TRENER")){
            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .build();
        }


        Users savedUsers = userRepository.save(users);


        return ResponseEntity
                .status(HttpStatus.OK)
                .body(savedUsers);
    }

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

    //TODO POST /api/history - do zapisu postępu ćwiczeń
    //TODO GET /api/users/{id}/history - żeby klient widział swój postęp
    //TODO GET /api/trainers/{id}/clients - dla trenera żeby widział przypisanych klientów
    //TODO GET /api/users/{id}/progress - dla trenera żeby widział postęp przypisanego klienta
    // Ewentualnie dodać szyfrowanie haseł oraz DTO



}

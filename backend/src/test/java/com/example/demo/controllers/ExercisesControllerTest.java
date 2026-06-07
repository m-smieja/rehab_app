package com.example.demo.controllers;

import com.example.demo.entities.Exercises;
import com.example.demo.entities.ExercisesHistory;
import com.example.demo.entities.Users;
import com.example.demo.repositories.ExercisesHistoryRepository;
import com.example.demo.repositories.ExercisesRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(ExercisesController.class)
class ExercisesControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private ExercisesRepository exercisesRepository;

    @MockitoBean
    private ExercisesHistoryRepository exercisesHistoryRepository;

    // --- GET /api/exercises ---

    @Test
    @DisplayName("Pobranie listy ćwiczeń zwraca listę i 200")
    void pobierzCwiczenia_listaIstnieje_zwracaListeI200() throws Exception {
        Exercises e1 = exercise(1L, "Przysiad", "Ćwiczenie nóg");
        Exercises e2 = exercise(2L, "Pompka", "Ćwiczenie ramion");
        given(exercisesRepository.findAll()).willReturn(List.of(e1, e2));

        mockMvc.perform(get("/api/exercises"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(2))
                .andExpect(jsonPath("$[0].name").value("Przysiad"))
                .andExpect(jsonPath("$[1].name").value("Pompka"));
    }

    @Test
    @DisplayName("Pobranie ćwiczeń gdy baza jest pusta zwraca pustą listę i 200")
    void pobierzCwiczenia_bazaPusta_zwracaPustaListeI200() throws Exception {
        given(exercisesRepository.findAll()).willReturn(List.of());

        mockMvc.perform(get("/api/exercises"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(0));
    }

    // --- POST /api/history ---

    @Test
    @DisplayName("Dodanie historii ćwiczenia z poprawnym body zwraca 201")
    void dodajHistorie_poprawneDane_zwraca201() throws Exception {
        Users user = new Users();
        user.setId(1L);
        Exercises ex = exercise(1L, "Przysiad", "Ćwiczenie nóg");

        ExercisesHistory saved = history(10L, user, ex, 15, 90);
        given(exercisesHistoryRepository.save(any())).willReturn(saved);

        String body = """
                {
                  "user": {"id": 1},
                  "exercise": {"id": 1},
                  "repetitions": 15,
                  "accuracy": 90
                }
                """;

        mockMvc.perform(post("/api/history")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.repetitions").value(15))
                .andExpect(jsonPath("$.accuracy").value(90));
    }

    // --- GET /users/{id}/history ---

    @Test
    @DisplayName("Pobranie historii ćwiczeń użytkownika zwraca listę i 200")
    void pobierzHistorie_uzytkownikMaHistorie_zwracaListeI200() throws Exception {
        Users user = new Users();
        user.setId(1L);
        Exercises ex = exercise(1L, "Przysiad", "Ćwiczenie nóg");

        ExercisesHistory h1 = history(1L, user, ex, 10, 80);
        ExercisesHistory h2 = history(2L, user, ex, 12, 85);
        given(exercisesHistoryRepository.findByUserId(1L)).willReturn(List.of(h1, h2));

        mockMvc.perform(get("/users/1/history"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(2))
                .andExpect(jsonPath("$[0].repetitions").value(10))
                .andExpect(jsonPath("$[1].repetitions").value(12));
    }

    // --- Metody pomocnicze ---

    private Exercises exercise(Long id, String name, String description) {
        return new Exercises(id, name, description);
    }

    private ExercisesHistory history(Long id, Users user, Exercises exercise, int reps, int accuracy) {
        return new ExercisesHistory(id, user, exercise, reps, accuracy, LocalDateTime.now());
    }
}

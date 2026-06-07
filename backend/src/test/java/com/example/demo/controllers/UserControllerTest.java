package com.example.demo.controllers;

import com.example.demo.entities.Users;
import com.example.demo.repositories.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(UserController.class)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private UserRepository userRepository;

    // --- POST /api/users/newAccount ---

    @Test
    @DisplayName("Rejestracja TRENERA z poprawnymi danymi zwraca 200")
    void noweKonto_poprawnaDanaTrainera_zwraca200() throws Exception {
        Users saved = user(1L, "trener@test.com", "TRENER", null);
        given(userRepository.findByEmail("trener@test.com")).willReturn(null);
        given(userRepository.save(any())).willReturn(saved);

        mockMvc.perform(post("/api/users/newAccount")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(jsonUser("trener@test.com", "haslo123", "TRENER", null)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.role").value("TRENER"));
    }

    @Test
    @DisplayName("Rejestracja KLIENTA z istniejącym trenerem zwraca 200")
    void noweKonto_klientZTrainerem_zwraca200() throws Exception {
        Users trainer = user(1L, "trener@test.com", "TRENER", null);
        Users saved = user(2L, "klient@test.com", "KLIENT", trainer);
        given(userRepository.findByEmail("klient@test.com")).willReturn(null);
        given(userRepository.findById(1L)).willReturn(Optional.of(trainer));
        given(userRepository.save(any())).willReturn(saved);

        mockMvc.perform(post("/api/users/newAccount")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(jsonUser("klient@test.com", "haslo123", "KLIENT", 1L)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.role").value("KLIENT"));
    }

    @Test
    @DisplayName("Rejestracja KLIENTA bez trenera zwraca 200")
    void noweKonto_klientBezTrenera_zwraca200() throws Exception {
        Users saved = user(2L, "klient@test.com", "KLIENT", null);
        given(userRepository.findByEmail("klient@test.com")).willReturn(null);
        given(userRepository.save(any())).willReturn(saved);

        mockMvc.perform(post("/api/users/newAccount")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(jsonUser("klient@test.com", "haslo123", "KLIENT", null)))
                .andExpect(status().isOk());
    }

    @Test
    @DisplayName("Niepoprawny format emaila zwraca 400")
    void noweKonto_niepoprawnyEmail_zwraca400() throws Exception {
        mockMvc.perform(post("/api/users/newAccount")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(jsonUser("to-nie-email", "haslo123", "KLIENT", null)))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("Hasło krótsze niż 6 znaków zwraca 400")
    void noweKonto_zaKrotkieHaslo_zwraca400() throws Exception {
        mockMvc.perform(post("/api/users/newAccount")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(jsonUser("klient@test.com", "abc", "KLIENT", null)))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("Zduplikowany email zwraca 409")
    void noweKonto_zduplikowanyEmail_zwraca409() throws Exception {
        Users existing = user(1L, "klient@test.com", "KLIENT", null);
        given(userRepository.findByEmail("klient@test.com")).willReturn(existing);

        mockMvc.perform(post("/api/users/newAccount")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(jsonUser("klient@test.com", "haslo456", "KLIENT", null)))
                .andExpect(status().isConflict());
    }

    @Test
    @DisplayName("Nieprawidłowa rola ADMIN zwraca 400")
    void noweKonto_nieprawidlowaRola_zwraca400() throws Exception {
        given(userRepository.findByEmail("admin@test.com")).willReturn(null);

        mockMvc.perform(post("/api/users/newAccount")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(jsonUser("admin@test.com", "haslo123", "ADMIN", null)))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("Klient podaje ID nieistniejącego trenera zwraca 400")
    void noweKonto_nieistniejacyTrener_zwraca400() throws Exception {
        given(userRepository.findByEmail("klient@test.com")).willReturn(null);
        given(userRepository.findById(99L)).willReturn(Optional.empty());

        mockMvc.perform(post("/api/users/newAccount")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(jsonUser("klient@test.com", "haslo123", "KLIENT", 99L)))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("Klient podaje ID użytkownika bez roli TRENER zwraca 400")
    void noweKonto_trenerIdWskazujeNaKlienta_zwraca400() throws Exception {
        Users notATrainer = user(5L, "inny@test.com", "KLIENT", null);
        given(userRepository.findByEmail("klient@test.com")).willReturn(null);
        given(userRepository.findById(5L)).willReturn(Optional.of(notATrainer));

        mockMvc.perform(post("/api/users/newAccount")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(jsonUser("klient@test.com", "haslo123", "KLIENT", 5L)))
                .andExpect(status().isBadRequest());
    }

    // --- POST /api/users/login ---

    @Test
    @DisplayName("Logowanie z poprawnymi danymi zwraca 201 z danymi użytkownika")
    void login_poprawneDane_zwraca201ZUzytkownikiem() throws Exception {
        Users dbUser = user(1L, "user@test.com", "KLIENT", null);
        dbUser.setPassword("haslo123");
        given(userRepository.findByEmail("user@test.com")).willReturn(dbUser);

        mockMvc.perform(post("/api/users/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"user@test.com\",\"password\":\"haslo123\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.email").value("user@test.com"))
                .andExpect(jsonPath("$.role").value("KLIENT"))
                .andExpect(jsonPath("$.password").doesNotExist());
    }

    @Test
    @DisplayName("Logowanie ze złym hasłem zwraca 403")
    void login_zleHaslo_zwraca403() throws Exception {
        Users dbUser = user(1L, "user@test.com", "KLIENT", null);
        dbUser.setPassword("poprawnehslo");
        given(userRepository.findByEmail("user@test.com")).willReturn(dbUser);

        mockMvc.perform(post("/api/users/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"user@test.com\",\"password\":\"zlehaslo\"}"))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("Logowanie z nieznanym emailem zwraca 400")
    void login_nieznanyEmail_zwraca400() throws Exception {
        given(userRepository.findByEmail("nieznany@test.com")).willReturn(null);

        mockMvc.perform(post("/api/users/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"nieznany@test.com\",\"password\":\"haslo123\"}"))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("Logowanie bez pola email zwraca 400")
    void login_brakPolaEmail_zwraca400() throws Exception {
        mockMvc.perform(post("/api/users/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"password\":\"haslo123\"}"))
                .andExpect(status().isBadRequest());
    }

    // --- GET /trainers/{id}/clients ---

    @Test
    @DisplayName("Trener z przypisanymi klientami zwraca listę i 200")
    void pobierzKlientow_trenerZKlientami_zwracaListeI200() throws Exception {
        Users trainer = user(1L, "trener@test.com", "TRENER", null);
        Users k1 = user(2L, "k1@test.com", "KLIENT", trainer);
        Users k2 = user(3L, "k2@test.com", "KLIENT", trainer);
        given(userRepository.findByTrainerId(1L)).willReturn(List.of(k1, k2));

        mockMvc.perform(get("/trainers/1/clients"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(2))
                .andExpect(jsonPath("$[0].email").value("k1@test.com"))
                .andExpect(jsonPath("$[1].email").value("k2@test.com"));
    }

    @Test
    @DisplayName("Trener bez klientów zwraca pustą listę i 200")
    void pobierzKlientow_trenerBezKlientow_zwracaPustaListeI200() throws Exception {
        given(userRepository.findByTrainerId(1L)).willReturn(List.of());

        mockMvc.perform(get("/trainers/1/clients"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(0));
    }

    // --- Metody pomocnicze ---

    private Users user(Long id, String email, String role, Users trainer) {
        Users u = new Users();
        u.setId(id);
        u.setEmail(email);
        u.setRole(role);
        u.setTrainer(trainer);
        return u;
    }

    private String jsonUser(String email, String password, String role, Long trainerId) {
        String trainerJson = trainerId != null
                ? String.format(",\"trainer\":{\"id\":%d}", trainerId)
                : "";
        return String.format(
                "{\"email\":\"%s\",\"password\":\"%s\",\"role\":\"%s\"%s}",
                email, password, role, trainerJson);
    }
}

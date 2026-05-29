package com.example.demo.entities;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;


@Entity
@Table(name = "exercise_history")
@Data
@NoArgsConstructor
public class ExercisesHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private Users user; // Kto ćwiczył

    @ManyToOne
    @JoinColumn(name = "exercise_id", nullable = false)
    private Exercises exercise; // Co ćwiczył

    private int repetitions; // Liczba powtórzeń
    private int accuracy;    // Poprawność 0-100%

    private LocalDateTime createdAt = LocalDateTime.now(); //kiedy ćwiczył
}

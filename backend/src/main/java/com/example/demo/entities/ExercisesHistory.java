package com.example.demo.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "exercises_history")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ExercisesHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private Users user;

    @ManyToOne
    @JoinColumn(name = "exercise_id")
    private Exercises exercise;

    @Column(name = "repetitions")
    private int repetitions;

    @Column(name = "accuracy")
    private int accuracy;

    @Column(name = "created_at")
    private LocalDateTime createdAt;
}

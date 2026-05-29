package com.example.demo.repositories;

import com.example.demo.entities.ExercisesHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExercisesHistoryRepository extends JpaRepository<ExercisesHistory, Long> {
    List<ExercisesHistory> findByUserId(Long id);
}

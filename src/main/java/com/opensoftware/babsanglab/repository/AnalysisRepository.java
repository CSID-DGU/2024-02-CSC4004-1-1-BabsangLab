package com.opensoftware.babsanglab.repository;

import com.opensoftware.babsanglab.domain.Food;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface AnalysisRepository extends JpaRepository<Food,Long> {
    Optional<Food> findByfoodName(String foodName);
}

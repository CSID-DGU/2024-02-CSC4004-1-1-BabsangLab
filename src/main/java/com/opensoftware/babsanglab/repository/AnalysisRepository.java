package com.opensoftware.babsanglab.repository;

import com.opensoftware.babsanglab.domain.Food;
import com.opensoftware.babsanglab.domain.enums.Allergy;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AnalysisRepository extends JpaRepository<Food,Long> {
    Optional<Food> findByfoodName(String foodName);
    @Query("SELECT f FROM Food f " +
            "WHERE f.calories < :calories " +
            "AND f.fat < :fat " +
            "AND f.protein < :protein " +
            "AND f.carbs < :carbs " +
            "AND (:allergy IS NULL OR f.allergy != :allergy OR f.allergy IS NULL) " +  // allergy가 null이면 비교하지 않음
            "AND (:med_history IS NULL OR f.medical_issue != :med_history OR f.medical_issue IS NULL)")
    List<Food> findByRecommend(
            @Param("calories") Double calories,
            @Param("fat") Double fat,
            @Param("protein") Double protein,
            @Param("carbs") Double carbs,
            @Param("allergy") Allergy allergy,
            @Param("med_history") String med_history);
}

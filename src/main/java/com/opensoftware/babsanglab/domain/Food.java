package com.opensoftware.babsanglab.domain;

import com.opensoftware.babsanglab.domain.enums.Allergy;
import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor
public class Food {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column
    private String foodName;

    @Column
    private Double calories;

    @Column
    private Double protein;

    @Column
    private Double fat;

    @Column
    private Double carbs;

    @Column
    @Enumerated(EnumType.STRING)
    private Allergy allergy;
    @Column
    private String medical_issue;

    @Builder
    public Food(String foodName, Double calories, Double protein, Double fat, Double carbs, Allergy allergy, String medical_issue){
        this.foodName = foodName;
        this.calories = calories;
        this.protein = protein;
        this.fat = fat;
        this.carbs = carbs;
        this.allergy = allergy;
        this.medical_issue = medical_issue;
    }
}

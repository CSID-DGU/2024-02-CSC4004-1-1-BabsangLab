package com.example.Open.Software.Back.domain;

import jakarta.persistence.*;
import lombok.Builder;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import com.example.Open.Software.Back.enums.Meal_time;

@Entity
@Table(name="MealRecord")
@NoArgsConstructor
public class Record {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @Column
    private LocalDate date;

    @Column
    @Enumerated(EnumType.STRING)
    private Meal_time meal_time;

    @Column(nullable = false)
    private String food_type;

    @Column
    private Double calories;

    @Column
    private Double protein;

    @Column
    private Double fat;

    @Column
    private Double carbs;

    @Column
    @Enumerated(EnumType.ORDINAL)
    private Integer allergy_info;

    @Builder
    public Record(User user,LocalDate date, Meal_time meal_time, String food_type, Double calories, Double protein, Double fat, Double carbs, Integer allergy_info) {
        this.user = user;
        this.date = date;
        this.meal_time = meal_time;
        this.food_type = food_type;
        this.calories = calories;
        this.protein = protein;
        this.fat = fat;
        this.carbs = carbs;
        this.allergy_info = allergy_info;
    }
}

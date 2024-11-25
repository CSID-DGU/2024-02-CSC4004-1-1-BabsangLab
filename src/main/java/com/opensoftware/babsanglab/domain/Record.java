package com.opensoftware.babsanglab.domain;


import com.opensoftware.babsanglab.domain.enums.Allergy;
import com.opensoftware.babsanglab.domain.enums.Mealtime;
import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Entity
@Getter
@NoArgsConstructor
public class Record {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="user_id")
    private User user;

    @Column
    private LocalDate date;

    @Column
    @Enumerated(EnumType.STRING)
    private Mealtime mealtime;

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
    private Double intake_amount;

    @Column
    @Enumerated(EnumType.STRING)
    private Allergy allergy;

    @Builder
    public Record(User user, LocalDate date, Mealtime mealtime, String foodName, Double calories, Double protein
    ,Double fat, Double carbs, Allergy allergy){
        this.user = user;
        this.date = date;
        this.mealtime = mealtime;
        this.foodName = foodName;
        this.calories = calories;
        this.protein = protein;
        this.fat = fat;
        this.carbs = carbs;
        this.allergy = allergy;
    }
}

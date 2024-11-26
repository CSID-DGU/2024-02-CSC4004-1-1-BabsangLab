package com.opensoftware.babsanglab.domain;


import com.opensoftware.babsanglab.domain.enums.Mealtime;
import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.HashSet;
import java.util.Set;

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

    @ElementCollection
    @CollectionTable(name = "user_allergies", joinColumns = @JoinColumn(name = "user_id"))
    @Column(name = "allergy")
    private Set<String> allergy = new HashSet<>();

    @Builder
    public Record(User user, LocalDate date, Mealtime mealtime, String foodName, Double calories, Double protein
    ,Double fat, Double carbs, Set<String> allergy){
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

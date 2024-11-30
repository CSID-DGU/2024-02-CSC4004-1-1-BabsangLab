package com.opensoftware.babsanglab.domain;


import com.opensoftware.babsanglab.domain.enums.Allergy;
import com.opensoftware.babsanglab.domain.enums.Mealtime;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.HashSet;
import java.util.Set;

@Entity
@Getter
@NoArgsConstructor
@AllArgsConstructor
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
    private Double intake_amount;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="food_id")
    private Food food;

    @Builder
    public Record(User user, LocalDate date, Mealtime mealtime, String foodName, Double intake_amount, Food food){
        this.user = user;
        this.date = date;
        this.mealtime = mealtime;
        this.foodName = foodName;
        this.intake_amount = intake_amount;
        this.food = food;
    }
}

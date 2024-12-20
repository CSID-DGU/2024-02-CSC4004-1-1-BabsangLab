package com.opensoftware.babsanglab.domain;

import com.opensoftware.babsanglab.domain.enums.Gender;
import com.opensoftware.babsanglab.domain.enums.Weight_goal;
import jakarta.persistence.*;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.HashSet;
import java.util.Set;

@Entity
@Table
@NoArgsConstructor
@Setter

public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String userId;

    @Column(nullable = false,updatable = false)
    private String name;

    @Column(nullable = false)
    private String password;

    @Column
    private Integer age;

    @Column
    @Enumerated(EnumType.STRING)
    private Gender gender;

    @Column
    private Double height;

    @Column
    private Double weight;

    @Column
    private String med_history;

    @ElementCollection
    @CollectionTable(name = "user_allergies", joinColumns = @JoinColumn(name = "user_id"))
    @Column(name = "allergy")
    private Set<String> allergy = new HashSet<>();


    @Column
    @Enumerated(EnumType.STRING)
    private Weight_goal weight_goal;

    @Builder
    public User(String userId, String name, String password, Integer age,
                Gender gender, Double height, Double weight, String med_history, Set<String> allergy, Weight_goal weight_goal) {
        this.userId = userId;
        this.name = name;
        this.password = password;
        this.age = age;
        this.gender = gender;
        this.height = height;
        this.weight = weight;
        this.med_history = med_history;
        this.allergy = allergy;
        this.weight_goal = weight_goal;
    }

}

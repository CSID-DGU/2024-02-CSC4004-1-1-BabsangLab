package com.example.Open.Software.Back.domain;

import jakarta.persistence.*;
import lombok.Builder;
import lombok.NoArgsConstructor;
import com.example.Open.Software.Back.enums.Gender;
import com.example.Open.Software.Back.enums.Weight_goal;

@Table(name = "UserInfo")
@Entity
@NoArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String user_id;

    @Column(nullable = false,length = 30,updatable = false)
    private String name;

    @Column(nullable = false,length = 30)
    private String password;

    @Column(nullable = false)
    private Integer age;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private Gender gender;

    @Column(nullable = false)
    private Double height;

    @Column(nullable = false)
    private Double weight;

    @Column(nullable = false)
    private String med_history;

    @Column
    @Enumerated(EnumType.ORDINAL)
    private Integer allergy_info;

    @Column
    @Enumerated(EnumType.STRING)
    private Weight_goal weight_goal;

    @Builder
    public User(String user_id, String name, String password, Integer age, Gender gender, Double height, Double weight, String med_history, Integer allergy_info, Weight_goal weight_goal) {
        this.user_id = user_id;
        this.name = name;
        this.password = password;
        this.age = age;
        this.gender = gender;
        this.height = height;
        this.weight = weight;
        this.med_history = med_history;
        this.allergy_info = allergy_info;
        this.weight_goal = weight_goal;
    }
}

package com.example.Open.Software.Back.dto;

import com.example.Open.Software.Back.domain.enums.Allergy;
import com.example.Open.Software.Back.domain.enums.Gender;
import com.example.Open.Software.Back.domain.enums.Weight_goal;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@AllArgsConstructor
@NoArgsConstructor
public class RegisterRequestDto {
    private String user_id;
    private String name;
    private String password;
    private Integer age;
    private Gender gender;
    private Double height;
    private Double weight;
    private String med_history;
    private Allergy allergy;
    private Weight_goal weight_goal;
}

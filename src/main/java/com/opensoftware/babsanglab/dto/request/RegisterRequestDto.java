package com.opensoftware.babsanglab.dto.request;


import com.opensoftware.babsanglab.domain.enums.Allergy;
import com.opensoftware.babsanglab.domain.enums.Gender;
import com.opensoftware.babsanglab.domain.enums.Weight_goal;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.Set;

@Getter
@AllArgsConstructor
@NoArgsConstructor
public class RegisterRequestDto {
    private String userId;
    private String password;
    private String name;
    private Integer age;
    private Gender gender;
    private Double height;
    private Double weight;
    private String med_history;
    private Allergy allergy;
    //private Set<String> allergy;
    private Weight_goal weight_goal;
}

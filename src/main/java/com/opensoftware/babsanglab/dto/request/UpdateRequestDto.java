package com.opensoftware.babsanglab.dto.request;

import com.opensoftware.babsanglab.domain.enums.Gender;
import com.opensoftware.babsanglab.domain.enums.Weight_goal;
import lombok.Getter;

import java.util.Set;

@Getter

public class UpdateRequestDto {
    private String userId; // 수정하려는 사용자 식별자
    private String password;
    private Integer age;
    private Gender gender;
    private Double height;
    private Double weight;
    private String med_history;
    private Set<String> allergy;
    private Weight_goal weight_goal;
}

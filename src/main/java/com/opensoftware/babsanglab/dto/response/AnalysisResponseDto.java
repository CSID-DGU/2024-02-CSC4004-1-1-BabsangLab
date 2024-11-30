package com.opensoftware.babsanglab.dto.response;

import com.opensoftware.babsanglab.domain.enums.Allergy;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
@AllArgsConstructor
public class AnalysisResponseDto {
    String foodName;
    Double calories;
    Double fat;
    Double protein;
    Double carbs;
    Allergy allergy;
    String medical_issue;
}

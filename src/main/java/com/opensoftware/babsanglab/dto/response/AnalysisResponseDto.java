package com.opensoftware.babsanglab.dto.response;

import com.opensoftware.babsanglab.domain.enums.Allergy;
import lombok.AllArgsConstructor;
import lombok.Builder;

@Builder
@AllArgsConstructor
public class AnalysisResponseDto {
    Double calories;
    Double fat;
    Double protein;
    Double carbs;
    Allergy allergy;
}

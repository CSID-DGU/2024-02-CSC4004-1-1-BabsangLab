package com.opensoftware.babsanglab.dto.response;

import com.opensoftware.babsanglab.domain.enums.Mealtime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
@AllArgsConstructor
public class RecordResponseDto {
    Mealtime mealtime;
    Double calories;
    Double fat;
    Double protein;
    Double carbs;
}

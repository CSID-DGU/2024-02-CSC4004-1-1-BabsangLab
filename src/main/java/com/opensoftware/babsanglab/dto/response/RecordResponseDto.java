package com.opensoftware.babsanglab.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;

@Builder
@AllArgsConstructor
public class RecordResponseDto {
    Double calories;
    Double fat;
    Double protein;
    Double carbs;
}

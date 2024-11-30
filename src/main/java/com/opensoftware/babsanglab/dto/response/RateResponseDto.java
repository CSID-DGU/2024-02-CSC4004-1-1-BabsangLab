package com.opensoftware.babsanglab.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@AllArgsConstructor
@Builder
@Getter
public class RateResponseDto {
    Double rateCalories;
    Double rateProtein;
    Double rateFat;
    Double rateCarbs;
}

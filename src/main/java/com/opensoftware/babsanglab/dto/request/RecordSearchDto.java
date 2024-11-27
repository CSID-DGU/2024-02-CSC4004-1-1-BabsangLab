package com.opensoftware.babsanglab.dto.request;

import com.opensoftware.babsanglab.domain.enums.Mealtime;
import lombok.Getter;

import java.time.LocalDate;

@Getter
public class RecordSearchDto {
    private String name;
    private LocalDate date;
    private Mealtime mealtime;
    private Double intake_amount;
}

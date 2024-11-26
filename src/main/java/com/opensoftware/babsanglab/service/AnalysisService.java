package com.opensoftware.babsanglab.service;

import com.opensoftware.babsanglab.domain.Food;
import com.opensoftware.babsanglab.dto.response.AnalysisResponseDto;
import com.opensoftware.babsanglab.repository.AnalysisRepository;

import java.util.List;

public class AnalysisService {
    private AnalysisRepository analysisRepository;
    public AnalysisResponseDto analysis(String foodName){
        Food food = analysisRepository.findByfoodName(foodName);
                //foodName으로 찾아서 food 객체 생성

        return new AnalysisResponseDto(
                food.getCalories(),
                food.getProtein(),
                food.getFat(),
                food.getCarbs(),
                food.getAllergy()
        );
    }
}

package com.opensoftware.babsanglab.service;

import com.opensoftware.babsanglab.domain.Food;
import com.opensoftware.babsanglab.domain.Record;
import com.opensoftware.babsanglab.domain.User;
import com.opensoftware.babsanglab.domain.enums.Weight_goal;
import com.opensoftware.babsanglab.dto.response.*;
import com.opensoftware.babsanglab.exception.ApiException;
import com.opensoftware.babsanglab.exception.ErrorDefine;
import com.opensoftware.babsanglab.repository.AnalysisRepository;
import com.opensoftware.babsanglab.repository.RecordRepository;
import com.opensoftware.babsanglab.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RequiredArgsConstructor
@Service
public class RecordService {
    private final RecordRepository recordRepository;
    private final UserRepository userRepository;
    private final AnalysisService analysisService;
    private final AnalysisRepository analysisRepository;

    public List<RecordResponseDto> recordDay(String userName, LocalDate date) {
        User user = userRepository.findByName(userName)
                .orElseThrow(() -> new ApiException(ErrorDefine.USER_NOT_FOUND));

        List<Record> records = recordRepository.findByUserAndDate(user, date);

        return records.stream()
                .map(record -> {
                    Food food = record.getFood(); // Record에서 매핑된 Food 가져오기
                    Double intakeAmount = record.getIntake_amount(); //record에서 intake_amount가져오기
                    return new RecordResponseDto(
                            food.getFoodName(),
                            record.getMealtime(),
                            food.getCalories()*intakeAmount,
                            food.getFat()*intakeAmount,
                            food.getProtein()*intakeAmount,
                            food.getCarbs()*intakeAmount,
                            intakeAmount
                    );
                })
                .toList();
    }

    public Object rateDay(String userName, LocalDate date) {
        User user = userRepository.findByName(userName)
                .orElseThrow(() -> new ApiException(ErrorDefine.USER_NOT_FOUND));
        if (user.getWeight() == null) {
            return NotifyResponseDto.builder()
                    .message("몸무게 정보가 없습니다. 정보를 업데이트 하세요.")
                    .build();
        }
        Map<String,Double> recommendValues = getRecommend(user.getWeight_goal(), user.getWeight());

        List<Record> records = recordRepository.findByUserAndDate(user, date);
        double totalCalories = 0.0;
        double totalProtein = 0.0;
        double totalFat = 0.0;
        double totalCarbs = 0.0;

        // 각 Record에 대하여 영양소 총합 계산
        for (Record record : records) {
            Food food = record.getFood();
            double intakeAmount = record.getIntake_amount();

            // 각 영양소 값을 섭취량에 따라 누적
            totalCalories += food.getCalories() * intakeAmount;
            totalProtein += food.getProtein() * intakeAmount;
            totalFat += food.getFat() * intakeAmount;
            totalCarbs += food.getCarbs() * intakeAmount;
        }


        return RateResponseDto.builder()
                .rateCalories(totalCalories/ recommendValues.get("calories"))
                .rateProtein(totalProtein/ recommendValues.get("protein"))
                .rateFat(totalFat/ recommendValues.get("fat"))
                .rateCarbs(totalCarbs/ recommendValues.get("carbs"))
                .build();
    }

    Map<String, Double> getRecommend(Weight_goal weight_goal, Double weight) {
        double recommendCalories;
        if (weight_goal == Weight_goal.gain) {
            recommendCalories = weight * 30 * 1.1;
        } else if (weight_goal == Weight_goal.lose) {
            recommendCalories = weight * 30 * 0.9;
        } else {
            recommendCalories = weight * 30;
        }

        double recommendProtein = recommendCalories * 0.15 / 4;
        double recommendFat = recommendCalories * 0.25 / 9;
        double recommendCarbs = recommendCalories * 0.60 / 4;

        // 결과를 Map에 담아 반환
        Map<String, Double> recommendValues = new HashMap<>();
        recommendValues.put("calories", recommendCalories);
        recommendValues.put("protein", recommendProtein);
        recommendValues.put("fat", recommendFat);
        recommendValues.put("carbs", recommendCarbs);

        return recommendValues;
    }
    public List<AnalysisResponseDto> recommendFood(String userName, LocalDate date) {
        User user = userRepository.findByName(userName)
                .orElseThrow(() -> new ApiException(ErrorDefine.USER_NOT_FOUND));
        Map<String,Double> recommendValues = getRecommend(user.getWeight_goal(), user.getWeight());
        List<Food> foods = analysisRepository.findByRecommend(
                recommendValues.get("calories"),recommendValues.get("protein"),recommendValues.get("fat"),recommendValues.get("carbs")
                ,user.getAllergy(),user.getMed_history()
        );
        return foods.stream()
                .map(food -> {
                    return new AnalysisResponseDto(
                            food.getFoodName(),
                            food.getCalories(),
                            food.getFat(),
                            food.getProtein(),
                            food.getCarbs(),
                            food.getAllergy(),
                            food.getMedical_issue()
                    );
                })
                .toList();
    }

}

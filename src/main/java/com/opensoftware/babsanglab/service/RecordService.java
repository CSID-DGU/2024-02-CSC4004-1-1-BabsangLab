package com.opensoftware.babsanglab.service;

import com.opensoftware.babsanglab.domain.Food;
import com.opensoftware.babsanglab.domain.Record;
import com.opensoftware.babsanglab.domain.User;
import com.opensoftware.babsanglab.domain.enums.Weight_goal;
import com.opensoftware.babsanglab.dto.response.NotifyResponseDto;
import com.opensoftware.babsanglab.dto.response.RateResponseDto;
import com.opensoftware.babsanglab.dto.response.RecordResponseDto;
import com.opensoftware.babsanglab.exception.ApiException;
import com.opensoftware.babsanglab.exception.ErrorDefine;
import com.opensoftware.babsanglab.repository.RecordRepository;
import com.opensoftware.babsanglab.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@RequiredArgsConstructor
@Service
public class RecordService {
    private final RecordRepository recordRepository;
    private final UserRepository userRepository;

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
        double recommendCalories = getRecommend(user.getWeight_goal(),user.getWeight());
        double recommendProtein = recommendCalories * 0.15 / 4;
        double recommendFat = recommendCalories * 0.25 / 9;
        double recommendCarbs = recommendCalories * 0.60 / 4;

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
                .rateCalories(totalCalories/recommendCalories)
                .rateProtein(totalProtein/recommendProtein)
                .rateFat(totalFat/recommendFat)
                .rateCarbs(totalCarbs/recommendCarbs)
                .build();
    }

    double getRecommend(Weight_goal weight_goal, Double weight) {
        if (weight_goal == Weight_goal.gain) {
            return weight * 30 * 1.1;
        } else {
            return weight * 30; // 기본 값
        }
    }
}

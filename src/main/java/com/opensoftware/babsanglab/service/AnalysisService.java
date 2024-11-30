package com.opensoftware.babsanglab.service;

import com.opensoftware.babsanglab.domain.Food;
import com.opensoftware.babsanglab.domain.Record;
import com.opensoftware.babsanglab.domain.User;
import com.opensoftware.babsanglab.dto.request.AnalysisRequestDto;
import com.opensoftware.babsanglab.dto.response.AnalysisResponseDto;
import com.opensoftware.babsanglab.exception.ApiException;
import com.opensoftware.babsanglab.exception.ErrorDefine;
import com.opensoftware.babsanglab.repository.AnalysisRepository;
import com.opensoftware.babsanglab.repository.RecordRepository;
import com.opensoftware.babsanglab.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class AnalysisService {

    private final AnalysisRepository analysisRepository;
    private final UserRepository userRepository;
    private final RecordRepository recordRepository;

    /**
     * 음식 이름으로 영양 정보를 분석합니다.
     */
    public AnalysisResponseDto analysis(String foodName) {
        // Food 객체를 foodName으로 조회
        Food food = analysisRepository.findByfoodName(foodName)
                .orElseThrow(() -> new ApiException(ErrorDefine.FOOD_NOT_FOUND));

        // Response DTO 생성 및 반환
        return new AnalysisResponseDto(
                food.getCalories(),
                food.getProtein(),
                food.getFat(),
                food.getCarbs(),
                food.getAllergy()
        );
    }

    /**
     * 사용자 섭취 기록을 저장하고 결과를 반환합니다.
     */
    public AnalysisResponseDto analysisRecord(AnalysisRequestDto analysisRequestDto) {
        // User 객체를 name으로 조회
        User user = userRepository.findByName(analysisRequestDto.getName())
                .orElseThrow(() -> new ApiException(ErrorDefine.USER_NOT_FOUND));
        // Record 객체 생성
        Record record = Record.builder()
                .user(user)
                .date(analysisRequestDto.getDate())
                .mealtime(analysisRequestDto.getMealtime())
                .foodName(analysisRequestDto.getFoodName())
                .intake_amount(analysisRequestDto.getIntake_amount()) // 수정된 필드명
                .build();

        // Record 저장
        recordRepository.save(record);

        // Food 객체 조회
        Food food = analysisRepository.findByfoodName(analysisRequestDto.getFoodName())
                .orElseThrow(() -> new ApiException(ErrorDefine.FOOD_NOT_FOUND));


        // Response DTO 생성 및 반환
        return new AnalysisResponseDto(
                food.getCalories(),
                food.getProtein(),
                food.getFat(),
                food.getCarbs(),
                food.getAllergy()
        );
    }
}

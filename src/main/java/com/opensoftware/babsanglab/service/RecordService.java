package com.opensoftware.babsanglab.service;

import com.opensoftware.babsanglab.domain.Food;
import com.opensoftware.babsanglab.domain.Record;
import com.opensoftware.babsanglab.domain.User;
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
}

package com.opensoftware.babsanglab.service;

import com.opensoftware.babsanglab.domain.Food;
import com.opensoftware.babsanglab.domain.Record;
import com.opensoftware.babsanglab.domain.User;
import com.opensoftware.babsanglab.dto.request.RecordSearchDto;
import com.opensoftware.babsanglab.dto.response.RecordResponseDto;
import com.opensoftware.babsanglab.dto.response.ResponseDto;
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

        public List<RecordResponseDto> recordSearch(RecordSearchDto recordSearchDto){
        User user = userRepository.findByName(recordSearchDto.getName())
                .orElseThrow(() -> new ApiException(ErrorDefine.USER_NOT_FOUND));

        List<Record> records = recordRepository.findByUser(user);

//        List<RecordResponseDto> recordResponseDtos = records.stream()
//                .map(record -> RecordResponseDto.builder()
//                        .fat(record.getFat())
//                        .calories(record.getCalories())
//                        .protein(record.getProtein())
//                        .carbs(record.getCarbs())
//                        .build()
//                ).toList();


        return records.stream()
                .map(record -> RecordResponseDto.builder()
                        .build()
                ).toList();
    }

    public List<RecordResponseDto> recordDay(String userName, LocalDate date) {
        User user = userRepository.findByName(userName)
                .orElseThrow(() -> new ApiException(ErrorDefine.USER_NOT_FOUND));

        List<Record> records = recordRepository.findByUserAndDate(user, date);

        return records.stream()
                .map(record -> {
                    Food food = record.getFood(); // Record에서 매핑된 Food 가져오기
                    return new RecordResponseDto(
                            record.getMealtime(),
                            food.getCalories(),
                            food.getFat(),
                            food.getProtein(),
                            food.getCarbs()
                    );
                })
                .toList();
    }
}

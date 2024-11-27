package com.opensoftware.babsanglab.service;

import com.opensoftware.babsanglab.domain.Record;
import com.opensoftware.babsanglab.domain.User;
import com.opensoftware.babsanglab.dto.request.RecordSearchDto;
import com.opensoftware.babsanglab.dto.response.RecordResponseDto;
import com.opensoftware.babsanglab.repository.RecordRepository;
import com.opensoftware.babsanglab.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@RequiredArgsConstructor
@Service
public class RecordService {
    private final RecordRepository recordRepository;
    private final UserRepository userRepository;

    public List<RecordResponseDto> recordSearch(RecordSearchDto recordSearchDto){
        User user = userRepository.findByName(recordSearchDto.getName());
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
                        .fat(record.getFat())
                        .calories(record.getCalories())
                        .protein(record.getProtein())
                        .carbs(record.getCarbs())
                        .build()
                ).toList();
    }

}

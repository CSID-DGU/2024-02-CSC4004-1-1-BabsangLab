package com.opensoftware.babsanglab.service;

import com.opensoftware.babsanglab.domain.Record;
import com.opensoftware.babsanglab.domain.User;
import com.opensoftware.babsanglab.dto.RecordDayDto;
import com.opensoftware.babsanglab.dto.RecordSearchDto;
import com.opensoftware.babsanglab.repository.RecordRepository;
import com.opensoftware.babsanglab.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@RequiredArgsConstructor
@Service
public class RecordService {
    private final RecordRepository recordRepository;
    private final UserRepository userRepository;

    public boolean recordSearch(RecordSearchDto recordSearchDto){
        User user = userRepository.findByName(recordSearchDto.getName());
        List<Record> records = recordRepository.findByUser(user);
        return true;
    }

}

package com.opensoftware.babsanglab.service;

import com.opensoftware.babsanglab.domain.User;
import com.opensoftware.babsanglab.dto.RegisterRequestDto;
import com.opensoftware.babsanglab.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class UserService {
    private final UserRepository userRepository;

    public Boolean register(RegisterRequestDto registerRequestDto){
        if (userRepository.findByUserId(registerRequestDto.getUserId()).isPresent())
            return false;
        User user = User.builder()
                .userId(registerRequestDto.getUserId())
                .password(registerRequestDto.getPassword())
                .name(registerRequestDto.getName())
                .age(registerRequestDto.getAge())
                .gender(registerRequestDto.getGender())
                .height(registerRequestDto.getHeight())
                .weight(registerRequestDto.getWeight())
                .med_history(registerRequestDto.getMed_history())
                .allergy(registerRequestDto.getAllergy())
                .weight_goal(registerRequestDto.getWeight_goal())
                .build();
            userRepository.save(user);
            return true;
    }
}

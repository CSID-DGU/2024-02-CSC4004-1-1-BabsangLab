package com.example.Open.Software.Back.service;

import com.example.Open.Software.Back.domain.User;
import com.example.Open.Software.Back.domain.enums.Gender;
import com.example.Open.Software.Back.dto.RegisterRequestDto;
import com.example.Open.Software.Back.exception.ApiException;
import com.example.Open.Software.Back.exception.ErrorDefine;
import com.example.Open.Software.Back.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

@Service
@Transactional
@RequiredArgsConstructor
@Slf4j
public class UserService {

    private final UserRepository userRepository;

    public Boolean register(RegisterRequestDto registerRequestDto) {
        if (userRepository.findByUserId(registerRequestDto.getUser_id()).isPresent())
            throw new ApiException(ErrorDefine.USERID_EXIST);
        User user = User.builder()
                .user_id(registerRequestDto.getUser_id())
                .password(registerRequestDto.getPassword())
                .name(registerRequestDto.getName())
                .age(registerRequestDto.getAge())
                .gender(registerRequestDto.getGender())
                .height(registerRequestDto.getHeight())
                .weight(registerRequestDto.getWeight())
                .med_history(registerRequestDto.getMed_history())
                .allergy(registerRequestDto.getAllergy())
                .build();
        userRepository.save(user);
        return true;
    }
}
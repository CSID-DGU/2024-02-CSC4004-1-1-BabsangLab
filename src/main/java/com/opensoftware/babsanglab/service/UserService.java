package com.opensoftware.babsanglab.service;

import com.opensoftware.babsanglab.domain.User;
import com.opensoftware.babsanglab.dto.request.RegisterRequestDto;
import com.opensoftware.babsanglab.dto.response.RegisterResponseDto;
import com.opensoftware.babsanglab.exception.ApiException;
import com.opensoftware.babsanglab.exception.ErrorDefine;
import com.opensoftware.babsanglab.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class UserService {
    private final UserRepository userRepository;

    public RegisterResponseDto register(RegisterRequestDto registerRequestDto){
//        User user = userRepository.findById(10l)
//                .orElseThrow(() -> new ApiException(ErrorDefine.USER_NOT_FOUND));

        if (userRepository.findByUserId(registerRequestDto.getUserId()).isPresent())
            throw new ApiException(ErrorDefine.USER_EXIST);
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

//             RegisterResponseDto registerResponseDto = RegisterResponseDto.builder()
//                    .message("회원가입이 잘 되었습니다")
//                    .build();

        return RegisterResponseDto.builder()
                    .message("회원가입이 잘 되었습니다")
                    .build();
    }
}

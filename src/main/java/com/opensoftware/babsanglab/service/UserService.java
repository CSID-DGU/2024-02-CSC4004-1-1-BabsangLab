package com.opensoftware.babsanglab.service;

import com.opensoftware.babsanglab.domain.Food;
import com.opensoftware.babsanglab.domain.User;
import com.opensoftware.babsanglab.dto.request.RegisterRequestDto;
import com.opensoftware.babsanglab.dto.request.UpdateRequestDto;
import com.opensoftware.babsanglab.dto.response.AnalysisResponseDto;
import com.opensoftware.babsanglab.dto.response.NotifyResponseDto;
import com.opensoftware.babsanglab.dto.response.RegisterResponseDto;
import com.opensoftware.babsanglab.dto.response.ResponseDto;
import com.opensoftware.babsanglab.exception.ApiException;
import com.opensoftware.babsanglab.exception.ErrorDefine;
import com.opensoftware.babsanglab.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.Set;

@RequiredArgsConstructor
@Service
@Transactional
public class UserService {
    private final UserRepository userRepository;
//    public void updateUserAllergies(Long userId, Set<String> allergies) {
//        User user = userRepository.findById(userId)
//                .orElseThrow(() -> new ApiException(ErrorDefine.USER_NOT_FOUND));
//        user.setAllergy(allergies);
//        userRepository.save(user);
//    }
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
                //.allergy(new HashSet<>(registerRequestDto.getAllergy())) // 다중 값 전달
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

    public RegisterResponseDto checkId(String userId){
        if (userRepository.findByUserId(userId).isPresent())
            return RegisterResponseDto.builder()
                    .message("이미 존재하는 아이디입니다")
                    .build();

        return RegisterResponseDto.builder()
                .message("사용 가능한 아이디입니다")
                .build();
    }

    public NotifyResponseDto getPw(String name){
            User user = userRepository.findByName(name)
                    .orElseThrow(() -> new ApiException(ErrorDefine.USER_NOT_FOUND));

        return new NotifyResponseDto(
                user.getPassword()
        );
    }
    public Boolean updateUser(UpdateRequestDto updateRequestDto) {
        User user = userRepository.findByUserId(updateRequestDto.getUserId())
                .orElseThrow(() -> new ApiException(ErrorDefine.USER_NOT_FOUND));

        // 업데이트 가능한 필드 수정)
        if (updateRequestDto.getPassword() != null) user.setPassword(updateRequestDto.getPassword());
        if (updateRequestDto.getAge() != null) user.setAge(updateRequestDto.getAge());
        if (updateRequestDto.getGender() != null) user.setGender(updateRequestDto.getGender());
        if (updateRequestDto.getHeight() != null) user.setHeight(updateRequestDto.getHeight());
        if (updateRequestDto.getWeight() != null) user.setWeight(updateRequestDto.getWeight());
        if (updateRequestDto.getMed_history() != null) user.setMed_history(updateRequestDto.getMed_history());
        if (updateRequestDto.getAllergy() != null) user.setAllergy(updateRequestDto.getAllergy());
//        if (updateRequestDto.getAllergy() != null) {user.setAllergy(new HashSet<>(updateRequestDto.getAllergy()));}
        if (updateRequestDto.getWeight_goal() != null) user.setWeight_goal(updateRequestDto.getWeight_goal());

        userRepository.save(user); // 데이터베이스에 변경사항 저장
        return true;
    }

}

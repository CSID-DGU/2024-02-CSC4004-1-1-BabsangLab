package com.opensoftware.babsanglab.service;

import com.opensoftware.babsanglab.domain.User;
import com.opensoftware.babsanglab.dto.request.RegisterRequestDto;
import com.opensoftware.babsanglab.dto.request.UpdateRequestDto;
import com.opensoftware.babsanglab.dto.response.NotifyResponseDto;
import com.opensoftware.babsanglab.exception.ApiException;
import com.opensoftware.babsanglab.exception.ErrorDefine;
import com.opensoftware.babsanglab.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
@Transactional
@Slf4j
@Getter
public class UserService {
    private final UserRepository userRepository;
    public NotifyResponseDto register(RegisterRequestDto registerRequestDto){
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
        return NotifyResponseDto.builder()
                    .message("회원가입이 잘 되었습니다")
                    .build();
    }

    public NotifyResponseDto checkId(String userId){
        if (userRepository.findByUserId(userId).isPresent())
            return NotifyResponseDto.builder()
                    .message("이미 존재하는 아이디입니다")
                    .build();

        return NotifyResponseDto.builder()
                .message("사용 가능한 아이디입니다")
                .build();
    }

    public NotifyResponseDto getPw(String name){
        log.info("Searching for user with name: {}", name);
            User user = userRepository.findByName(name)
                    .orElseThrow(() -> new ApiException(ErrorDefine.USER_NOT_FOUND));

        return NotifyResponseDto.builder()
                .message(user.getPassword())
                .build();
    }

    public NotifyResponseDto login(String userId, String password){
        User user = userRepository.findByUserIdAndPassword(userId,password)
                .orElseThrow(() -> new ApiException(ErrorDefine.USER_NOT_FOUND));

        return NotifyResponseDto.builder()
                .message(user.getName()+"님 로그인에 성공하였습니다")
                .build();
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

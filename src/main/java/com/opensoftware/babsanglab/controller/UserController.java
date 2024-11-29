package com.opensoftware.babsanglab.controller;

import com.opensoftware.babsanglab.dto.request.RegisterRequestDto;
import com.opensoftware.babsanglab.dto.request.UpdateRequestDto;
import com.opensoftware.babsanglab.dto.response.RegisterResponseDto;
import com.opensoftware.babsanglab.dto.response.ResponseDto;
import com.opensoftware.babsanglab.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.HashSet;
import java.util.List;

@RestController
@RequestMapping("/user")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;
    @PostMapping("/register")
    public ResponseDto<RegisterResponseDto> register(
            @RequestBody  RegisterRequestDto registerRequestDto
            ) {
        return new ResponseDto<>(userService.register(registerRequestDto));
    }

    @PutMapping("/update")
    public ResponseDto<Boolean> updateUser(
            @RequestBody UpdateRequestDto updateRequestDto
    ) {
        return new ResponseDto<>(userService.updateUser(updateRequestDto));
    }

//    @PutMapping("/{userId}/allergies")
//    public ResponseDto<Boolean> updateAllergies(
//            @PathVariable Long userId,
//            @RequestBody List<String> allergies) {
//        userService.updateUserAllergies(userId, new HashSet<>(allergies));
//        return new ResponseDto<>(true);
//    }


    @GetMapping("")
    public ResponseDto<Boolean> test() {
        return new ResponseDto<>(true);
    }

}

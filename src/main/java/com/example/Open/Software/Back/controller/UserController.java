package com.example.Open.Software.Back.controller;

import com.example.Open.Software.Back.dto.RegisterRequestDto;
import com.example.Open.Software.Back.dto.ResponseDto;
import com.example.Open.Software.Back.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/user")
@RequiredArgsConstructor // 생성자 자동 생성
public class UserController {
    private final UserService userService;

    @PostMapping("/register")
    public ResponseDto<Boolean> register(
            @RequestBody RegisterRequestDto registerRequestDto
            ){
        return new ResponseDto<>(userService.register(registerRequestDto));
    }
}

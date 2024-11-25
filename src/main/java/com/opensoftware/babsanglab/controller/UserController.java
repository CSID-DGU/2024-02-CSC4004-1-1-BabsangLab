package com.opensoftware.babsanglab.controller;

import com.opensoftware.babsanglab.dto.request.RegisterRequestDto;
import com.opensoftware.babsanglab.dto.response.RegisterResponseDto;
import com.opensoftware.babsanglab.dto.response.ResponseDto;
import com.opensoftware.babsanglab.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

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

    @GetMapping("")
    public ResponseDto<Boolean> test() {
        return new ResponseDto<>(true);
    }

}

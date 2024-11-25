package com.opensoftware.babsanglab.controller;

import com.opensoftware.babsanglab.dto.RegisterRequestDto;
import com.opensoftware.babsanglab.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/user")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;
    @PostMapping("/register")
    public Boolean register(
            @RequestBody  RegisterRequestDto registerRequestDto
            ) {
        return userService.register(registerRequestDto);
    }
}

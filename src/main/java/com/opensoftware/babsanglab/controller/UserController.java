package com.opensoftware.babsanglab.controller;

import com.opensoftware.babsanglab.dto.request.RegisterRequestDto;
import com.opensoftware.babsanglab.dto.request.UpdateRequestDto;
import com.opensoftware.babsanglab.dto.response.NotifyResponseDto;
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
    public ResponseDto<NotifyResponseDto> register(
            @RequestBody  RegisterRequestDto registerRequestDto
            ) {
        return new ResponseDto<>(userService.register(registerRequestDto));
    }

    @GetMapping("/login")
    public ResponseDto<NotifyResponseDto> login(
            @RequestParam(name="userId") String userId,
            @RequestParam(name="password") String password
    ) {
        return new ResponseDto<>(userService.login(userId,password));
    }

    @GetMapping("/register")
    public ResponseDto<NotifyResponseDto> checkId(
            @RequestParam(name="userId") String userId
        ) {
        return new ResponseDto<>(userService.checkId(userId));
    }

    @GetMapping("/pw")
    public ResponseDto<NotifyResponseDto> getPw(
            @RequestParam(name="name") String name
    ){
        return new ResponseDto<>(userService.getPw(name));
    }

    @PutMapping("/update")
    public ResponseDto<Boolean> updateUser(
            @RequestBody UpdateRequestDto updateRequestDto
    ) {
        return new ResponseDto<>(userService.updateUser(updateRequestDto));
    }

    @GetMapping("")
    public ResponseDto<Boolean> test() {
        return new ResponseDto<>(true);
    }

}

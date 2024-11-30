package com.opensoftware.babsanglab.controller;

import com.opensoftware.babsanglab.domain.User;
import com.opensoftware.babsanglab.dto.response.AnalysisResponseDto;
import com.opensoftware.babsanglab.dto.response.RateResponseDto;
import com.opensoftware.babsanglab.dto.response.RecordResponseDto;
import com.opensoftware.babsanglab.dto.response.ResponseDto;
import com.opensoftware.babsanglab.service.RecordService;
import com.opensoftware.babsanglab.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/record")
@RequiredArgsConstructor
public class RecordController {
    private final RecordService recordService;
    private final UserService userService;

    @GetMapping("/date")
    public ResponseDto<List<RecordResponseDto>> recordDay(
            @RequestParam(name="userName") String userName,
            @RequestParam(name="date") LocalDate date
    )   {
        return new ResponseDto<>(recordService.recordDay(userName,date));
    }

    @GetMapping("/rate")
    public ResponseDto<Object> rateDay(
            @RequestParam(name="userName") String userName,
            @RequestParam(name="date") LocalDate date
    ){
        return new ResponseDto<>(recordService.rateDay(userName,date));
    }

    @GetMapping("/recommend")
    public ResponseDto<List<AnalysisResponseDto>> recommendFood(
            @RequestParam(name="userName") String userName,
            @RequestParam(name="date") LocalDate date
    ){
        return new ResponseDto<>(recordService.recommendFood(userName,date));
    }
}

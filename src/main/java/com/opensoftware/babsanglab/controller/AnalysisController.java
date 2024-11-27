package com.opensoftware.babsanglab.controller;

import com.opensoftware.babsanglab.dto.response.AnalysisResponseDto;
import com.opensoftware.babsanglab.dto.response.ResponseDto;
import com.opensoftware.babsanglab.service.AnalysisService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/analysis")
public class AnalysisController {

    private AnalysisService analysisService;

    @GetMapping("/search")
    public ResponseDto<AnalysisResponseDto> analysis(
            @RequestParam(name = "foodName") String foodName
    ) {
        return new ResponseDto<>(analysisService.analysis(foodName));
    }
}

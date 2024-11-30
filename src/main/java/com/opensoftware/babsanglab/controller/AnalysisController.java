package com.opensoftware.babsanglab.controller;

import com.opensoftware.babsanglab.dto.request.AnalysisRequestDto;
import com.opensoftware.babsanglab.dto.response.AnalysisResponseDto;
import com.opensoftware.babsanglab.dto.response.ResponseDto;
import com.opensoftware.babsanglab.service.AnalysisService;
import org.springframework.web.bind.annotation.*;

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

    @PostMapping("/record")
    public ResponseDto<AnalysisResponseDto> analysisrecord(
            @RequestBody AnalysisRequestDto analysisRequestDto
    ){
        return new ResponseDto<>(analysisService.analysisRecord(analysisRequestDto));
    }
}

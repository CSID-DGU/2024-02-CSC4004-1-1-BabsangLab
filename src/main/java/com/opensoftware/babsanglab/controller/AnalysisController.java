package com.opensoftware.babsanglab.controller;

import com.opensoftware.babsanglab.dto.request.AnalysisRequestDto;
import com.opensoftware.babsanglab.dto.response.AnalysisResponseDto;
import com.opensoftware.babsanglab.dto.response.NotifyResponseDto;
import com.opensoftware.babsanglab.dto.response.ResponseDto;
import com.opensoftware.babsanglab.service.AnalysisService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/analysis")
public class AnalysisController {


    private AnalysisService analysisService;

    @Autowired  // 주입을 명시적으로 확인
    public AnalysisController(AnalysisService analysisService) {
        this.analysisService = analysisService;
    }
    @GetMapping
    public ResponseDto<AnalysisResponseDto> analysis(
            @RequestParam(name = "foodName") String foodName
    ) {
        return new ResponseDto<>(analysisService.analysis(foodName));
    }


    @PostMapping("/record")
    public ResponseDto<Object> analysisRecord(
            @RequestBody AnalysisRequestDto analysisRequestDto
    ){
        return new ResponseDto<>(analysisService.analysisRecord(analysisRequestDto));
    }

    @GetMapping("/foods")
    public ResponseDto<List<AnalysisResponseDto>> analysisAllFoods(
            @RequestParam(name = "foodNames") List<String> foodNames
    ) {
        // foodNames 리스트에 있는 각 foodName에 대해 영양 정보를 가져오는 작업
        List<AnalysisResponseDto> analysisResponseDtoList = foodNames.stream()
                .map(foodName -> analysisService.analysis(foodName))  // 각 foodName에 대해 분석을 실행
                .collect(Collectors.toList());

        return new ResponseDto<>(analysisResponseDtoList);
    }

    @PostMapping("/foods/record")
    public ResponseDto<List<Object>> analysisRecordAllFoods(
            @RequestBody List<AnalysisRequestDto> analysisRequestDtos
    ) {
        List<Object> resultList = analysisRequestDtos.stream()
                .map(analysisRequestDto -> {
                    Object result = analysisService.analysisRecord(analysisRequestDto);

                    // NotifyResponseDto 처리
                    if (result instanceof NotifyResponseDto) {
                        return result; // NotifyResponseDto 반환
                    }

                    // AnalysisResponseDto 처리
                    return result;
                })
                .collect(Collectors.toList());

        return new ResponseDto<>(resultList);
    }





}

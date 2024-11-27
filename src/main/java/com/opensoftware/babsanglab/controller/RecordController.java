package com.opensoftware.babsanglab.controller;

import com.opensoftware.babsanglab.dto.request.RecordSearchDto;
import com.opensoftware.babsanglab.dto.response.RecordResponseDto;
import com.opensoftware.babsanglab.dto.response.ResponseDto;
import com.opensoftware.babsanglab.service.RecordService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/record")
@RequiredArgsConstructor
public class RecordController {
    private final RecordService recordService;
    @PostMapping("/search")
    public ResponseDto<List<RecordResponseDto>> recordSearch(
            @RequestBody RecordSearchDto recordSearchDto) {
        return new ResponseDto<>(recordService.recordSearch(recordSearchDto));
    }
    @GetMapping("/date")
    public ResponseDto<List<RecordResponseDto>> recordDay(
            @RequestParam(name="userName") String userName,
            @RequestParam(name="date") LocalDate date
    )   {
        return new ResponseDto<>(recordService.recordDay(userName,date));
    }


}

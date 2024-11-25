package com.opensoftware.babsanglab.controller;

import com.opensoftware.babsanglab.dto.RecordSearchDto;
import com.opensoftware.babsanglab.service.RecordService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/record")
@RequiredArgsConstructor
public class RecordController {
    private final RecordService recordService;
    @PostMapping("/search")
    public boolean recordSearch(@RequestBody RecordSearchDto recordSearchDto) {
        return recordService.recordSearch(recordSearchDto);
    }
}

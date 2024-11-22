package com.example.Open.Software.Back.dto;

import com.example.Open.Software.Back.exception.ErrorDefine;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;

@AllArgsConstructor
public class ExceptionDto {
    private final String code;
    private final String message;

    public ExceptionDto(ErrorDefine errorDefine) {
        this.code = errorDefine.getErrorCode();
        this.message = errorDefine.getMessage();
    }

    public ExceptionDto(Exception exception) {
        this.code = Integer.toString(HttpStatus.INTERNAL_SERVER_ERROR.value());
        this.message = exception.getMessage();
    }
}

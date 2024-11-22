package com.example.Open.Software.Back.exception;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum ErrorDefine {
    USERID_EXIST("4091", HttpStatus.CONFLICT, "Conflict: An account with this userId already exists.");
    private final String errorCode;
    private final HttpStatus httpStatus;
    private final String message;
}

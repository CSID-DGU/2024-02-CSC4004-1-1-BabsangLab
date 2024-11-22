package com.example.Open.Software.Back.dto;

import com.example.Open.Software.Back.exception.ApiException;
import lombok.Builder;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;

@Getter
@Builder
@RequiredArgsConstructor
public class ResponseDto<T> {
    private final boolean success;
    private final T responseDto;
    private final ExceptionDto error;

    // 성공 응답 생성자
    public ResponseDto(T responseDto) {
        this.success = true;
        this.responseDto = responseDto;
        this.error = null;
    }

    // 실패 응답 생성 메서드
    public static <T> ResponseDto<T> error(ExceptionDto error) {
        return ResponseDto.<T>builder()
                .success(false)
                .responseDto(null)
                .error(error)
                .build();
    }

    // ApiException을 바탕으로 ResponseEntity 생성
    public static ResponseEntity<ResponseDto<?>> toResponseEntity(ApiException e) {
        return ResponseEntity
                .status(e.getError().getHttpStatus())
                .body(ResponseDto.error(new ExceptionDto(e.getError())));
    }
}

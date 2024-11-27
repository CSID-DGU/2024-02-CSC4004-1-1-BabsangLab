package com.opensoftware.babsanglab.dto.response;

import com.opensoftware.babsanglab.dto.exception.ExceptionDto;
import com.opensoftware.babsanglab.dto.exception.InvalidateArgumentExceptionDto;
import com.opensoftware.babsanglab.dto.exception.JSONConvertExceptionDto;
import com.opensoftware.babsanglab.exception.ApiException;
import io.micrometer.common.lang.Nullable;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageConversionException;
import org.springframework.web.bind.MethodArgumentNotValidException;

@Getter
@Builder
@AllArgsConstructor
public class ResponseDto<T> {
    private boolean isSuccess;
    private final T responseDto;
    private ExceptionDto error;

    public ResponseDto(@Nullable T responseDto) {
        this.isSuccess = true;
        this.responseDto = responseDto;
    }

    public static ResponseEntity<?> toResponseEntity(ApiException e) {
        return ResponseEntity.status(e.getError().getHttpStatus())
                .body(
                        ResponseDto.builder()
                                .isSuccess(false)
                                .responseDto(null)
                                .error(new ExceptionDto(e.getError()))
                                .build());
    }

    public static ResponseEntity<Object> toResponseEntity(MethodArgumentNotValidException e) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(
                        ResponseDto.builder()
                                .isSuccess(false)
                                .responseDto(null)
                                .error(new InvalidateArgumentExceptionDto(e))
                                .build());
    }

    public static ResponseEntity<Object> toResponseEntity(HttpMessageConversionException e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(
                        ResponseDto.builder()
                                .isSuccess(false)
                                .responseDto(null)
                                .error(new JSONConvertExceptionDto(e))
                                .build());
    }

    public static ResponseEntity<Object> toResponseEntity(Exception e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(
                        ResponseDto.builder()
                                .isSuccess(false)
                                .responseDto(null)
                                .error(new ExceptionDto(e))
                                .build());
    }
}

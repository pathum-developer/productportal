package com.elvencode.productportal.common.dto;

import org.springframework.http.HttpStatus;

import java.time.LocalDateTime;

public record ErrorResponseDto(
        String apiPath,
        HttpStatus errorCode,
        String errorMessage,
        LocalDateTime errorTime,
        String correlationId
) {
    public ErrorResponseDto(
            String apiPath,
            HttpStatus errorCode,
            String errorMessage,
            LocalDateTime errorTime) {
        this(apiPath, errorCode, errorMessage, errorTime, null);
    }
}

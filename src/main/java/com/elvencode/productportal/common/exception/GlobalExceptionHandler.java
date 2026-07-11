package com.elvencode.productportal.common.exception;


import com.elvencode.productportal.auth.protection.exception.LoginBlockedException;
import com.elvencode.productportal.auth.session.exception.InvalidRefreshTokenException;
import com.elvencode.productportal.common.dto.ErrorResponseDto;
import com.elvencode.productportal.common.web.CorrelationIdContext;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.AuthenticationException;
import org.springframework.validation.FieldError;
import org.springframework.validation.method.ParameterValidationResult;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.method.annotation.HandlerMethodValidationException;

import java.time.Clock;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestControllerAdvice
@Slf4j
@RequiredArgsConstructor
public class GlobalExceptionHandler {

    private static final String GENERIC_INTERNAL_SERVER_ERROR_MESSAGE =
            "An unexpected error occurred. Please contact support with the correlation ID.";

    private final Clock clock;

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponseDto> handleResourceNotFoundException(
            ResourceNotFoundException exception, WebRequest webRequest) {
        return buildErrorResponse(webRequest, HttpStatus.NOT_FOUND, exception.getMessage());
    }

    @ExceptionHandler(ResourceConflictException.class)
    public ResponseEntity<ErrorResponseDto> handleResourceConflictException(
            ResourceConflictException exception, WebRequest webRequest) {
        return buildErrorResponse(webRequest, HttpStatus.CONFLICT, exception.getMessage());
    }

    @ExceptionHandler(LoginBlockedException.class)
    public ResponseEntity<ErrorResponseDto> handleLoginBlockedException(
            LoginBlockedException exception, WebRequest webRequest) {
        String correlationId = CorrelationIdContext.resolveOrCreate(webRequest);
        ErrorResponseDto errorResponseDto = buildErrorResponseDto(
                webRequest,
                HttpStatus.TOO_MANY_REQUESTS,
                "Too many failed login attempts. Try again later.",
                correlationId);

        return ResponseEntity.status(HttpStatus.TOO_MANY_REQUESTS)
                .header(HttpHeaders.RETRY_AFTER, String.valueOf(exception.retryAfterSeconds(clock.instant())))
                .header(CorrelationIdContext.HEADER_NAME, correlationId)
                .body(errorResponseDto);
    }

    @ExceptionHandler(InvalidRefreshTokenException.class)
    public ResponseEntity<ErrorResponseDto> handleInvalidRefreshTokenException(
            InvalidRefreshTokenException exception, WebRequest webRequest) {
        return buildErrorResponse(webRequest, HttpStatus.UNAUTHORIZED, "Invalid refresh token");
    }

    @ExceptionHandler(AuthenticationException.class)
    public ResponseEntity<ErrorResponseDto> handleAuthenticationException(
            AuthenticationException exception, WebRequest webRequest) {
        return buildErrorResponse(webRequest, HttpStatus.UNAUTHORIZED, "Invalid username or password");
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponseDto> handleException(Exception exception, WebRequest webRequest) {
        return handleInternalServerError(exception, webRequest);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, String>> handleException(
            MethodArgumentNotValidException exception,
            WebRequest webRequest) {
        Map<String, String> errors = new HashMap<>();
        List<FieldError> fieldErrorList = exception.getBindingResult().getFieldErrors();
        fieldErrorList.forEach(error -> errors.put(error.getField(), error.getDefaultMessage()));
        return buildBadRequestResponse(webRequest, errors);
    }

    @ExceptionHandler(HandlerMethodValidationException.class)
    public ResponseEntity<Map<String, String>> handleException(
            HandlerMethodValidationException exception,
            WebRequest webRequest) {
        Map<String, String> errors = new HashMap<>();
        List<ParameterValidationResult> results = exception.getParameterValidationResults();
        results.forEach(result -> {
            String paramName = result.getMethodParameter().getParameterName();

            String combinedMessages = result.getResolvableErrors()
                    .stream()
                    .map(error -> error.getDefaultMessage())
                    .collect(Collectors.joining(", "));
            errors.put(paramName, combinedMessages);
        });
        return buildBadRequestResponse(webRequest, errors);
    }

    @ExceptionHandler(NullPointerException.class)
    public ResponseEntity<ErrorResponseDto> handleNullException(
            NullPointerException exception,
            WebRequest webRequest) {
        return handleInternalServerError(exception, webRequest);
    }

    private ResponseEntity<ErrorResponseDto> handleInternalServerError(
            Exception exception,
            WebRequest webRequest) {
        String correlationId = CorrelationIdContext.resolveOrCreate(webRequest);
        log.error("Unhandled exception for request {}. correlationId={}",
                webRequest.getDescription(false), correlationId, exception);

        ErrorResponseDto errorResponseDto = buildErrorResponseDto(
                webRequest,
                HttpStatus.INTERNAL_SERVER_ERROR,
                GENERIC_INTERNAL_SERVER_ERROR_MESSAGE,
                correlationId);

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .header(CorrelationIdContext.HEADER_NAME, correlationId)
                .body(errorResponseDto);
    }

    private ResponseEntity<ErrorResponseDto> buildErrorResponse(
            WebRequest webRequest,
            HttpStatus httpStatus,
            String errorMessage) {
        String correlationId = CorrelationIdContext.resolveOrCreate(webRequest);
        ErrorResponseDto errorResponseDto = buildErrorResponseDto(
                webRequest,
                httpStatus,
                errorMessage,
                correlationId);

        return ResponseEntity.status(httpStatus)
                .header(CorrelationIdContext.HEADER_NAME, correlationId)
                .body(errorResponseDto);
    }

    private ErrorResponseDto buildErrorResponseDto(
            WebRequest webRequest,
            HttpStatus httpStatus,
            String errorMessage,
            String correlationId) {
        return new ErrorResponseDto(
                webRequest.getDescription(false),
                httpStatus,
                errorMessage,
                LocalDateTime.now(clock),
                correlationId);
    }

    private ResponseEntity<Map<String, String>> buildBadRequestResponse(
            WebRequest webRequest,
            Map<String, String> errors) {
        String correlationId = CorrelationIdContext.resolveOrCreate(webRequest);
        return ResponseEntity.badRequest()
                .header(CorrelationIdContext.HEADER_NAME, correlationId)
                .body(errors);
    }

}

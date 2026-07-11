package com.elvencode.productportal.common.exception;

import com.elvencode.productportal.common.dto.ErrorResponseDto;
import com.elvencode.productportal.common.web.CorrelationIdContext;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.web.context.request.ServletWebRequest;

import static org.assertj.core.api.Assertions.assertThat;

class GlobalExceptionHandlerTest {

    private static final String SAFE_INTERNAL_ERROR_MESSAGE =
            "An unexpected error occurred. Please contact support with the correlation ID.";

    private final GlobalExceptionHandler exceptionHandler = new GlobalExceptionHandler();

    @Test
    void genericExceptionShouldReturnSafeErrorMessageWithCorrelationId() {
        ServletWebRequest webRequest = webRequestWithCorrelationId("client-request-123");
        RuntimeException exception = new IllegalStateException("database password is invalid");

        ResponseEntity<ErrorResponseDto> response = exceptionHandler.handleException(exception, webRequest);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.INTERNAL_SERVER_ERROR);
        assertThat(response.getHeaders().getFirst(CorrelationIdContext.HEADER_NAME))
                .isEqualTo("client-request-123");

        ErrorResponseDto body = response.getBody();
        assertThat(body).isNotNull();
        assertThat(body.errorMessage()).isEqualTo(SAFE_INTERNAL_ERROR_MESSAGE);
        assertThat(body.errorMessage()).doesNotContain("database password");
        assertThat(body.correlationId()).isEqualTo("client-request-123");
    }

    @Test
    void nullPointerExceptionShouldReturnSafeErrorMessageWithCorrelationId() {
        ServletWebRequest webRequest = webRequestWithCorrelationId("npe-request-456");
        NullPointerException exception = new NullPointerException("Cannot invoke String.length()");

        ResponseEntity<ErrorResponseDto> response = exceptionHandler.handleNullException(exception, webRequest);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.INTERNAL_SERVER_ERROR);

        ErrorResponseDto body = response.getBody();
        assertThat(body).isNotNull();
        assertThat(body.errorMessage()).isEqualTo(SAFE_INTERNAL_ERROR_MESSAGE);
        assertThat(body.errorMessage()).doesNotContain("NullPointerException", "Cannot invoke");
        assertThat(body.correlationId()).isEqualTo("npe-request-456");
    }

    @Test
    void genericExceptionShouldGenerateCorrelationIdWhenRequestDoesNotProvideOne() {
        ServletWebRequest webRequest = webRequestWithoutCorrelationId();

        ResponseEntity<ErrorResponseDto> response = exceptionHandler.handleException(
                new RuntimeException("internal details"),
                webRequest);

        String responseHeaderCorrelationId = response.getHeaders().getFirst(CorrelationIdContext.HEADER_NAME);
        ErrorResponseDto body = response.getBody();

        assertThat(body).isNotNull();
        assertThat(responseHeaderCorrelationId).isNotBlank();
        assertThat(body.correlationId()).isEqualTo(responseHeaderCorrelationId);
        assertThat(body.errorMessage()).doesNotContain("internal details");
    }

    private ServletWebRequest webRequestWithCorrelationId(String correlationId) {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/test");
        request.addHeader(CorrelationIdContext.HEADER_NAME, correlationId);
        return new ServletWebRequest(request);
    }

    private ServletWebRequest webRequestWithoutCorrelationId() {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/test");
        return new ServletWebRequest(request);
    }
}

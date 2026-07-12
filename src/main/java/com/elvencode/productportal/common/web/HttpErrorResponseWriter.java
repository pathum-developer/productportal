package com.elvencode.productportal.common.web;

import com.elvencode.productportal.common.dto.ErrorResponseDto;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.databind.json.JsonMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.Objects;

@Component
public class HttpErrorResponseWriter {

    private final ObjectMapper objectMapper;
    private final Clock clock;

    @Autowired
    public HttpErrorResponseWriter(ObjectProvider<ObjectMapper> objectMapperProvider, Clock clock) {
        this(objectMapperProvider.getIfAvailable(HttpErrorResponseWriter::createDefaultObjectMapper), clock);
    }

    public HttpErrorResponseWriter(ObjectMapper objectMapper, Clock clock) {
        this.objectMapper = Objects.requireNonNull(objectMapper, "objectMapper must not be null");
        this.clock = Objects.requireNonNull(clock, "clock must not be null");
    }

    public void write(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpStatus httpStatus,
            String errorMessage) throws IOException {
        if (response.isCommitted()) {
            return;
        }

        String correlationId = CorrelationIdContext.resolveOrCreate(request);
        request.setAttribute(CorrelationIdContext.REQUEST_ATTRIBUTE, correlationId);

        response.resetBuffer();
        response.setStatus(httpStatus.value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.setHeader(CorrelationIdContext.HEADER_NAME, correlationId);

        ErrorResponseDto errorResponseDto = new ErrorResponseDto(
                buildApiPath(request),
                httpStatus,
                errorMessage,
                LocalDateTime.now(clock),
                correlationId);

        objectMapper.writeValue(response.getOutputStream(), errorResponseDto);
        response.flushBuffer();
    }

    private String buildApiPath(HttpServletRequest request) {
        return "uri=" + request.getRequestURI();
    }

    private static ObjectMapper createDefaultObjectMapper() {
        return JsonMapper.builder()
                .addModule(new JavaTimeModule())
                .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS)
                .build();
    }
}

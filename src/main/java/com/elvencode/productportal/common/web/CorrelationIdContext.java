package com.elvencode.productportal.common.web;

import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.MDC;
import org.springframework.util.StringUtils;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.WebRequest;

import java.util.Optional;
import java.util.UUID;
import java.util.regex.Pattern;

public final class CorrelationIdContext {

    public static final String HEADER_NAME = "X-Correlation-ID";
    public static final String MDC_KEY = "correlationId";
    public static final String REQUEST_ATTRIBUTE = CorrelationIdContext.class.getName() + ".correlationId";

    private static final int MAX_CORRELATION_ID_LENGTH = 100;
    private static final Pattern SAFE_CORRELATION_ID_PATTERN = Pattern.compile("^[A-Za-z0-9._:-]+$");

    private CorrelationIdContext() {
        throw new AssertionError("Utility class cannot be instantiated");
    }

    public static String resolveOrCreate(HttpServletRequest request) {
        return normalize(request.getHeader(HEADER_NAME))
                .orElseGet(CorrelationIdContext::createCorrelationId);
    }

    public static String resolveOrCreate(WebRequest webRequest) {
        Object requestAttribute = webRequest.getAttribute(REQUEST_ATTRIBUTE, RequestAttributes.SCOPE_REQUEST);
        if (requestAttribute instanceof String correlationId) {
            Optional<String> normalizedCorrelationId = normalize(correlationId);
            if (normalizedCorrelationId.isPresent()) {
                return normalizedCorrelationId.get();
            }
        }

        Optional<String> mdcCorrelationId = normalize(MDC.get(MDC_KEY));
        if (mdcCorrelationId.isPresent()) {
            return mdcCorrelationId.get();
        }

        return normalize(webRequest.getHeader(HEADER_NAME))
                .orElseGet(CorrelationIdContext::createCorrelationId);
    }

    public static Optional<String> normalize(String correlationId) {
        if (!StringUtils.hasText(correlationId)) {
            return Optional.empty();
        }

        String trimmedCorrelationId = correlationId.trim();
        if (trimmedCorrelationId.length() > MAX_CORRELATION_ID_LENGTH
                || !SAFE_CORRELATION_ID_PATTERN.matcher(trimmedCorrelationId).matches()) {
            return Optional.empty();
        }

        return Optional.of(trimmedCorrelationId);
    }

    private static String createCorrelationId() {
        return UUID.randomUUID().toString();
    }
}

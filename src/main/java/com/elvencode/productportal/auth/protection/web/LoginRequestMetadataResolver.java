package com.elvencode.productportal.auth.protection.web;

import com.elvencode.productportal.auth.config.AuthenticationProtectionProperties;
import com.elvencode.productportal.auth.protection.dto.LoginRequestMetadata;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.util.Locale;

@Component
@RequiredArgsConstructor
public class LoginRequestMetadataResolver {

    private static final int MAX_CLIENT_IP_LENGTH = 45;
    private static final int MAX_USER_AGENT_LENGTH = 512;
    private static final String FORWARDED_HEADER = "Forwarded";
    private static final String X_FORWARDED_FOR_HEADER = "X-Forwarded-For";
    private static final String X_REAL_IP_HEADER = "X-Real-IP";

    private final AuthenticationProtectionProperties properties;

    public LoginRequestMetadata resolve(HttpServletRequest request) {
        return new LoginRequestMetadata(
                truncate(resolveClientIp(request), MAX_CLIENT_IP_LENGTH),
                truncate(request.getHeader(HttpHeaders.USER_AGENT), MAX_USER_AGENT_LENGTH));
    }

    private String resolveClientIp(HttpServletRequest request) {
        if (Boolean.TRUE.equals(properties.trustForwardedHeaders())) {
            String forwardedIp = resolveForwardedClientIp(request);
            if (StringUtils.hasText(forwardedIp)) {
                return forwardedIp;
            }
        }

        return request.getRemoteAddr();
    }

    private String resolveForwardedClientIp(HttpServletRequest request) {
        String forwardedHeader = request.getHeader(FORWARDED_HEADER);
        String forwardedFor = extractForwardedFor(forwardedHeader);
        if (StringUtils.hasText(forwardedFor)) {
            return forwardedFor;
        }

        String xForwardedFor = firstHeaderValue(request.getHeader(X_FORWARDED_FOR_HEADER));
        if (StringUtils.hasText(xForwardedFor)) {
            return xForwardedFor;
        }

        return request.getHeader(X_REAL_IP_HEADER);
    }

    private String extractForwardedFor(String forwardedHeader) {
        if (!StringUtils.hasText(forwardedHeader)) {
            return null;
        }

        String firstEntry = firstHeaderValue(forwardedHeader);
        for (String directive : firstEntry.split(";")) {
            String[] parts = directive.split("=", 2);
            if (parts.length == 2 && "for".equals(parts[0].trim().toLowerCase(Locale.ROOT))) {
                return cleanForwardedForValue(parts[1]);
            }
        }

        return null;
    }

    private String cleanForwardedForValue(String value) {
        if (!StringUtils.hasText(value)) {
            return null;
        }

        String cleaned = value.trim().replace("\"", "");
        if (cleaned.startsWith("[") && cleaned.contains("]")) {
            return cleaned.substring(1, cleaned.indexOf(']'));
        }

        return cleaned;
    }

    private String firstHeaderValue(String value) {
        if (!StringUtils.hasText(value)) {
            return null;
        }

        return value.split(",", 2)[0].trim();
    }

    private String truncate(String value, int maxLength) {
        if (!StringUtils.hasText(value)) {
            return null;
        }

        String trimmed = value.trim();
        return trimmed.length() <= maxLength ? trimmed : trimmed.substring(0, maxLength);
    }
}

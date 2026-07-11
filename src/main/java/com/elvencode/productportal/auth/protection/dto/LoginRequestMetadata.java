package com.elvencode.productportal.auth.protection.dto;

public record LoginRequestMetadata(
        String clientIp,
        String userAgent
) {

    private static final String UNKNOWN_CLIENT_IP = "unknown";

    public LoginRequestMetadata {
        clientIp = hasText(clientIp) ? clientIp.trim() : UNKNOWN_CLIENT_IP;
        userAgent = hasText(userAgent) ? userAgent.trim() : null;
    }

    public static LoginRequestMetadata unknown() {
        return new LoginRequestMetadata(UNKNOWN_CLIENT_IP, null);
    }

    private static boolean hasText(String value) {
        return value != null && !value.trim().isEmpty();
    }
}

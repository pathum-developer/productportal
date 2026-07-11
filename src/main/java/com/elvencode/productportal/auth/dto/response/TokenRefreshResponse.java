package com.elvencode.productportal.auth.dto.response;

import java.time.Instant;
import java.util.UUID;

public record TokenRefreshResponse(
        String tokenType,
        String accessToken,
        String refreshToken,
        UUID sessionId,
        Instant issuedAt,
        Instant expiresAt,
        Long expiresInSeconds,
        Instant refreshExpiresAt
) {
}

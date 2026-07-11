package com.elvencode.productportal.auth.session.dto;

import java.time.Instant;
import java.util.UUID;

public record RotatedAuthSession(
        UUID sessionId,
        Long userId,
        String refreshToken,
        Instant refreshExpiresAt
) {
}

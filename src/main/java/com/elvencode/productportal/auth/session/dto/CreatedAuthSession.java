package com.elvencode.productportal.auth.session.dto;

import java.time.Instant;
import java.util.UUID;

public record CreatedAuthSession(
        UUID sessionId,
        String refreshToken,
        Instant refreshExpiresAt
) {
}

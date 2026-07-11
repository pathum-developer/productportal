package com.elvencode.productportal.auth.session.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

import java.time.Duration;

@ConfigurationProperties(prefix = "auth.session")
public record AuthenticationSessionProperties(
        Duration refreshTokenTtl,
        Integer maxActiveSessionsPerUser
) {

    private static final Duration DEFAULT_REFRESH_TOKEN_TTL = Duration.ofDays(30);
    private static final int DEFAULT_MAX_ACTIVE_SESSIONS_PER_USER = 5;

    public AuthenticationSessionProperties {
        refreshTokenTtl = refreshTokenTtl == null ? DEFAULT_REFRESH_TOKEN_TTL : refreshTokenTtl;
        maxActiveSessionsPerUser = maxActiveSessionsPerUser == null
                ? DEFAULT_MAX_ACTIVE_SESSIONS_PER_USER
                : maxActiveSessionsPerUser;

        if (refreshTokenTtl.isZero() || refreshTokenTtl.isNegative()) {
            throw new IllegalArgumentException("auth.session.refresh-token-ttl must be positive");
        }

        if (maxActiveSessionsPerUser <= 0) {
            throw new IllegalArgumentException("auth.session.max-active-sessions-per-user must be positive");
        }
    }
}

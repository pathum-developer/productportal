package com.elvencode.productportal.security.config;

import io.jsonwebtoken.security.Keys;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.util.StringUtils;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Duration;

@ConfigurationProperties(prefix = "jwt")
public record JwtProperties(
        String secret,
        Duration accessTokenTtl,
        String issuer
) {

    private static final int MINIMUM_SECRET_BYTES = 64;
    private static final Duration DEFAULT_ACCESS_TOKEN_TTL = Duration.ofMinutes(15);
    private static final String DEFAULT_ISSUER = "Product Portal";

    public JwtProperties {
        if (!StringUtils.hasText(secret)) {
            throw new IllegalArgumentException("JWT_SECRET must be configured");
        }

        secret = secret.trim();
        accessTokenTtl = accessTokenTtl == null ? DEFAULT_ACCESS_TOKEN_TTL : accessTokenTtl;
        issuer = StringUtils.hasText(issuer) ? issuer.trim() : DEFAULT_ISSUER;

        if (secret.getBytes(StandardCharsets.UTF_8).length < MINIMUM_SECRET_BYTES) {
            throw new IllegalArgumentException("JWT_SECRET must be at least 64 UTF-8 bytes");
        }

        if (accessTokenTtl.isZero() || accessTokenTtl.isNegative()) {
            throw new IllegalArgumentException("jwt.access-token-ttl must be positive");
        }
    }

    public SecretKey signingKey() {
        return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }
}

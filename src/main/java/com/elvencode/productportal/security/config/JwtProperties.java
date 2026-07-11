package com.elvencode.productportal.security.config;

import io.jsonwebtoken.security.Keys;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.util.StringUtils;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;

@ConfigurationProperties(prefix = "jwt")
public record JwtProperties(String secret) {

    private static final int MINIMUM_SECRET_BYTES = 64;

    public JwtProperties {
        if (!StringUtils.hasText(secret)) {
            throw new IllegalArgumentException("JWT_SECRET must be configured");
        }

        secret = secret.trim();

        if (secret.getBytes(StandardCharsets.UTF_8).length < MINIMUM_SECRET_BYTES) {
            throw new IllegalArgumentException("JWT_SECRET must be at least 64 UTF-8 bytes");
        }
    }

    public SecretKey signingKey() {
        return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }
}

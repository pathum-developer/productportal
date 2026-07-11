package com.elvencode.productportal.auth.session.token;

import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.HexFormat;
import java.util.UUID;

@Component
public class RefreshTokenCodec {

    private static final String TOKEN_PREFIX = "pp_rt_";
    private static final int SECRET_BYTE_LENGTH = 32;
    private static final String HASH_ALGORITHM = "SHA-256";

    private final SecureRandom secureRandom = new SecureRandom();

    public GeneratedRefreshToken generate(UUID sessionId) {
        byte[] secretBytes = new byte[SECRET_BYTE_LENGTH];
        secureRandom.nextBytes(secretBytes);
        String secret = Base64.getUrlEncoder().withoutPadding().encodeToString(secretBytes);
        String token = TOKEN_PREFIX + sessionId + "." + secret;

        return new GeneratedRefreshToken(sessionId, token, hashSecret(secret));
    }

    public ParsedRefreshToken parse(String rawToken) {
        if (!StringUtils.hasText(rawToken)) {
            throw invalidRefreshToken();
        }

        String token = rawToken.trim();
        if (!token.startsWith(TOKEN_PREFIX)) {
            throw invalidRefreshToken();
        }

        String[] parts = token.substring(TOKEN_PREFIX.length()).split("\\.", 2);
        if (parts.length != 2 || !StringUtils.hasText(parts[0]) || !StringUtils.hasText(parts[1])) {
            throw invalidRefreshToken();
        }

        try {
            return new ParsedRefreshToken(UUID.fromString(parts[0]), parts[1]);
        } catch (IllegalArgumentException exception) {
            throw invalidRefreshToken();
        }
    }

    public boolean matches(String presentedSecret, String expectedHash) {
        if (!StringUtils.hasText(presentedSecret) || !StringUtils.hasText(expectedHash)) {
            return false;
        }

        byte[] presented = hashSecret(presentedSecret).getBytes(StandardCharsets.UTF_8);
        byte[] expected = expectedHash.getBytes(StandardCharsets.UTF_8);
        return MessageDigest.isEqual(presented, expected);
    }

    public String hashSecret(String secret) {
        if (!StringUtils.hasText(secret)) {
            throw invalidRefreshToken();
        }

        try {
            MessageDigest digest = MessageDigest.getInstance(HASH_ALGORITHM);
            return HexFormat.of().formatHex(digest.digest(secret.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 message digest is not available", exception);
        }
    }

    private BadCredentialsException invalidRefreshToken() {
        return new BadCredentialsException("Invalid refresh token");
    }

    public record GeneratedRefreshToken(
            UUID sessionId,
            String token,
            String secretHash
    ) {
    }

    public record ParsedRefreshToken(
            UUID sessionId,
            String secret
    ) {
    }
}

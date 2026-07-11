package com.elvencode.productportal.security.util;

import com.elvencode.productportal.security.config.JwtProperties;
import com.elvencode.productportal.security.principal.ProductPortalUserPrincipal;
import io.jsonwebtoken.Jwts;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.time.Instant;
import java.util.Date;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class JwtUtil {

    public static final String SESSION_ID_CLAIM = "sessionId";

    private final JwtProperties jwtProperties;

    public String generateJwtToken(Authentication authentication) {
        return generateJwtToken(authentication, Instant.now());
    }

    public String generateJwtToken(Authentication authentication, Instant issuedAt) {
        return generateJwtToken(authentication, null, issuedAt);
    }

    public String generateJwtToken(Authentication authentication, UUID sessionId, Instant issuedAt) {
        SecretKey secretKey = jwtProperties.signingKey();
        ProductPortalUserPrincipal principal = (ProductPortalUserPrincipal) authentication.getPrincipal();
        Instant expiresAt = calculateAccessTokenExpiresAt(issuedAt);

        var builder = Jwts.builder()
                .issuer(jwtProperties.issuer())
                .id(UUID.randomUUID().toString())
                .subject(String.valueOf(principal.userId()))
                .claim("userId", principal.userId())
                .issuedAt(Date.from(issuedAt))
                .expiration(Date.from(expiresAt));

        if (sessionId != null) {
            builder.claim(SESSION_ID_CLAIM, sessionId.toString());
        }

        return builder.signWith(secretKey).compact();
    }

    public long getAccessTokenValiditySeconds() {
        return jwtProperties.accessTokenTtl().toSeconds();
    }

    public Instant calculateAccessTokenExpiresAt(Instant issuedAt) {
        return issuedAt.plus(jwtProperties.accessTokenTtl());
    }
}

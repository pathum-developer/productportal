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

    private final JwtProperties jwtProperties;

    public String generateJwtToken(Authentication authentication) {
        return generateJwtToken(authentication, Instant.now());
    }

    public String generateJwtToken(Authentication authentication, Instant issuedAt) {
        SecretKey secretKey = jwtProperties.signingKey();
        ProductPortalUserPrincipal principal = (ProductPortalUserPrincipal) authentication.getPrincipal();
        Instant expiresAt = calculateAccessTokenExpiresAt(issuedAt);

        return Jwts.builder()
                .issuer(jwtProperties.issuer())
                .id(UUID.randomUUID().toString())
                .subject(String.valueOf(principal.userId()))
                .claim("userId", principal.userId())
                .issuedAt(Date.from(issuedAt))
                .expiration(Date.from(expiresAt))
                .signWith(secretKey).compact();
    }

    public long getAccessTokenValiditySeconds() {
        return jwtProperties.accessTokenTtl().toSeconds();
    }

    public Instant calculateAccessTokenExpiresAt(Instant issuedAt) {
        return issuedAt.plus(jwtProperties.accessTokenTtl());
    }
}

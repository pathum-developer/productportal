package com.elvencode.productportal.security.util;

import com.elvencode.productportal.security.config.JwtProperties;
import com.elvencode.productportal.security.principal.ProductPortalUserPrincipal;
import io.jsonwebtoken.Jwts;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.time.Instant;
import java.util.Date;

@Component
@RequiredArgsConstructor
public class JwtUtil {

    private static final long ACCESS_TOKEN_VALIDITY_SECONDS = 24 * 60 * 60;

    private final JwtProperties jwtProperties;

    public String generateJwtToken(Authentication authentication) {
        return generateJwtToken(authentication, Instant.now());
    }

    public String generateJwtToken(Authentication authentication, Instant issuedAt) {
        SecretKey secretKey = jwtProperties.signingKey();
        ProductPortalUserPrincipal principal = (ProductPortalUserPrincipal) authentication.getPrincipal();
        Instant expiresAt = calculateAccessTokenExpiresAt(issuedAt);

        return Jwts.builder()
                .issuer("Product Portal")
                .subject(principal.username())
                .claim("userId", principal.userId())
                .claim("username", principal.username())
                .claim("email", principal.email())
                .claim("phoneNumber", principal.phoneNumber())
                .claim("primaryOrganizationId", principal.primaryOrganizationId())
                .claim("roleCodes", principal.roleCodes())
                .claim("permissionCodes", principal.permissionCodes())
                .claim("status", principal.statusCode())
                .claim("authorities", authentication.getAuthorities()
                        .stream().map(GrantedAuthority::getAuthority)
                        .toList())
                .issuedAt(Date.from(issuedAt))
                .expiration(Date.from(expiresAt))
                .signWith(secretKey).compact();
    }

    public long getAccessTokenValiditySeconds() {
        return ACCESS_TOKEN_VALIDITY_SECONDS;
    }

    public Instant calculateAccessTokenExpiresAt(Instant issuedAt) {
        return issuedAt.plusSeconds(ACCESS_TOKEN_VALIDITY_SECONDS);
    }
}

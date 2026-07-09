package com.elvencode.productportal.security.util;

import com.elvencode.productportal.common.constants.ApplicationConstants;
import com.elvencode.productportal.security.principal.ProductPortalUserPrincipal;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import org.springframework.core.env.Environment;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class JwtUtil {

    private static final long ACCESS_TOKEN_VALIDITY_SECONDS = 24 * 60 * 60;

    private final Environment env;

    public String generateJwtToken(Authentication authentication) {
        String secret = env.getProperty(ApplicationConstants.JWT_SECRET_KEY,
                ApplicationConstants.JWT_SECRET_DEFAULT_VALUE);
        SecretKey secretKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        ProductPortalUserPrincipal principal = (ProductPortalUserPrincipal) authentication.getPrincipal();
        Instant issuedAt = Instant.now();
        Instant expiresAt = issuedAt.plusSeconds(ACCESS_TOKEN_VALIDITY_SECONDS);

        return Jwts.builder()
                .issuer("Product Portal")
                .subject(principal.username())
                .claim("userId", principal.userId())
                .claim("username", principal.username())
                .claim("email", principal.email())
                .claim("phoneNumber", principal.phoneNumber())
                .claim("role", principal.roleCode())
                .claim("status", principal.statusCode())
                .claim("roles", authentication.getAuthorities()
                        .stream().map(GrantedAuthority::getAuthority)
                        .collect(Collectors.joining(",")))
                .issuedAt(Date.from(issuedAt))
                .expiration(Date.from(expiresAt))
                .signWith(secretKey).compact();
    }

    public long getAccessTokenValiditySeconds() {
        return ACCESS_TOKEN_VALIDITY_SECONDS;
    }
}

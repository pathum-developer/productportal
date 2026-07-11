package com.elvencode.productportal.security.util;

import com.elvencode.productportal.security.config.JwtProperties;
import com.elvencode.productportal.security.principal.ProductPortalUserPrincipal;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import org.junit.jupiter.api.Test;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.time.Duration;
import java.time.Instant;
import java.util.Date;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class JwtUtilTest {

    private static final String STRONG_SECRET = "a".repeat(64);

    @Test
    void shouldCreateShortLivedTokenWithIdentityClaimsOnly() {
        JwtProperties jwtProperties = new JwtProperties(
                STRONG_SECRET,
                Duration.ofMinutes(10),
                "Product Portal Test");
        JwtUtil jwtUtil = new JwtUtil(jwtProperties);
        Instant issuedAt = Instant.parse("2026-07-11T10:00:00Z");

        String token = jwtUtil.generateJwtToken(authentication(), issuedAt);

        Claims claims = Jwts.parser()
                .requireIssuer("Product Portal Test")
                .verifyWith(jwtProperties.signingKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();

        assertThat(claims.getSubject()).isEqualTo("42");
        assertThat(claims.get("userId", Number.class).longValue()).isEqualTo(42L);
        assertThat(claims.getIssuedAt()).isEqualTo(Date.from(issuedAt));
        assertThat(claims.getExpiration()).isEqualTo(Date.from(issuedAt.plus(Duration.ofMinutes(10))));
        assertThat(claims.getId()).isNotBlank();

        assertThat(claims.get("username")).isNull();
        assertThat(claims.get("email")).isNull();
        assertThat(claims.get("phoneNumber")).isNull();
        assertThat(claims.get("roleCodes")).isNull();
        assertThat(claims.get("permissionCodes")).isNull();
        assertThat(claims.get("authorities")).isNull();
    }

    @Test
    void shouldUseConfiguredAccessTokenTtl() {
        JwtUtil jwtUtil = new JwtUtil(new JwtProperties(
                STRONG_SECRET,
                Duration.ofMinutes(7),
                "Product Portal Test"));
        Instant issuedAt = Instant.parse("2026-07-11T10:00:00Z");

        assertThat(jwtUtil.calculateAccessTokenExpiresAt(issuedAt))
                .isEqualTo(issuedAt.plus(Duration.ofMinutes(7)));
        assertThat(jwtUtil.getAccessTokenValiditySeconds()).isEqualTo(420L);
    }

    private UsernamePasswordAuthenticationToken authentication() {
        ProductPortalUserPrincipal principal = new ProductPortalUserPrincipal(
                42L,
                "alice",
                "alice@example.test",
                "+94111111111",
                7L,
                List.of("ADMIN"),
                List.of("PRODUCT_READ"),
                "ACTIVE");

        return new UsernamePasswordAuthenticationToken(
                principal,
                null,
                List.of(new SimpleGrantedAuthority("ROLE_ADMIN")));
    }
}

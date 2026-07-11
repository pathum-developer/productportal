package com.elvencode.productportal.security.util;

import com.elvencode.productportal.security.config.JwtProperties;
import com.elvencode.productportal.security.principal.ProductPortalUserPrincipal;
import io.jsonwebtoken.Claims;
import org.junit.jupiter.api.Test;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.Date;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

class JwtUtilTest {

    private static final String STRONG_SECRET = "a".repeat(64);
    private static final UUID SESSION_ID = UUID.fromString("9db45bc0-3625-47e5-a794-784f37f62734");
    private static final Instant NOW = Instant.parse("2026-07-11T10:00:00Z");
    private static final Clock FIXED_CLOCK = Clock.fixed(NOW, ZoneOffset.UTC);

    @Test
    void shouldCreateShortLivedTokenWithIdentityAndSessionClaimsOnly() {
        JwtProperties jwtProperties = new JwtProperties(
                STRONG_SECRET,
                Duration.ofMinutes(10),
                "Product Portal Test");
        JwtUtil jwtUtil = new JwtUtil(jwtProperties, FIXED_CLOCK);
        Instant issuedAt = NOW;

        String token = jwtUtil.generateJwtToken(authentication(), SESSION_ID, issuedAt);

        Claims claims = jwtUtil.parseSignedClaims(token);

        assertThat(claims.getSubject()).isEqualTo("42");
        assertThat(claims.get("userId", Number.class).longValue()).isEqualTo(42L);
        assertThat(claims.get(JwtUtil.SESSION_ID_CLAIM, String.class)).isEqualTo(SESSION_ID.toString());
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
    void shouldIssueTokenUsingConfiguredClock() {
        JwtProperties jwtProperties = new JwtProperties(
                STRONG_SECRET,
                Duration.ofMinutes(10),
                "Product Portal Test");
        JwtUtil jwtUtil = new JwtUtil(jwtProperties, FIXED_CLOCK);

        String token = jwtUtil.generateJwtToken(authentication());

        Claims claims = jwtUtil.parseSignedClaims(token);
        assertThat(claims.getIssuedAt()).isEqualTo(Date.from(NOW));
        assertThat(claims.getExpiration()).isEqualTo(Date.from(NOW.plus(Duration.ofMinutes(10))));
    }

    @Test
    void shouldUseConfiguredAccessTokenTtl() {
        JwtUtil jwtUtil = new JwtUtil(new JwtProperties(
                STRONG_SECRET,
                Duration.ofMinutes(7),
                "Product Portal Test"),
                FIXED_CLOCK);
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

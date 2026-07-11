package com.elvencode.productportal.auth.session.entity;

import com.elvencode.productportal.auth.protection.dto.LoginRequestMetadata;
import com.elvencode.productportal.user.entity.PortalUser;
import org.junit.jupiter.api.Test;

import java.time.Duration;
import java.time.Instant;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

class AuthSessionTest {

    @Test
    void shouldTrackRefreshRotationRevocationAndCredentialInvalidation() {
        Instant issuedAt = Instant.parse("2026-07-12T10:00:00Z");
        PortalUser user = PortalUser.register(
                "alice",
                "Alice",
                "alice@example.test",
                null,
                "$hash",
                null,
                null);

        AuthSession session = AuthSession.create(
                UUID.fromString("9db45bc0-3625-47e5-a794-784f37f62734"),
                user,
                "a".repeat(64),
                issuedAt.plus(Duration.ofDays(30)),
                new LoginRequestMetadata("10.0.0.10", "JUnit"),
                issuedAt);

        assertThat(session.isActive(issuedAt)).isTrue();
        assertThat(session.isValidForCredentials(issuedAt.minusSeconds(1))).isTrue();
        assertThat(session.isValidForCredentials(issuedAt.plusSeconds(1))).isFalse();
        assertThat(session.getClientIp()).isEqualTo("10.0.0.10");

        Instant rotatedAt = issuedAt.plus(Duration.ofMinutes(5));
        session.rotateRefreshToken(
                "b".repeat(64),
                rotatedAt.plus(Duration.ofDays(30)),
                new LoginRequestMetadata("10.0.0.11", "JUnit-Rotated"),
                rotatedAt);

        assertThat(session.getRefreshTokenHash()).isEqualTo("b".repeat(64));
        assertThat(session.getLastUsedAt()).isEqualTo(rotatedAt);
        assertThat(session.getClientIp()).isEqualTo("10.0.0.11");

        session.revoke(AuthSessionRevocationReason.LOGOUT, rotatedAt.plusSeconds(1));

        assertThat(session.isActive(rotatedAt.plusSeconds(1))).isFalse();
        assertThat(session.getRevocationReason()).isEqualTo(AuthSessionRevocationReason.LOGOUT);
    }
}

package com.elvencode.productportal.auth.session.service.impl;

import com.elvencode.productportal.auth.protection.dto.LoginRequestMetadata;
import com.elvencode.productportal.auth.session.config.AuthenticationSessionProperties;
import com.elvencode.productportal.auth.session.dto.CreatedAuthSession;
import com.elvencode.productportal.auth.session.dto.RotatedAuthSession;
import com.elvencode.productportal.auth.session.entity.AuthSession;
import com.elvencode.productportal.auth.session.entity.AuthSessionRevocationReason;
import com.elvencode.productportal.auth.session.exception.InvalidRefreshTokenException;
import com.elvencode.productportal.auth.session.repository.AuthSessionRepository;
import com.elvencode.productportal.auth.session.token.RefreshTokenCodec;
import com.elvencode.productportal.user.entity.PortalUser;
import com.elvencode.productportal.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.security.authentication.BadCredentialsException;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class AuthSessionServiceImplTest {

    private static final Instant NOW = Instant.parse("2026-07-12T10:00:00Z");

    private AuthSessionRepository authSessionRepository;
    private UserRepository userRepository;
    private RefreshTokenCodec refreshTokenCodec;
    private AuthSessionServiceImpl service;
    private PortalUser user;

    @BeforeEach
    void setUp() {
        authSessionRepository = mock(AuthSessionRepository.class);
        userRepository = mock(UserRepository.class);
        refreshTokenCodec = new RefreshTokenCodec();
        service = new AuthSessionServiceImpl(
                new AuthenticationSessionProperties(Duration.ofDays(30), 5),
                authSessionRepository,
                userRepository,
                refreshTokenCodec,
                Clock.fixed(NOW, ZoneOffset.UTC));
        user = user(42L);

        when(authSessionRepository.save(any(AuthSession.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));
    }

    @Test
    void shouldCreateSessionWithHashedRefreshTokenAndDeviceMetadata() {
        when(userRepository.getReferenceById(42L)).thenReturn(user);
        when(authSessionRepository.findActiveSessionsByUserId(eq(42L), eq(NOW)))
                .thenReturn(List.of());

        CreatedAuthSession createdSession = service.createSession(
                42L,
                new LoginRequestMetadata("10.0.0.10", "JUnit"));

        ArgumentCaptor<AuthSession> sessionCaptor = ArgumentCaptor.forClass(AuthSession.class);
        verify(authSessionRepository).save(sessionCaptor.capture());
        AuthSession savedSession = sessionCaptor.getValue();

        assertThat(createdSession.sessionId()).isEqualTo(savedSession.getId());
        assertThat(createdSession.refreshToken()).startsWith("pp_rt_");
        assertThat(createdSession.refreshExpiresAt()).isEqualTo(NOW.plus(Duration.ofDays(30)));
        assertThat(savedSession.getRefreshTokenHash()).hasSize(64);
        assertThat(savedSession.getClientIp()).isEqualTo("10.0.0.10");
        assertThat(savedSession.getUserAgent()).isEqualTo("JUnit");
    }

    @Test
    void shouldRotateRefreshTokenForActiveSession() {
        UUID sessionId = UUID.fromString("9db45bc0-3625-47e5-a794-784f37f62734");
        RefreshTokenCodec.GeneratedRefreshToken originalToken = refreshTokenCodec.generate(sessionId);
        AuthSession session = AuthSession.create(
                sessionId,
                user,
                originalToken.secretHash(),
                NOW.plus(Duration.ofDays(30)),
                LoginRequestMetadata.unknown(),
                NOW);
        when(authSessionRepository.findByIdForUpdate(sessionId)).thenReturn(Optional.of(session));

        RotatedAuthSession rotatedSession = service.rotateRefreshToken(
                originalToken.token(),
                new LoginRequestMetadata("10.0.0.11", "JUnit-Rotated"));
        RefreshTokenCodec.ParsedRefreshToken parsedRotatedToken =
                refreshTokenCodec.parse(rotatedSession.refreshToken());

        assertThat(rotatedSession.sessionId()).isEqualTo(sessionId);
        assertThat(rotatedSession.userId()).isEqualTo(42L);
        assertThat(rotatedSession.refreshToken()).isNotEqualTo(originalToken.token());
        assertThat(refreshTokenCodec.matches(parsedRotatedToken.secret(), session.getRefreshTokenHash())).isTrue();
        assertThat(refreshTokenCodec.matches(
                refreshTokenCodec.parse(originalToken.token()).secret(),
                session.getRefreshTokenHash())).isFalse();
        assertThat(session.getClientIp()).isEqualTo("10.0.0.11");
    }

    @Test
    void shouldRevokeUserSessionsWhenRefreshTokenReuseIsDetected() {
        UUID sessionId = UUID.fromString("9db45bc0-3625-47e5-a794-784f37f62734");
        RefreshTokenCodec.GeneratedRefreshToken originalToken = refreshTokenCodec.generate(sessionId);
        RefreshTokenCodec.GeneratedRefreshToken replayedToken = refreshTokenCodec.generate(sessionId);
        AuthSession session = AuthSession.create(
                sessionId,
                user,
                originalToken.secretHash(),
                NOW.plus(Duration.ofDays(30)),
                LoginRequestMetadata.unknown(),
                NOW);
        when(authSessionRepository.findByIdForUpdate(sessionId)).thenReturn(Optional.of(session));

        assertThatThrownBy(() -> service.rotateRefreshToken(replayedToken.token(), LoginRequestMetadata.unknown()))
                .isInstanceOf(InvalidRefreshTokenException.class)
                .hasMessage("Invalid refresh token");

        assertThat(session.getRevocationReason())
                .isEqualTo(AuthSessionRevocationReason.REFRESH_TOKEN_REUSE_DETECTED);
        verify(authSessionRepository).revokeOtherActiveByUserId(
                42L,
                sessionId,
                NOW,
                AuthSessionRevocationReason.REFRESH_TOKEN_REUSE_DETECTED);
    }

    @Test
    void shouldRejectAccessTokenSessionAfterCredentialChange() {
        UUID sessionId = UUID.fromString("9db45bc0-3625-47e5-a794-784f37f62734");
        AuthSession session = AuthSession.create(
                sessionId,
                user,
                "a".repeat(64),
                NOW.plus(Duration.ofDays(30)),
                LoginRequestMetadata.unknown(),
                NOW);
        when(authSessionRepository.findByIdWithUser(sessionId)).thenReturn(Optional.of(session));

        assertThatCode(() -> service.validateAccessTokenSession(sessionId, 42L))
                .doesNotThrowAnyException();

        user.changePasswordHash("$new-hash", NOW.plusSeconds(1));

        assertThatThrownBy(() -> service.validateAccessTokenSession(sessionId, 42L))
                .isInstanceOf(BadCredentialsException.class)
                .hasMessage("Invalid authentication session");
    }

    private PortalUser user(Long userId) {
        PortalUser portalUser = PortalUser.register(
                "alice",
                "Alice",
                "alice@example.test",
                null,
                "$hash",
                null,
                null);
        portalUser.setId(userId);
        portalUser.changePasswordHash("$hash", NOW.minusSeconds(1));
        return portalUser;
    }
}

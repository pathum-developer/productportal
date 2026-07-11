package com.elvencode.productportal.auth.session.service.impl;

import com.elvencode.productportal.auth.protection.dto.LoginRequestMetadata;
import com.elvencode.productportal.auth.session.config.AuthenticationSessionProperties;
import com.elvencode.productportal.auth.session.dto.CreatedAuthSession;
import com.elvencode.productportal.auth.session.dto.RotatedAuthSession;
import com.elvencode.productportal.auth.session.entity.AuthSession;
import com.elvencode.productportal.auth.session.entity.AuthSessionRevocationReason;
import com.elvencode.productportal.auth.session.exception.InvalidRefreshTokenException;
import com.elvencode.productportal.auth.session.repository.AuthSessionRepository;
import com.elvencode.productportal.auth.session.service.AuthSessionService;
import com.elvencode.productportal.auth.session.token.RefreshTokenCodec;
import com.elvencode.productportal.user.entity.PortalUser;
import com.elvencode.productportal.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthSessionServiceImpl implements AuthSessionService {

    private final AuthenticationSessionProperties properties;
    private final AuthSessionRepository authSessionRepository;
    private final UserRepository userRepository;
    private final RefreshTokenCodec refreshTokenCodec;
    private final Clock clock;

    @Transactional
    @Override
    public CreatedAuthSession createSession(Long userId, LoginRequestMetadata metadata) {
        Instant now = clock.instant();
        PortalUser user = userRepository.getReferenceById(userId);
        UUID sessionId = UUID.randomUUID();
        RefreshTokenCodec.GeneratedRefreshToken refreshToken = refreshTokenCodec.generate(sessionId);

        AuthSession session = AuthSession.create(
                sessionId,
                user,
                refreshToken.secretHash(),
                now.plus(properties.refreshTokenTtl()),
                metadata,
                now);

        authSessionRepository.save(session);
        revokeSessionsBeyondLimit(userId, now);

        return new CreatedAuthSession(sessionId, refreshToken.token(), session.getRefreshExpiresAt());
    }

    @Transactional(noRollbackFor = InvalidRefreshTokenException.class)
    @Override
    public RotatedAuthSession rotateRefreshToken(String refreshToken, LoginRequestMetadata metadata) {
        RefreshTokenCodec.ParsedRefreshToken parsedRefreshToken = parseRefreshToken(refreshToken);
        AuthSession session = authSessionRepository.findByIdForUpdate(parsedRefreshToken.sessionId())
                .orElseThrow(this::invalidRefreshToken);
        Instant now = clock.instant();

        if (!session.isActive(now) || !session.isValidForCredentials(session.getUser().getCredentialsChangedAt())) {
            throw invalidRefreshToken();
        }

        if (!refreshTokenCodec.matches(parsedRefreshToken.secret(), session.getRefreshTokenHash())) {
            Long userId = session.getUser().getId();
            session.revoke(AuthSessionRevocationReason.REFRESH_TOKEN_REUSE_DETECTED, now);
            authSessionRepository.revokeOtherActiveByUserId(
                    userId,
                    session.getId(),
                    now,
                    AuthSessionRevocationReason.REFRESH_TOKEN_REUSE_DETECTED);
            throw invalidRefreshToken();
        }

        RefreshTokenCodec.GeneratedRefreshToken rotatedRefreshToken = refreshTokenCodec.generate(session.getId());
        session.rotateRefreshToken(
                rotatedRefreshToken.secretHash(),
                now.plus(properties.refreshTokenTtl()),
                metadata,
                now);

        return new RotatedAuthSession(
                session.getId(),
                session.getUser().getId(),
                rotatedRefreshToken.token(),
                session.getRefreshExpiresAt());
    }

    @Transactional
    @Override
    public void revokeRefreshToken(String refreshToken, AuthSessionRevocationReason reason) {
        RefreshTokenCodec.ParsedRefreshToken parsedRefreshToken;
        try {
            parsedRefreshToken = refreshTokenCodec.parse(refreshToken);
        } catch (BadCredentialsException exception) {
            return;
        }

        Instant now = clock.instant();
        authSessionRepository.findByIdForUpdate(parsedRefreshToken.sessionId())
                .filter(session -> refreshTokenCodec.matches(parsedRefreshToken.secret(), session.getRefreshTokenHash()))
                .ifPresent(session -> session.revoke(reason, now));
    }

    @Transactional(readOnly = true)
    @Override
    public void validateAccessTokenSession(UUID sessionId, Long userId) {
        AuthSession session = authSessionRepository.findByIdWithUser(sessionId)
                .orElseThrow(this::invalidAuthenticationSession);
        Instant now = clock.instant();

        if (!session.getUser().getId().equals(userId)
                || !session.isActive(now)
                || !session.isValidForCredentials(session.getUser().getCredentialsChangedAt())) {
            throw invalidAuthenticationSession();
        }
    }

    @Transactional
    @Override
    public int revokeUserSessions(Long userId, AuthSessionRevocationReason reason) {
        return authSessionRepository.revokeActiveByUserId(userId, clock.instant(), reason);
    }

    private void revokeSessionsBeyondLimit(Long userId, Instant now) {
        authSessionRepository.findActiveSessionsByUserId(userId, now)
                .stream()
                .skip(properties.maxActiveSessionsPerUser())
                .forEach(session -> session.revoke(AuthSessionRevocationReason.SESSION_LIMIT_EXCEEDED, now));
    }

    private RefreshTokenCodec.ParsedRefreshToken parseRefreshToken(String refreshToken) {
        try {
            return refreshTokenCodec.parse(refreshToken);
        } catch (BadCredentialsException exception) {
            throw invalidRefreshToken();
        }
    }

    private InvalidRefreshTokenException invalidRefreshToken() {
        return new InvalidRefreshTokenException();
    }

    private BadCredentialsException invalidAuthenticationSession() {
        return new BadCredentialsException("Invalid authentication session");
    }
}

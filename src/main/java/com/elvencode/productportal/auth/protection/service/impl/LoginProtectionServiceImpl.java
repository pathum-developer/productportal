package com.elvencode.productportal.auth.protection.service.impl;

import com.elvencode.productportal.auth.config.AuthenticationProtectionProperties;
import com.elvencode.productportal.auth.protection.dto.LoginRequestMetadata;
import com.elvencode.productportal.auth.protection.entity.LoginAttemptAudit;
import com.elvencode.productportal.auth.protection.entity.LoginAttemptOutcome;
import com.elvencode.productportal.auth.protection.entity.LoginThrottleScope;
import com.elvencode.productportal.auth.protection.entity.LoginThrottleState;
import com.elvencode.productportal.auth.protection.exception.LoginBlockedException;
import com.elvencode.productportal.auth.protection.repository.LoginAttemptAuditRepository;
import com.elvencode.productportal.auth.protection.repository.LoginThrottleStateRepository;
import com.elvencode.productportal.auth.protection.service.LoginProtectionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.Instant;
import java.util.Locale;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class LoginProtectionServiceImpl implements LoginProtectionService {

    private static final String UNKNOWN_USERNAME = "unknown";

    private final AuthenticationProtectionProperties properties;
    private final LoginThrottleStateRepository throttleStateRepository;
    private final LoginAttemptAuditRepository auditRepository;

    @Transactional(readOnly = true)
    @Override
    public void assertLoginAllowed(String username, LoginRequestMetadata metadata) {
        if (!Boolean.TRUE.equals(properties.enabled())) {
            return;
        }

        LoginRequestMetadata safeMetadata = safeMetadata(metadata);
        Instant now = Instant.now();

        Optional<LoginBlockedException> ipBlock = findActiveBlock(
                LoginThrottleScope.IP_ADDRESS,
                safeMetadata.clientIp(),
                LoginAttemptOutcome.IP_THROTTLED,
                now);
        if (ipBlock.isPresent()) {
            throw ipBlock.get();
        }

        Optional<LoginBlockedException> usernameBlock = findActiveBlock(
                LoginThrottleScope.USERNAME,
                normalizeUsername(username),
                LoginAttemptOutcome.USERNAME_LOCKED,
                now);
        if (usernameBlock.isPresent()) {
            throw usernameBlock.get();
        }
    }

    @Transactional
    @Override
    public void recordBadCredentials(String username, Long userId, LoginRequestMetadata metadata) {
        LoginRequestMetadata safeMetadata = safeMetadata(metadata);
        String normalizedUsername = normalizeUsername(username);
        Instant now = Instant.now();
        Instant lockedUntil = null;

        if (Boolean.TRUE.equals(properties.enabled())) {
            LoginThrottleState usernameState = stateForUpdate(LoginThrottleScope.USERNAME, normalizedUsername);
            usernameState.recordFailure(
                    now,
                    properties.usernameMaxFailedAttempts(),
                    properties.usernameFailureWindow(),
                    properties.usernameLockDuration());
            lockedUntil = laterOf(lockedUntil, usernameState.getLockedUntil());

            LoginThrottleState ipState = stateForUpdate(LoginThrottleScope.IP_ADDRESS, safeMetadata.clientIp());
            ipState.recordFailure(
                    now,
                    properties.ipMaxFailedAttempts(),
                    properties.ipFailureWindow(),
                    properties.ipLockDuration());
            lockedUntil = laterOf(lockedUntil, ipState.getLockedUntil());
        }

        audit(normalizedUsername, userId, LoginAttemptOutcome.BAD_CREDENTIALS, safeMetadata, lockedUntil, now);
    }

    @Transactional
    @Override
    public void recordSuccessfulLogin(String username, Long userId, LoginRequestMetadata metadata) {
        LoginRequestMetadata safeMetadata = safeMetadata(metadata);
        String normalizedUsername = normalizeUsername(username);
        Instant now = Instant.now();

        if (Boolean.TRUE.equals(properties.enabled())) {
            throttleStateRepository
                    .findByScopeAndIdentifierForUpdate(LoginThrottleScope.USERNAME, normalizedUsername)
                    .ifPresent(state -> state.recordSuccessfulUsernameLogin(now));
            throttleStateRepository
                    .findByScopeAndIdentifierForUpdate(LoginThrottleScope.IP_ADDRESS, safeMetadata.clientIp())
                    .ifPresent(state -> state.recordSuccessfulIpLogin(now));
        }

        audit(normalizedUsername, userId, LoginAttemptOutcome.SUCCESS, safeMetadata, null, now);
    }

    @Transactional
    @Override
    public void recordSecurityFailure(
            String username,
            Long userId,
            LoginAttemptOutcome outcome,
            LoginRequestMetadata metadata) {
        audit(normalizeUsername(username), userId, outcome, safeMetadata(metadata), null, Instant.now());
    }

    @Transactional
    @Override
    public void recordBlockedAttempt(
            String username,
            LoginBlockedException exception,
            LoginRequestMetadata metadata) {
        audit(
                normalizeUsername(username),
                null,
                exception.outcome(),
                safeMetadata(metadata),
                exception.retryAfter(),
                Instant.now());
    }

    private Optional<LoginBlockedException> findActiveBlock(
            LoginThrottleScope scope,
            String identifier,
            LoginAttemptOutcome outcome,
            Instant now) {
        return throttleStateRepository.findByScopeAndIdentifier(scope, identifier)
                .filter(state -> state.isLocked(now))
                .map(state -> new LoginBlockedException(outcome, state.getLockedUntil()));
    }

    private LoginThrottleState stateForUpdate(LoginThrottleScope scope, String identifier) {
        throttleStateRepository.insertIfAbsent(scope.name(), identifier);

        return throttleStateRepository.findByScopeAndIdentifierForUpdate(scope, identifier)
                .orElseThrow(() -> new IllegalStateException(
                        "Login throttle state could not be initialized for scope " + scope));
    }

    private void audit(
            String username,
            Long userId,
            LoginAttemptOutcome outcome,
            LoginRequestMetadata metadata,
            Instant lockedUntil,
            Instant occurredAt) {
        auditRepository.save(LoginAttemptAudit.create(
                username,
                userId,
                outcome,
                metadata.clientIp(),
                metadata.userAgent(),
                lockedUntil,
                occurredAt));
    }

    private LoginRequestMetadata safeMetadata(LoginRequestMetadata metadata) {
        return metadata == null ? LoginRequestMetadata.unknown() : metadata;
    }

    private String normalizeUsername(String username) {
        if (!StringUtils.hasText(username)) {
            return UNKNOWN_USERNAME;
        }

        return username.trim().toLowerCase(Locale.ROOT);
    }

    private Instant laterOf(Instant first, Instant second) {
        if (first == null) {
            return second;
        }
        if (second == null) {
            return first;
        }
        return first.isAfter(second) ? first : second;
    }
}

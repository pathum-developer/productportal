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
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InOrder;

import java.time.Duration;
import java.time.Instant;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class LoginProtectionServiceImplTest {

    private LoginThrottleStateRepository throttleStateRepository;
    private LoginAttemptAuditRepository auditRepository;
    private LoginProtectionServiceImpl service;

    @BeforeEach
    void setUp() {
        throttleStateRepository = mock(LoginThrottleStateRepository.class);
        auditRepository = mock(LoginAttemptAuditRepository.class);
        service = new LoginProtectionServiceImpl(
                new AuthenticationProtectionProperties(
                        true,
                        2,
                        Duration.ofMinutes(15),
                        Duration.ofMinutes(10),
                        3,
                        Duration.ofMinutes(15),
                        Duration.ofMinutes(10),
                        false),
                throttleStateRepository,
                auditRepository);

        when(auditRepository.save(any(LoginAttemptAudit.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));
    }

    @Test
    void shouldRecordBadCredentialsAgainstUsernameAndIpState() {
        LoginThrottleState usernameState = LoginThrottleState.create(LoginThrottleScope.USERNAME, "alice");
        LoginThrottleState ipState = LoginThrottleState.create(LoginThrottleScope.IP_ADDRESS, "10.0.0.10");

        when(throttleStateRepository.findByScopeAndIdentifierForUpdate(LoginThrottleScope.USERNAME, "alice"))
                .thenReturn(Optional.of(usernameState));
        when(throttleStateRepository.findByScopeAndIdentifierForUpdate(LoginThrottleScope.IP_ADDRESS, "10.0.0.10"))
                .thenReturn(Optional.of(ipState));

        service.recordBadCredentials(
                "Alice",
                42L,
                new LoginRequestMetadata("10.0.0.10", "JUnit"));

        assertThat(usernameState.getFailedAttemptCount()).isEqualTo(1);
        assertThat(ipState.getFailedAttemptCount()).isEqualTo(1);
        verify(throttleStateRepository).insertIfAbsent(LoginThrottleScope.USERNAME.name(), "alice");
        verify(throttleStateRepository).insertIfAbsent(LoginThrottleScope.IP_ADDRESS.name(), "10.0.0.10");
        verify(throttleStateRepository, never()).save(any(LoginThrottleState.class));
        verify(auditRepository).save(any(LoginAttemptAudit.class));
    }

    @Test
    void shouldInitializeThrottleStateBeforeAcquiringUpdateLock() {
        LoginThrottleState usernameState = LoginThrottleState.create(LoginThrottleScope.USERNAME, "alice");
        LoginThrottleState ipState = LoginThrottleState.create(LoginThrottleScope.IP_ADDRESS, "10.0.0.10");

        when(throttleStateRepository.findByScopeAndIdentifierForUpdate(LoginThrottleScope.USERNAME, "alice"))
                .thenReturn(Optional.of(usernameState));
        when(throttleStateRepository.findByScopeAndIdentifierForUpdate(LoginThrottleScope.IP_ADDRESS, "10.0.0.10"))
                .thenReturn(Optional.of(ipState));

        service.recordBadCredentials(
                "Alice",
                42L,
                new LoginRequestMetadata("10.0.0.10", "JUnit"));

        InOrder inOrder = inOrder(throttleStateRepository);
        inOrder.verify(throttleStateRepository).insertIfAbsent(LoginThrottleScope.USERNAME.name(), "alice");
        inOrder.verify(throttleStateRepository)
                .findByScopeAndIdentifierForUpdate(LoginThrottleScope.USERNAME, "alice");
        inOrder.verify(throttleStateRepository).insertIfAbsent(LoginThrottleScope.IP_ADDRESS.name(), "10.0.0.10");
        inOrder.verify(throttleStateRepository)
                .findByScopeAndIdentifierForUpdate(LoginThrottleScope.IP_ADDRESS, "10.0.0.10");
    }

    @Test
    void shouldRejectActiveUsernameLock() {
        LoginThrottleState usernameState = LoginThrottleState.create(LoginThrottleScope.USERNAME, "alice");
        Instant now = Instant.now();
        usernameState.recordFailure(now, 1, Duration.ofMinutes(15), Duration.ofMinutes(10));

        when(throttleStateRepository.findByScopeAndIdentifier(LoginThrottleScope.IP_ADDRESS, "10.0.0.10"))
                .thenReturn(Optional.empty());
        when(throttleStateRepository.findByScopeAndIdentifier(LoginThrottleScope.USERNAME, "alice"))
                .thenReturn(Optional.of(usernameState));

        assertThatThrownBy(() -> service.assertLoginAllowed(
                "Alice",
                new LoginRequestMetadata("10.0.0.10", "JUnit")))
                .isInstanceOf(LoginBlockedException.class)
                .satisfies(exception -> assertThat(((LoginBlockedException) exception).outcome())
                        .isEqualTo(LoginAttemptOutcome.USERNAME_LOCKED));
    }

    @Test
    void shouldAuditBlockedAttempt() {
        LoginBlockedException exception = new LoginBlockedException(
                LoginAttemptOutcome.IP_THROTTLED,
                Instant.now().plus(Duration.ofMinutes(10)));

        service.recordBlockedAttempt(
                "Alice",
                exception,
                new LoginRequestMetadata("10.0.0.10", "JUnit"));

        verify(auditRepository).save(any(LoginAttemptAudit.class));
    }
}

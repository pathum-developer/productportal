package com.elvencode.productportal.auth.protection.entity;

import org.junit.jupiter.api.Test;

import java.time.Duration;
import java.time.Instant;

import static org.assertj.core.api.Assertions.assertThat;

class LoginThrottleStateTest {

    @Test
    void shouldLockAfterMaximumFailuresWithinWindow() {
        LoginThrottleState state = LoginThrottleState.create(LoginThrottleScope.USERNAME, "alice");
        Instant firstAttempt = Instant.parse("2026-07-11T10:00:00Z");

        state.recordFailure(firstAttempt, 3, Duration.ofMinutes(15), Duration.ofMinutes(10));
        state.recordFailure(firstAttempt.plusSeconds(30), 3, Duration.ofMinutes(15), Duration.ofMinutes(10));

        assertThat(state.isLocked(firstAttempt.plusSeconds(30))).isFalse();

        state.recordFailure(firstAttempt.plusSeconds(60), 3, Duration.ofMinutes(15), Duration.ofMinutes(10));

        assertThat(state.getFailedAttemptCount()).isEqualTo(3);
        assertThat(state.getLockedUntil()).isEqualTo(firstAttempt.plusSeconds(60).plus(Duration.ofMinutes(10)));
        assertThat(state.isLocked(firstAttempt.plusSeconds(61))).isTrue();
    }

    @Test
    void shouldResetFailureCounterWhenFailureWindowExpires() {
        LoginThrottleState state = LoginThrottleState.create(LoginThrottleScope.USERNAME, "alice");
        Instant firstAttempt = Instant.parse("2026-07-11T10:00:00Z");

        state.recordFailure(firstAttempt, 3, Duration.ofMinutes(15), Duration.ofMinutes(10));
        state.recordFailure(firstAttempt.plus(Duration.ofMinutes(16)), 3, Duration.ofMinutes(15), Duration.ofMinutes(10));

        assertThat(state.getFailedAttemptCount()).isEqualTo(1);
        assertThat(state.getWindowStartedAt()).isEqualTo(firstAttempt.plus(Duration.ofMinutes(16)));
        assertThat(state.getLockedUntil()).isNull();
    }

    @Test
    void shouldClearUsernameFailuresAfterSuccessfulLogin() {
        LoginThrottleState state = LoginThrottleState.create(LoginThrottleScope.USERNAME, "alice");
        Instant firstAttempt = Instant.parse("2026-07-11T10:00:00Z");
        Instant successAt = firstAttempt.plusSeconds(90);

        state.recordFailure(firstAttempt, 3, Duration.ofMinutes(15), Duration.ofMinutes(10));
        state.recordSuccessfulUsernameLogin(successAt);

        assertThat(state.getFailedAttemptCount()).isZero();
        assertThat(state.getWindowStartedAt()).isNull();
        assertThat(state.getLockedUntil()).isNull();
        assertThat(state.getLastSuccessfulAt()).isEqualTo(successAt);
    }
}

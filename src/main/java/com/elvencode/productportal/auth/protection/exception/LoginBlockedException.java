package com.elvencode.productportal.auth.protection.exception;

import com.elvencode.productportal.auth.protection.entity.LoginAttemptOutcome;
import org.springframework.security.core.AuthenticationException;

import java.time.Duration;
import java.time.Instant;

public class LoginBlockedException extends AuthenticationException {

    private final LoginAttemptOutcome outcome;
    private final Instant retryAfter;

    public LoginBlockedException(LoginAttemptOutcome outcome, Instant retryAfter) {
        super("Too many failed login attempts");
        this.outcome = outcome;
        this.retryAfter = retryAfter;
    }

    public LoginAttemptOutcome outcome() {
        return outcome;
    }

    public Instant retryAfter() {
        return retryAfter;
    }

    public long retryAfterSeconds(Instant now) {
        if (retryAfter == null || !retryAfter.isAfter(now)) {
            return 0;
        }

        return Math.max(1, Duration.between(now, retryAfter).toSeconds());
    }
}

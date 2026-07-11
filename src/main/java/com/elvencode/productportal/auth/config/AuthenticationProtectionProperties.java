package com.elvencode.productportal.auth.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

import java.time.Duration;

@ConfigurationProperties(prefix = "auth.login-protection")
public record AuthenticationProtectionProperties(
        Boolean enabled,
        Integer usernameMaxFailedAttempts,
        Duration usernameFailureWindow,
        Duration usernameLockDuration,
        Integer ipMaxFailedAttempts,
        Duration ipFailureWindow,
        Duration ipLockDuration,
        Boolean trustForwardedHeaders
) {

    private static final int DEFAULT_USERNAME_MAX_FAILED_ATTEMPTS = 5;
    private static final Duration DEFAULT_USERNAME_FAILURE_WINDOW = Duration.ofMinutes(15);
    private static final Duration DEFAULT_USERNAME_LOCK_DURATION = Duration.ofMinutes(15);
    private static final int DEFAULT_IP_MAX_FAILED_ATTEMPTS = 25;
    private static final Duration DEFAULT_IP_FAILURE_WINDOW = Duration.ofMinutes(15);
    private static final Duration DEFAULT_IP_LOCK_DURATION = Duration.ofMinutes(15);

    public AuthenticationProtectionProperties {
        enabled = enabled == null || enabled;
        usernameMaxFailedAttempts = defaultIfNull(
                usernameMaxFailedAttempts,
                DEFAULT_USERNAME_MAX_FAILED_ATTEMPTS);
        usernameFailureWindow = defaultIfNull(
                usernameFailureWindow,
                DEFAULT_USERNAME_FAILURE_WINDOW);
        usernameLockDuration = defaultIfNull(
                usernameLockDuration,
                DEFAULT_USERNAME_LOCK_DURATION);
        ipMaxFailedAttempts = defaultIfNull(
                ipMaxFailedAttempts,
                DEFAULT_IP_MAX_FAILED_ATTEMPTS);
        ipFailureWindow = defaultIfNull(
                ipFailureWindow,
                DEFAULT_IP_FAILURE_WINDOW);
        ipLockDuration = defaultIfNull(
                ipLockDuration,
                DEFAULT_IP_LOCK_DURATION);
        trustForwardedHeaders = trustForwardedHeaders != null && trustForwardedHeaders;

        requirePositive(usernameMaxFailedAttempts, "username-max-failed-attempts");
        requirePositive(ipMaxFailedAttempts, "ip-max-failed-attempts");
        requirePositive(usernameFailureWindow, "username-failure-window");
        requirePositive(usernameLockDuration, "username-lock-duration");
        requirePositive(ipFailureWindow, "ip-failure-window");
        requirePositive(ipLockDuration, "ip-lock-duration");
    }

    private static int defaultIfNull(Integer value, int defaultValue) {
        return value == null ? defaultValue : value;
    }

    private static Duration defaultIfNull(Duration value, Duration defaultValue) {
        return value == null ? defaultValue : value;
    }

    private static void requirePositive(int value, String propertyName) {
        if (value <= 0) {
            throw new IllegalArgumentException("auth.login-protection." + propertyName + " must be positive");
        }
    }

    private static void requirePositive(Duration value, String propertyName) {
        if (value.isZero() || value.isNegative()) {
            throw new IllegalArgumentException("auth.login-protection." + propertyName + " must be positive");
        }
    }
}

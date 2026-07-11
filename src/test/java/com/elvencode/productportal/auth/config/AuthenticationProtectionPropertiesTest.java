package com.elvencode.productportal.auth.config;

import org.junit.jupiter.api.Test;

import java.time.Duration;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class AuthenticationProtectionPropertiesTest {

    @Test
    void shouldApplySecureDefaults() {
        AuthenticationProtectionProperties properties = new AuthenticationProtectionProperties(
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null);

        assertThat(properties.enabled()).isTrue();
        assertThat(properties.usernameMaxFailedAttempts()).isEqualTo(5);
        assertThat(properties.usernameFailureWindow()).isEqualTo(Duration.ofMinutes(15));
        assertThat(properties.usernameLockDuration()).isEqualTo(Duration.ofMinutes(15));
        assertThat(properties.ipMaxFailedAttempts()).isEqualTo(25);
        assertThat(properties.ipFailureWindow()).isEqualTo(Duration.ofMinutes(15));
        assertThat(properties.ipLockDuration()).isEqualTo(Duration.ofMinutes(15));
        assertThat(properties.trustForwardedHeaders()).isFalse();
    }

    @Test
    void shouldRejectInvalidThresholds() {
        assertThatThrownBy(() -> new AuthenticationProtectionProperties(
                true,
                0,
                Duration.ofMinutes(15),
                Duration.ofMinutes(15),
                25,
                Duration.ofMinutes(15),
                Duration.ofMinutes(15),
                false))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("username-max-failed-attempts");
    }
}

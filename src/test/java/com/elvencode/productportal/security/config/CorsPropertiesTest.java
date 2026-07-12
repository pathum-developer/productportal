package com.elvencode.productportal.security.config;

import org.junit.jupiter.api.Test;

import java.time.Duration;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class CorsPropertiesTest {

    @Test
    void shouldApplyRestrictiveDefaultsForConfiguredOrigin() {
        CorsProperties properties = new CorsProperties(
                List.of(" https://portal.example.com "),
                null,
                null,
                null,
                null,
                null,
                null);

        assertThat(properties.allowedOrigins()).containsExactly("https://portal.example.com");
        assertThat(properties.allowedOriginPatterns()).isEmpty();
        assertThat(properties.allowedMethods()).containsExactly(
                "GET",
                "POST",
                "PUT",
                "PATCH",
                "DELETE",
                "OPTIONS");
        assertThat(properties.allowedHeaders()).containsExactly(
                "Authorization",
                "Content-Type",
                "Accept",
                "Origin",
                "X-Requested-With",
                "X-Correlation-ID");
        assertThat(properties.exposedHeaders()).containsExactly("X-Correlation-ID");
        assertThat(properties.allowCredentials()).isTrue();
        assertThat(properties.maxAge()).isEqualTo(Duration.ofHours(1));
    }

    @Test
    void shouldRequireAtLeastOneOriginPolicy() {
        assertThatThrownBy(() -> new CorsProperties(
                null,
                null,
                List.of("GET"),
                List.of("Authorization"),
                List.of("X-Correlation-ID"),
                true,
                Duration.ofHours(1)))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("allowed-origins");
    }

    @Test
    void shouldRejectWildcardMethods() {
        assertThatThrownBy(() -> new CorsProperties(
                List.of("https://portal.example.com"),
                null,
                List.of("*"),
                List.of("Authorization"),
                List.of("X-Correlation-ID"),
                true,
                Duration.ofHours(1)))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("allowed-methods");
    }

    @Test
    void shouldRejectWildcardHeaders() {
        assertThatThrownBy(() -> new CorsProperties(
                List.of("https://portal.example.com"),
                null,
                List.of("GET"),
                List.of("*"),
                List.of("X-Correlation-ID"),
                true,
                Duration.ofHours(1)))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("allowed-headers");
    }

    @Test
    void shouldRejectWildcardOriginWhenCredentialsAreAllowed() {
        assertThatThrownBy(() -> new CorsProperties(
                List.of("*"),
                null,
                List.of("GET"),
                List.of("Authorization"),
                List.of("X-Correlation-ID"),
                true,
                Duration.ofHours(1)))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("wildcard origins");
    }
}

package com.elvencode.productportal.security.config;

import org.junit.jupiter.api.Test;
import org.springframework.boot.context.properties.ConfigurationProperties;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class SecurityPathPolicyTest {

    @Test
    void policyShouldExposeAuditableCodeDefinedPathGroups() {
        assertThat(SecurityPathPolicy.permitAll())
                .contains(
                        "/api/auth/login",
                        "/api/auth/refresh",
                        "/api/auth/logout",
                        "/api/users/register",
                        "/api/swagger-ui/**",
                        "/v3/api-docs/**");
        assertThat(SecurityPathPolicy.authenticated()).containsExactly("/api/**");
    }

    @Test
    void jwtBypassPathsShouldExactlyMatchPublicPaths() {
        assertThat(SecurityPathPolicy.jwtBypass())
                .containsExactlyElementsOf(SecurityPathPolicy.permitAll());
    }

    @Test
    void policyPathsShouldBeImmutable() {
        assertThatThrownBy(() -> SecurityPathPolicy.permitAll().add("/api/**"))
                .isInstanceOf(UnsupportedOperationException.class);
    }

    @Test
    void policyShouldNotBeConfigurationPropertiesBound() {
        assertThat(SecurityPathPolicy.class.isAnnotationPresent(ConfigurationProperties.class)).isFalse();
    }
}

package com.elvencode.productportal.security.config;

import org.junit.jupiter.api.Test;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.test.context.runner.ApplicationContextRunner;
import org.springframework.context.annotation.Configuration;

import static org.assertj.core.api.Assertions.assertThat;

class JwtPropertiesTest {

    private static final String STRONG_SECRET = "a".repeat(64);

    private final ApplicationContextRunner contextRunner = new ApplicationContextRunner()
            .withUserConfiguration(TestConfiguration.class);

    @Test
    void shouldFailStartupWhenJwtSecretIsMissing() {
        contextRunner.run(context -> assertThat(context).hasFailed());
    }

    @Test
    void shouldFailStartupWhenJwtSecretIsWeak() {
        contextRunner
                .withPropertyValues("jwt.secret=short-secret")
                .run(context -> assertThat(context).hasFailed());
    }

    @Test
    void shouldBindJwtSecretWhenItIsStrongEnough() {
        contextRunner
                .withPropertyValues("jwt.secret=" + STRONG_SECRET)
                .run(context -> {
                    assertThat(context).hasNotFailed();
                    JwtProperties jwtProperties = context.getBean(JwtProperties.class);

                    assertThat(jwtProperties.secret()).isEqualTo(STRONG_SECRET);
                    assertThat(jwtProperties.signingKey()).isNotNull();
                });
    }

    @Configuration
    @EnableConfigurationProperties(JwtProperties.class)
    static class TestConfiguration {
    }
}

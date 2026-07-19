# Spring Boot Configuration Properties Guide

## Purpose

Use this guide when you need to move application settings out of hardcoded Java values and into type-safe Spring Boot configuration classes.

This pattern is useful for settings such as:

- JWT settings
- CORS settings
- security path rules
- authentication session limits
- feature flags
- external integration settings

The main annotations are:

```java
@ConfigurationProperties
@EnableConfigurationProperties
```

For larger applications, `@ConfigurationPropertiesScan` is usually a cleaner project-level alternative.

---

## Core idea

`@ConfigurationProperties` defines a typed Java object that can receive external configuration.

`@EnableConfigurationProperties` tells Spring Boot to create and bind that object as a Spring bean.

Think about it this way:

```text
@ConfigurationProperties
= this class can be bound from application.properties / YAML / env vars

@EnableConfigurationProperties
= register this configuration class as a Spring bean
```

---

## Example 1: Using `@ConfigurationProperties` with a Java record

Create a dedicated config class:

```java
package com.elvencode.productportal.payment.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.util.StringUtils;

import java.time.Duration;

@ConfigurationProperties(prefix = "payment.gateway")
public record PaymentGatewayProperties(
        String baseUrl,
        String apiKey,
        Duration timeout,
        boolean enabled
) {

    private static final Duration DEFAULT_TIMEOUT = Duration.ofSeconds(5);

    public PaymentGatewayProperties {
        if (!StringUtils.hasText(baseUrl)) {
            throw new IllegalArgumentException("payment.gateway.base-url must be configured");
        }

        if (!StringUtils.hasText(apiKey)) {
            throw new IllegalArgumentException("payment.gateway.api-key must be configured");
        }

        baseUrl = baseUrl.trim();
        apiKey = apiKey.trim();
        timeout = timeout == null ? DEFAULT_TIMEOUT : timeout;

        if (timeout.isZero() || timeout.isNegative()) {
            throw new IllegalArgumentException("payment.gateway.timeout must be positive");
        }
    }
}
```

What this gives you:

- immutable configuration object
- constructor-based binding
- startup-time validation
- clear defaults
- no scattered `@Value` fields

Records are a good fit because configuration should normally be immutable after startup.

---

## Example 2: Configure values in `application.properties`

```properties
payment.gateway.base-url=https://payments.example.com
payment.gateway.api-key=${PAYMENT_GATEWAY_API_KEY}
payment.gateway.timeout=5s
payment.gateway.enabled=true
```

Spring Boot relaxed binding maps kebab-case properties to camelCase record components:

```text
base-url -> baseUrl
api-key  -> apiKey
timeout  -> timeout
enabled  -> enabled
```

Environment variable equivalents:

```text
PAYMENT_GATEWAY_BASE_URL
PAYMENT_GATEWAY_API_KEY
PAYMENT_GATEWAY_TIMEOUT
PAYMENT_GATEWAY_ENABLED
```

---

## Example 3: Register with `@EnableConfigurationProperties`

Use this when you want explicit registration from a configuration class.

```java
package com.elvencode.productportal.payment.config;

import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableConfigurationProperties(PaymentGatewayProperties.class)
public class PaymentGatewayConfig {
}
```

You can also register several config classes:

```java
@Configuration
@EnableConfigurationProperties({
        PaymentGatewayProperties.class,
        PaymentRetryProperties.class,
        PaymentAuditProperties.class
})
public class PaymentGatewayConfig {
}
```

After this, Spring can inject the properties object:

```java
package com.elvencode.productportal.payment.service;

import com.elvencode.productportal.payment.config.PaymentGatewayProperties;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class PaymentGatewayClient {

    private final PaymentGatewayProperties paymentGatewayProperties;

    public void callGateway() {
        if (!paymentGatewayProperties.enabled()) {
            return;
        }

        String baseUrl = paymentGatewayProperties.baseUrl();
        Duration timeout = paymentGatewayProperties.timeout();

        // use baseUrl and timeout to call external payment gateway
    }
}
```

Execution flow:

```text
Application starts
 -> Spring sees @EnableConfigurationProperties(PaymentGatewayProperties.class)
 -> Spring reads payment.gateway.* properties
 -> Spring creates PaymentGatewayProperties
 -> compact constructor validates/defaults values
 -> PaymentGatewayClient receives it through constructor injection
```

---

## Example 4: Project-level scanning with `@ConfigurationPropertiesScan`

For normal application code, this is often cleaner than registering every class manually.

Add it to the main application class:

```java
package com.elvencode.productportal;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

@SpringBootApplication
@ConfigurationPropertiesScan
public class ProductportalApplication {

    public static void main(String[] args) {
        SpringApplication.run(ProductportalApplication.class, args);
    }
}
```

Then this class is automatically discovered if it is under the application root package:

```text
com.elvencode.productportal
```

Example discovered package:

```text
com.elvencode.productportal.payment.config
```

With scanning enabled, this is enough:

```java
@ConfigurationProperties(prefix = "payment.gateway")
public record PaymentGatewayProperties(...) {
}
```

You do not need:

```java
@EnableConfigurationProperties(PaymentGatewayProperties.class)
```

---

## When to use each approach

| Approach | Best use case |
|---|---|
| `@EnableConfigurationProperties(SomeProperties.class)` | Explicitly register a small number of config classes from a related configuration class |
| `@ConfigurationPropertiesScan` | Application-level discovery of many config classes |
| `@Value` | Simple one-off values only; avoid for grouped enterprise config |

Current project standard:

```text
Use @ConfigurationPropertiesScan on ProductportalApplication
```

Reason:

- the project already has several config property classes
- the main app class is in the root package
- scanning reduces future registration mistakes
- config classes remain strongly typed and testable

---

## Current project example

Current project class:

```java
@ConfigurationProperties(prefix = "security.paths")
public record SecurityPathProperties(
        List<String> permitAll,
        List<String> jwtBypass,
        List<String> authenticated
) {
    // defaults and validation
}
```

Example config:

```properties
security.paths.permit-all=/api/auth/login,/api/auth/refresh,/api/auth/logout
security.paths.jwt-bypass=/api/auth/login,/api/auth/refresh,/api/auth/logout
security.paths.authenticated=/api/**
```

Registered once at the application root:

```java
@SpringBootApplication
@ConfigurationPropertiesScan
@EnableJpaAuditing(auditorAwareRef = "auditorAwareImpl", modifyOnCreate = false)
public class ProductportalApplication {
    public static void main(String[] args) {
        SpringApplication.run(ProductportalApplication.class, args);
    }
}
```

Used by security config through constructor injection:

```java
@RequiredArgsConstructor
public class ProductPortalSecurityConfig {

    private final SecurityPathProperties securityPathProperties;

    @Bean
    SecurityFilterChain customSecurityFilterChain(HttpSecurity http) {
        return http.authorizeHttpRequests(requests -> {
                    securityPathProperties.permitAll()
                            .forEach(path -> requests.requestMatchers(path).permitAll());
                    securityPathProperties.authenticated()
                            .forEach(path -> requests.requestMatchers(path).authenticated());
                    requests.anyRequest().denyAll();
                })
                .addFilterBefore(
                        new JwtTokenValidatorFilter(
                                securityPathProperties.jwtBypass(),
                                jwtUtil,
                                currentUserAccessService,
                                authSessionService,
                                errorResponseWriter),
                        UsernamePasswordAuthenticationFilter.class)
                .build();
    }
}
```

Important distinction:

```text
permitAll
= Spring Security authorization rule

jwtBypass
= request skips JwtTokenValidatorFilter

authenticated
= request must be authenticated
```

Do not treat `permitAll` and `jwtBypass` as automatically equivalent. They are separate security decisions.

---

## Testing template

Test defaults:

```java
class PaymentGatewayPropertiesTest {

    @Test
    void shouldApplyDefaultTimeout() {
        PaymentGatewayProperties properties = new PaymentGatewayProperties(
                "https://payments.example.com",
                "secret-key",
                null,
                true);

        assertThat(properties.timeout()).isEqualTo(Duration.ofSeconds(5));
    }
}
```

Test validation:

```java
@Test
void shouldRejectMissingBaseUrl() {
    assertThatThrownBy(() -> new PaymentGatewayProperties(
            " ",
            "secret-key",
            Duration.ofSeconds(5),
            true))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("payment.gateway.base-url");
}
```

For security-sensitive config, always test:

- defaults
- invalid values
- empty values
- duplicate values
- unsafe combinations

---

## Enterprise checklist

When adding a new configuration properties class:

1. Use a dedicated package:

   ```text
   feature/config
   security/config
   integration/payment/config
   ```

2. Use a clear prefix:

   ```java
   @ConfigurationProperties(prefix = "payment.gateway")
   ```

3. Prefer Java records for immutable config.

4. Use kebab-case property names:

   ```properties
   payment.gateway.base-url=...
   ```

5. Add defaults only when safe.

6. Validate required values at startup.

7. Do not inject services, repositories, or clients into config properties classes.

8. Add unit tests for defaults and validation.

9. Avoid secrets as hardcoded defaults.

10. Use environment variables for secrets:

    ```properties
    payment.gateway.api-key=${PAYMENT_GATEWAY_API_KEY}
    ```

---

## Common mistakes

Avoid this:

```java
@Value("${payment.gateway.base-url}")
private String baseUrl;

@Value("${payment.gateway.api-key}")
private String apiKey;

@Value("${payment.gateway.timeout}")
private Duration timeout;
```

Why it is weaker:

- no grouped config object
- harder to validate consistently
- harder to test
- easy to scatter across services

Prefer this:

```java
private final PaymentGatewayProperties paymentGatewayProperties;
```

Also avoid adding `@Component` to `@ConfigurationProperties` classes when using `@ConfigurationPropertiesScan`. Let Spring Boot configuration property infrastructure register them.

---

## Summary

Use this pattern:

```java
@ConfigurationProperties(prefix = "some.feature")
public record SomeFeatureProperties(...) {
    // defaults and validation
}
```

Register it with either:

```java
@EnableConfigurationProperties(SomeFeatureProperties.class)
```

or project-wide:

```java
@ConfigurationPropertiesScan
```

For this project, use `@ConfigurationPropertiesScan` at the application root because the codebase has multiple configuration property classes.

References:

- [Spring Boot external configuration and type-safe configuration properties](https://github.com/spring-projects/spring-boot/blob/v4.1.0/documentation/spring-boot-docs/src/docs/antora/modules/reference/pages/features/external-config.adoc)
- [Spring Boot `@ConfigurationProperties` annotation source](https://github.com/spring-projects/spring-boot/blob/main/core/spring-boot/src/main/java/org/springframework/boot/context/properties/ConfigurationProperties.java)
- [Spring Boot `@ConfigurationPropertiesScan` annotation source](https://github.com/spring-projects/spring-boot/blob/main/core/spring-boot/src/main/java/org/springframework/boot/context/properties/ConfigurationPropertiesScan.java)

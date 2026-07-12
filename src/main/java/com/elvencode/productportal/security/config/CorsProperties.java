package com.elvencode.productportal.security.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.http.HttpMethod;
import org.springframework.util.StringUtils;

import java.time.Duration;
import java.util.Arrays;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@ConfigurationProperties(prefix = "security.cors")
public record CorsProperties(
        List<String> allowedOrigins,
        List<String> allowedOriginPatterns,
        List<String> allowedMethods,
        List<String> allowedHeaders,
        List<String> exposedHeaders,
        Boolean allowCredentials,
        Duration maxAge
) {

    private static final List<String> DEFAULT_ALLOWED_METHODS = List.of(
            HttpMethod.GET.name(),
            HttpMethod.POST.name(),
            HttpMethod.PUT.name(),
            HttpMethod.PATCH.name(),
            HttpMethod.DELETE.name(),
            HttpMethod.OPTIONS.name());
    private static final List<String> DEFAULT_ALLOWED_HEADERS = List.of(
            "Authorization",
            "Content-Type",
            "Accept",
            "Origin",
            "X-Requested-With",
            "X-Correlation-ID");
    private static final List<String> DEFAULT_EXPOSED_HEADERS = List.of("X-Correlation-ID");
    private static final Duration DEFAULT_MAX_AGE = Duration.ofHours(1);
    private static final String WILDCARD = "*";
    private static final Set<String> SUPPORTED_HTTP_METHODS = Arrays.stream(HttpMethod.values())
            .map(HttpMethod::name)
            .collect(Collectors.toUnmodifiableSet());

    public CorsProperties {
        allowedOrigins = normalize(allowedOrigins);
        allowedOriginPatterns = normalize(allowedOriginPatterns);
        allowedMethods = defaultIfEmpty(normalizeMethods(allowedMethods), DEFAULT_ALLOWED_METHODS);
        allowedHeaders = defaultIfEmpty(normalize(allowedHeaders), DEFAULT_ALLOWED_HEADERS);
        exposedHeaders = defaultIfEmpty(normalize(exposedHeaders), DEFAULT_EXPOSED_HEADERS);
        allowCredentials = allowCredentials == null || allowCredentials;
        maxAge = maxAge == null ? DEFAULT_MAX_AGE : maxAge;

        requireOriginsConfigured(allowedOrigins, allowedOriginPatterns);
        requireKnownMethods(allowedMethods);
        requireNoWildcard(allowedMethods, "allowed-methods");
        requireNoWildcard(allowedHeaders, "allowed-headers");
        requireNoWildcard(exposedHeaders, "exposed-headers");
        requireValidCredentialedOrigins(allowedOrigins, allowedOriginPatterns, allowCredentials);
        requirePositive(maxAge, "max-age");
    }

    private static List<String> normalize(List<String> values) {
        if (values == null) {
            return List.of();
        }

        return values.stream()
                .filter(StringUtils::hasText)
                .map(String::trim)
                .distinct()
                .toList();
    }

    private static List<String> normalizeMethods(List<String> methods) {
        return normalize(methods).stream()
                .map(String::toUpperCase)
                .toList();
    }

    private static List<String> defaultIfEmpty(List<String> values, List<String> defaults) {
        return values.isEmpty() ? defaults : values;
    }

    private static void requireOriginsConfigured(List<String> allowedOrigins, List<String> allowedOriginPatterns) {
        if (allowedOrigins.isEmpty() && allowedOriginPatterns.isEmpty()) {
            throw new IllegalArgumentException(
                    "security.cors.allowed-origins or security.cors.allowed-origin-patterns must be configured");
        }
    }

    private static void requireKnownMethods(List<String> allowedMethods) {
        List<String> unknownMethods = allowedMethods.stream()
                .filter(method -> !SUPPORTED_HTTP_METHODS.contains(method))
                .toList();

        if (!unknownMethods.isEmpty()) {
            throw new IllegalArgumentException(
                    "security.cors.allowed-methods contains unsupported HTTP methods: " + unknownMethods);
        }
    }

    private static void requireNoWildcard(List<String> values, String propertyName) {
        if (values.contains(WILDCARD)) {
            throw new IllegalArgumentException("security.cors." + propertyName + " must not contain wildcard '*'");
        }
    }

    private static void requireValidCredentialedOrigins(
            List<String> allowedOrigins,
            List<String> allowedOriginPatterns,
            boolean allowCredentials) {
        if (!allowCredentials) {
            return;
        }

        if (allowedOrigins.contains(WILDCARD) || allowedOriginPatterns.contains(WILDCARD)) {
            throw new IllegalArgumentException(
                    "security.cors cannot use wildcard origins when credentials are allowed");
        }
    }

    private static void requirePositive(Duration value, String propertyName) {
        if (value.isZero() || value.isNegative()) {
            throw new IllegalArgumentException("security.cors." + propertyName + " must be positive");
        }
    }
}

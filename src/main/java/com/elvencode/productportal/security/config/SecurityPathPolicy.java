package com.elvencode.productportal.security.config;

import java.util.List;
import java.util.stream.Stream;

/**
 * Source-controlled authorization matcher policy for the application.
 *
 * <p>This class deliberately is not a {@code @ConfigurationProperties} type. Changes to public,
 * JWT-bypassed, or authenticated paths require a reviewed code change and deployment rather than an
 * environment-variable or YAML override.</p>
 */
public final class SecurityPathPolicy {

    private static final List<String> PUBLIC_API_PATHS = List.of(
            "/api/auth/login",
            "/api/auth/refresh",
            "/api/auth/logout",
            "/api/users/register",
            "/api/contacts/public",
            "/api/logging/public");

    private static final List<String> API_DOCUMENTATION_PATHS = List.of(
            "/api/swagger-ui.html",
            "/api/swagger-ui/**",
            "/swagger-ui/**",
            "/api/v3/api-docs",
            "/api/v3/api-docs/**",
            "/v3/api-docs",
            "/v3/api-docs/**",
            "/swagger-resources/**",
            "/swagger-ui.html",
            "/webjars/**");

    private static final List<String> PERMIT_ALL_PATHS = Stream.concat(
                    PUBLIC_API_PATHS.stream(),
                    API_DOCUMENTATION_PATHS.stream())
            .toList();

    /*
     * Public endpoints must not attempt JWT processing. Reusing the immutable permit-all list makes the
     * subset invariant structural rather than dependent on deployment configuration.
     */
    private static final List<String> JWT_BYPASS_PATHS = PERMIT_ALL_PATHS;

    private static final List<String> AUTHENTICATED_PATHS = List.of("/api/**");

    private SecurityPathPolicy() {
    }

    /**
     * Returns request matchers that are intentionally accessible without authentication.
     *
     * @return immutable public endpoint matchers
     */
    public static List<String> permitAll() {
        return PERMIT_ALL_PATHS;
    }

    /**
     * Returns request matchers excluded from JWT parsing and validation.
     *
     * <p>Every returned matcher is also present in {@link #permitAll()}.</p>
     *
     * @return immutable JWT-filter bypass matchers
     */
    public static List<String> jwtBypass() {
        return JWT_BYPASS_PATHS;
    }

    /**
     * Returns request matchers that require an authenticated principal.
     *
     * @return immutable authenticated endpoint matchers
     */
    public static List<String> authenticated() {
        return AUTHENTICATED_PATHS;
    }
}

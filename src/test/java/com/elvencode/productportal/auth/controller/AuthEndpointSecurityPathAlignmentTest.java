package com.elvencode.productportal.auth.controller;

import com.elvencode.productportal.auth.dto.request.LoginRequest;
import com.elvencode.productportal.auth.session.service.AuthSessionService;
import com.elvencode.productportal.catalog.category.controller.CategoryController;
import com.elvencode.productportal.catalog.product.controller.CategoryProductController;
import com.elvencode.productportal.common.config.web.WebConfig;
import com.elvencode.productportal.scopes.ScopeController;
import com.elvencode.productportal.security.PathsConfig;
import com.elvencode.productportal.security.config.JwtProperties;
import com.elvencode.productportal.security.filter.JwtTokenValidatorFilter;
import com.elvencode.productportal.security.service.CurrentUserAccessService;
import com.elvencode.productportal.security.util.JwtUtil;
import com.elvencode.productportal.user.address.controller.AddressController;
import com.elvencode.productportal.user.controller.UserController;
import jakarta.servlet.http.HttpServletRequest;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.config.annotation.PathMatchConfigurer;

import java.lang.reflect.Method;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Map;
import java.util.function.Predicate;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;

class AuthEndpointSecurityPathAlignmentTest {

    private static final String API_PREFIX = "/api";
    private static final String INTERNAL_LOGIN_PATH = "/auth/login";
    private static final String EXTERNAL_LOGIN_PATH = "/api/auth/login";
    private static final String TEST_JWT_SECRET =
            "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";

    @Test
    void loginEndpointShouldUseCentralApiPrefixBeforeMatchingPublicSecurityPath()
            throws NoSuchMethodException {
        String controllerLoginPath = resolveControllerLoginPath();
        Map<String, Predicate<Class<?>>> pathPrefixes = configuredPathPrefixes();
        Predicate<Class<?>> apiPrefixPredicate = pathPrefixes.get(API_PREFIX);
        List<String> publicPaths = new PathsConfig().publicPaths();
        TestableJwtTokenValidatorFilter jwtFilter = new TestableJwtTokenValidatorFilter(publicPaths);

        assertThat(controllerLoginPath).isEqualTo(INTERNAL_LOGIN_PATH);
        assertThat(pathPrefixes).containsKey(API_PREFIX);
        assertThat(apiPrefixPredicate).accepts(
                AuthController.class,
                UserController.class,
                AddressController.class,
                CategoryController.class,
                CategoryProductController.class);
        assertThat(apiPrefixPredicate).rejects(ScopeController.class);

        String externalLoginPath = API_PREFIX + controllerLoginPath;
        assertThat(externalLoginPath).isEqualTo(EXTERNAL_LOGIN_PATH);
        assertThat(publicPaths).contains(externalLoginPath);
        assertThat(jwtFilter.shouldSkip(externalLoginPath)).isTrue();
        assertThat(jwtFilter.shouldSkip(controllerLoginPath)).isFalse();
    }

    private Map<String, Predicate<Class<?>>> configuredPathPrefixes() {
        TestablePathMatchConfigurer pathMatchConfigurer = new TestablePathMatchConfigurer();
        new WebConfig().configurePathMatch(pathMatchConfigurer);
        return pathMatchConfigurer.pathPrefixes();
    }

    private String resolveControllerLoginPath() throws NoSuchMethodException {
        RequestMapping controllerMapping = AuthController.class.getAnnotation(RequestMapping.class);
        Method loginMethod = AuthController.class.getMethod(
                "login",
                LoginRequest.class,
                HttpServletRequest.class);
        PostMapping loginMapping = loginMethod.getAnnotation(PostMapping.class);

        return join(firstDeclaredPath(controllerMapping.path(), controllerMapping.value()),
                firstDeclaredPath(loginMapping.path(), loginMapping.value()));
    }

    private String firstDeclaredPath(String[] path, String[] value) {
        if (path.length > 0) {
            return path[0];
        }
        return value[0];
    }

    private String join(String parent, String child) {
        return "/" + trimSlashes(parent) + "/" + trimSlashes(child);
    }

    private String trimSlashes(String value) {
        return value.replaceAll("^/+", "").replaceAll("/+$", "");
    }

    private static final class TestablePathMatchConfigurer extends PathMatchConfigurer {

        private Map<String, Predicate<Class<?>>> pathPrefixes() {
            return getPathPrefixes();
        }
    }

    private static final class TestableJwtTokenValidatorFilter extends JwtTokenValidatorFilter {

        private TestableJwtTokenValidatorFilter(List<String> publicPaths) {
            super(
                    publicPaths,
                    new JwtUtil(
                            new JwtProperties(TEST_JWT_SECRET, Duration.ofMinutes(15), "Product Portal"),
                            Clock.fixed(Instant.parse("2026-07-11T10:00:00Z"), ZoneOffset.UTC)),
                    mock(CurrentUserAccessService.class),
                    mock(AuthSessionService.class));
        }

        private boolean shouldSkip(String requestUri) {
            return shouldNotFilter(new MockHttpServletRequest("POST", requestUri));
        }
    }
}

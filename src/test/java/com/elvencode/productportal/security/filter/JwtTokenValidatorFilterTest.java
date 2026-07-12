package com.elvencode.productportal.security.filter;

import com.elvencode.productportal.auth.session.service.AuthSessionService;
import com.elvencode.productportal.common.constants.ApplicationConstants;
import com.elvencode.productportal.common.web.CorrelationIdContext;
import com.elvencode.productportal.common.web.HttpErrorResponseWriter;
import com.elvencode.productportal.security.service.CurrentUserAccessService;
import com.elvencode.productportal.security.util.JwtUtil;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Claims;
import jakarta.servlet.FilterChain;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.security.core.context.SecurityContextHolder;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

class JwtTokenValidatorFilterTest {

    private static final Instant NOW = Instant.parse("2026-07-11T10:00:00Z");

    private final ObjectMapper objectMapper = new ObjectMapper()
            .registerModule(new JavaTimeModule())
            .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
    private final JwtUtil jwtUtil = mock(JwtUtil.class);
    private final CurrentUserAccessService currentUserAccessService = mock(CurrentUserAccessService.class);
    private final AuthSessionService authSessionService = mock(AuthSessionService.class);
    private final HttpErrorResponseWriter errorResponseWriter = new HttpErrorResponseWriter(
            objectMapper,
            Clock.fixed(NOW, ZoneOffset.UTC));
    private final JwtTokenValidatorFilter filter = new JwtTokenValidatorFilter(
            List.of(),
            jwtUtil,
            currentUserAccessService,
            authSessionService,
            errorResponseWriter);

    @Test
    void expiredTokenShouldReturnStandardErrorResponseDto() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/products");
        request.addHeader(ApplicationConstants.JWT_HEADER, "Bearer expired-token");
        request.setAttribute(CorrelationIdContext.REQUEST_ATTRIBUTE, "request-correlation-123");
        MockHttpServletResponse response = new MockHttpServletResponse();
        FilterChain filterChain = mock(FilterChain.class);

        when(jwtUtil.parseSignedClaims("expired-token"))
                .thenThrow(new ExpiredJwtException(null, null, "Token expired"));

        filter.doFilter(request, response, filterChain);

        JsonNode body = objectMapper.readTree(response.getContentAsString());
        assertThat(response.getStatus()).isEqualTo(401);
        assertThat(response.getContentType()).contains("application/json");
        assertThat(response.getHeader(CorrelationIdContext.HEADER_NAME))
                .isEqualTo("request-correlation-123");
        assertThat(body.get("apiPath").asText()).isEqualTo("uri=/api/products");
        assertThat(body.get("errorCode").asText()).isEqualTo("UNAUTHORIZED");
        assertThat(body.get("errorMessage").asText()).isEqualTo("Token expired");
        assertThat(body.get("errorTime").asText()).isEqualTo("2026-07-11T10:00:00");
        assertThat(body.get("correlationId").asText()).isEqualTo("request-correlation-123");
        verifyNoInteractions(filterChain, currentUserAccessService, authSessionService);
        assertThat(SecurityContextHolder.getContext().getAuthentication()).isNull();
    }

    @Test
    void invalidAuthorizationHeaderShouldReturnStandardErrorResponseDto() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/products");
        request.addHeader(ApplicationConstants.JWT_HEADER, "Basic credentials");
        request.addHeader(CorrelationIdContext.HEADER_NAME, "client-correlation-456");
        MockHttpServletResponse response = new MockHttpServletResponse();
        FilterChain filterChain = mock(FilterChain.class);

        filter.doFilter(request, response, filterChain);

        JsonNode body = objectMapper.readTree(response.getContentAsString());
        assertThat(response.getStatus()).isEqualTo(401);
        assertThat(response.getHeader(CorrelationIdContext.HEADER_NAME))
                .isEqualTo("client-correlation-456");
        assertThat(body.get("apiPath").asText()).isEqualTo("uri=/api/products");
        assertThat(body.get("errorCode").asText()).isEqualTo("UNAUTHORIZED");
        assertThat(body.get("errorMessage").asText()).isEqualTo("Invalid token");
        assertThat(body.get("correlationId").asText()).isEqualTo("client-correlation-456");
        verifyNoInteractions(filterChain, jwtUtil, currentUserAccessService, authSessionService);
    }

    @Test
    void unexpectedValidationFailureShouldReturnSafeStandardErrorResponseDto() throws Exception {
        UUID sessionId = UUID.fromString("9db45bc0-3625-47e5-a794-784f37f62734");
        Claims claims = mock(Claims.class);
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/products");
        request.addHeader(ApplicationConstants.JWT_HEADER, "Bearer valid-token");
        request.addHeader(CorrelationIdContext.HEADER_NAME, "client-correlation-789");
        MockHttpServletResponse response = new MockHttpServletResponse();
        FilterChain filterChain = mock(FilterChain.class);

        when(jwtUtil.parseSignedClaims("valid-token")).thenReturn(claims);
        when(claims.get("userId", Number.class)).thenReturn(42L);
        when(claims.get(JwtUtil.SESSION_ID_CLAIM, String.class)).thenReturn(sessionId.toString());
        when(currentUserAccessService.loadContextByUserId(42L))
                .thenThrow(new IllegalStateException("database unavailable internal detail"));

        filter.doFilter(request, response, filterChain);

        JsonNode body = objectMapper.readTree(response.getContentAsString());
        assertThat(response.getStatus()).isEqualTo(500);
        assertThat(response.getHeader(CorrelationIdContext.HEADER_NAME))
                .isEqualTo("client-correlation-789");
        assertThat(body.get("apiPath").asText()).isEqualTo("uri=/api/products");
        assertThat(body.get("errorCode").asText()).isEqualTo("INTERNAL_SERVER_ERROR");
        assertThat(body.get("errorMessage").asText())
                .isEqualTo("An unexpected error occurred. Please contact support with the correlation ID.");
        assertThat(body.get("errorMessage").asText()).doesNotContain("database unavailable");
        assertThat(body.get("correlationId").asText()).isEqualTo("client-correlation-789");
        verifyNoInteractions(filterChain);
    }
}

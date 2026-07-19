package com.elvencode.productportal.security.filter;

import com.elvencode.productportal.common.constants.ApplicationConstants;
import com.elvencode.productportal.auth.session.service.AuthSessionService;
import com.elvencode.productportal.common.web.CorrelationIdContext;
import com.elvencode.productportal.common.web.HttpErrorResponseWriter;
import com.elvencode.productportal.security.authentication.ProductPortalAuthenticationContext;
import com.elvencode.productportal.security.service.CurrentUserAccessService;
import com.elvencode.productportal.security.util.JwtUtil;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.JwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.http.HttpStatus;
import org.springframework.util.AntPathMatcher;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@RequiredArgsConstructor
@Slf4j
public class JwtTokenValidatorFilter extends OncePerRequestFilter {

    private static final String GENERIC_INTERNAL_SERVER_ERROR_MESSAGE =
            "An unexpected error occurred. Please contact support with the correlation ID.";

    private final AntPathMatcher pathMatcher = new AntPathMatcher();

    private final List<String> jwtBypassPaths;

    private final JwtUtil jwtUtil;
    private final CurrentUserAccessService currentUserAccessService;
    private final AuthSessionService authSessionService;
    private final HttpErrorResponseWriter errorResponseWriter;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        try {
            // Resolve the Authorization header. Missing bearer tokens are allowed to continue unauthenticated;
            // authorization rules later decide whether the requested endpoint requires authentication.
            Optional<String> bearerToken = resolveBearerToken(request);
            if (bearerToken.isPresent()) {
                // Verify JWT signature, issuer, and expiration before trusting any token claims.
                Claims claims = jwtUtil.parseSignedClaims(bearerToken.get());

                // Read identity claims, validate the server-side session, then load current user access.
                Long userId = readUserId(claims);
                authSessionService.validateAccessTokenSession(readSessionId(claims), userId);
                ProductPortalAuthenticationContext authenticationContext =
                        currentUserAccessService.loadContextByUserId(userId);

                // Convert the current user, roles, permissions, and account status into Spring Authentication.
                SecurityContextHolder.getContext().setAuthentication(authenticationContext.toAuthentication());
            }
        } catch (ExpiredJwtException exception) {
            // Expired tokens are authentication failures and must not leave stale authentication in the context.
            SecurityContextHolder.clearContext();
            writeUnauthorizedResponse(request, response, "Token expired");
            return;
        } catch (AuthenticationException | JwtException exception) {
            // Invalid tokens, invalid sessions, and denied current-user access all produce a generic 401 response.
            SecurityContextHolder.clearContext();
            writeUnauthorizedResponse(request, response, "Invalid token");
            return;
        } catch (Exception exception) {
            // Unexpected system failures are logged with a correlation ID while returning a generic 500 response.
            SecurityContextHolder.clearContext();
            String correlationId = CorrelationIdContext.resolveOrCreate(request);
            log.error("Unexpected JWT validation exception for request {}. correlationId={}",
                    request.getRequestURI(), correlationId, exception);
            errorResponseWriter.write(
                    request,
                    response,
                    HttpStatus.INTERNAL_SERVER_ERROR,
                    GENERIC_INTERNAL_SERVER_ERROR_MESSAGE);
            return;
        }

        // Continue the filter chain after either successful authentication or an allowed unauthenticated request.
        filterChain.doFilter(request, response);

    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        // Public endpoints are skipped using source-controlled JWT bypass paths.
        String path = request.getRequestURI();
        return jwtBypassPaths.stream().anyMatch(jwtBypassPath ->
                pathMatcher.match(jwtBypassPath, path));
    }

    private Optional<String> resolveBearerToken(HttpServletRequest request) {
        String authHeader = request.getHeader(ApplicationConstants.JWT_HEADER);
        if (!StringUtils.hasText(authHeader)) {
            return Optional.empty();
        }

        if (!authHeader.startsWith("Bearer ")) {
            throw new BadCredentialsException("Invalid Authorization header");
        }

        String token = authHeader.substring(7).trim();
        if (!StringUtils.hasText(token)) {
            throw new BadCredentialsException("Bearer token is empty");
        }

        return Optional.of(token);
    }

    private Long readUserId(Claims claims) {
        Number userId = claims.get("userId", Number.class);
        if (userId != null) {
            return userId.longValue();
        }

        try {
            return Long.valueOf(claims.getSubject());
        } catch (NumberFormatException | NullPointerException exception) {
            throw new BadCredentialsException("Token subject is not a valid user id", exception);
        }
    }

    private UUID readSessionId(Claims claims) {
        String sessionId = claims.get(JwtUtil.SESSION_ID_CLAIM, String.class);
        if (!StringUtils.hasText(sessionId)) {
            throw new BadCredentialsException("Token session id is missing");
        }

        try {
            return UUID.fromString(sessionId);
        } catch (IllegalArgumentException exception) {
            throw new BadCredentialsException("Token session id is not valid", exception);
        }
    }

    private void writeUnauthorizedResponse(
            HttpServletRequest request,
            HttpServletResponse response,
            String errorMessage) throws IOException {
        errorResponseWriter.write(request, response, HttpStatus.UNAUTHORIZED, errorMessage);
    }
}

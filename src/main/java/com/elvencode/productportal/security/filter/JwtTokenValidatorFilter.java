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
import org.springframework.beans.factory.annotation.Qualifier;
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

    @Qualifier("publicPaths")
    private final List<String> publicPaths;

    private final JwtUtil jwtUtil;
    private final CurrentUserAccessService currentUserAccessService;
    private final AuthSessionService authSessionService;
    private final HttpErrorResponseWriter errorResponseWriter;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        try {
            Optional<String> bearerToken = resolveBearerToken(request);
            if (bearerToken.isPresent()) {
                Claims claims = jwtUtil.parseSignedClaims(bearerToken.get());
                Long userId = readUserId(claims);
                authSessionService.validateAccessTokenSession(readSessionId(claims), userId);
                ProductPortalAuthenticationContext authenticationContext =
                        currentUserAccessService.loadContextByUserId(userId);
                SecurityContextHolder.getContext().setAuthentication(authenticationContext.toAuthentication());
            }
        } catch (ExpiredJwtException exception) {
            SecurityContextHolder.clearContext();
            writeUnauthorizedResponse(request, response, "Token expired");
            return;
        } catch (AuthenticationException | JwtException exception) {
            SecurityContextHolder.clearContext();
            writeUnauthorizedResponse(request, response, "Invalid token");
            return;
        } catch (Exception exception) {
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
        filterChain.doFilter(request, response);

    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI();
        return publicPaths.stream().anyMatch(publicPath ->
                pathMatcher.match(publicPath, path));
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

package com.elvencode.productportal.security.filter;

import com.elvencode.productportal.common.constants.ApplicationConstants;
import com.elvencode.productportal.security.authentication.ProductPortalAuthenticationContext;
import com.elvencode.productportal.security.config.JwtProperties;
import com.elvencode.productportal.security.service.CurrentUserAccessService;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.AntPathMatcher;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.crypto.SecretKey;
import java.io.IOException;
import java.util.List;
import java.util.Optional;

@RequiredArgsConstructor
public class JwtTokenValidatorFilter extends OncePerRequestFilter {

    private final AntPathMatcher pathMatcher = new AntPathMatcher();

    @Qualifier("publicPaths")
    private final List<String> publicPaths;

    private final JwtProperties jwtProperties;
    private final CurrentUserAccessService currentUserAccessService;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        try {
            Optional<String> bearerToken = resolveBearerToken(request);
            if (bearerToken.isPresent()) {
                SecretKey secretKey = jwtProperties.signingKey();
                Claims claims = Jwts.parser()
                        .requireIssuer(jwtProperties.issuer())
                        .verifyWith(secretKey)
                        .build().parseSignedClaims(bearerToken.get()).getPayload();
                ProductPortalAuthenticationContext authenticationContext =
                        currentUserAccessService.loadContextByUserId(readUserId(claims));
                SecurityContextHolder.getContext().setAuthentication(authenticationContext.toAuthentication());
            }
        } catch (ExpiredJwtException exception) {
            SecurityContextHolder.clearContext();
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Token expired");
            return;
        } catch (Exception exception) {
            SecurityContextHolder.clearContext();
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Invalid token");
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
}

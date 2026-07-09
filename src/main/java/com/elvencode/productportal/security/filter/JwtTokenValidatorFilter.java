package com.elvencode.productportal.security.filter;

import com.elvencode.productportal.common.constants.ApplicationConstants;
import com.elvencode.productportal.security.principal.ProductPortalUserPrincipal;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.core.env.Environment;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.AntPathMatcher;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.crypto.SecretKey;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.List;

@RequiredArgsConstructor
public class JwtTokenValidatorFilter extends OncePerRequestFilter {

    private final AntPathMatcher pathMatcher = new AntPathMatcher();

    @Qualifier("publicPaths")
    private final List<String> publicPaths;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String authHeader = request.getHeader(ApplicationConstants.JWT_HEADER);

        if (null != authHeader) {
            try {
                // Extract the JWT token
                // Whoever bears (holds) the token is trusted and can access the protected resource.
                String jwt = authHeader.substring(7); // Remove 'Bearer ' prefix
                Environment env = getEnvironment();
                if (null != env) {

                    String secret = env.getProperty(ApplicationConstants.JWT_SECRET_KEY, ApplicationConstants.JWT_SECRET_DEFAULT_VALUE);
                    SecretKey secretKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));

                    if (null != secretKey) {
                        Claims claims = Jwts.parser()
                                .verifyWith(secretKey)
                                .build().parseSignedClaims(jwt).getPayload();
                        ProductPortalUserPrincipal principal = toPrincipal(claims);
                        String roles = claims.get("roles", String.class);
                        Authentication authentication = new UsernamePasswordAuthenticationToken(principal,
                                null, AuthorityUtils.commaSeparatedStringToAuthorityList(roles));
                        SecurityContextHolder.getContext().setAuthentication(authentication);
                    }
                }

            } catch (ExpiredJwtException exception) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("Token Expired");
                return;
            } catch (Exception exception) {
                throw new BadCredentialsException("Invalid Token received!");
            }
        }
        filterChain.doFilter(request, response);

    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI();
        return publicPaths.stream().anyMatch(publicPath ->
                pathMatcher.match(publicPath, path));
    }

    private ProductPortalUserPrincipal toPrincipal(Claims claims) {
        Number userId = claims.get("userId", Number.class);

        return new ProductPortalUserPrincipal(
                userId.longValue(),
                claims.get("username", String.class),
                claims.get("email", String.class),
                claims.get("phoneNumber", String.class),
                claims.get("role", String.class),
                claims.get("status", String.class));
    }
}

package com.elvencode.productportal.security.filter;

import com.elvencode.productportal.common.constants.ApplicationConstants;
import com.elvencode.productportal.security.config.JwtProperties;
import com.elvencode.productportal.security.principal.ProductPortalUserPrincipal;
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
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.AntPathMatcher;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.crypto.SecretKey;
import java.io.IOException;
import java.util.List;
import java.util.Objects;

@RequiredArgsConstructor
public class JwtTokenValidatorFilter extends OncePerRequestFilter {

    private final AntPathMatcher pathMatcher = new AntPathMatcher();

    @Qualifier("publicPaths")
    private final List<String> publicPaths;

    private final JwtProperties jwtProperties;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String authHeader = request.getHeader(ApplicationConstants.JWT_HEADER);

        if (null != authHeader) {
            try {
                // Extract the JWT token
                // Whoever bears (holds) the token is trusted and can access the protected resource.
                String jwt = authHeader.substring(7); // Remove 'Bearer ' prefix
                SecretKey secretKey = jwtProperties.signingKey();
                Claims claims = Jwts.parser()
                        .verifyWith(secretKey)
                        .build().parseSignedClaims(jwt).getPayload();
                ProductPortalUserPrincipal principal = toPrincipal(claims);
                List<SimpleGrantedAuthority> authorities = toAuthorities(claims);
                Authentication authentication = new UsernamePasswordAuthenticationToken(principal,
                        null, authorities);
                SecurityContextHolder.getContext().setAuthentication(authentication);

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
        Number primaryOrganizationId = claims.get("primaryOrganizationId", Number.class);
        List<String> roleCodes = readStringListClaim(claims, "roleCodes");

        return new ProductPortalUserPrincipal(
                userId.longValue(),
                claims.get("username", String.class),
                claims.get("email", String.class),
                claims.get("phoneNumber", String.class),
                primaryOrganizationId == null ? null : primaryOrganizationId.longValue(),
                roleCodes,
                readStringListClaim(claims, "permissionCodes"),
                claims.get("status", String.class));
    }

    private List<SimpleGrantedAuthority> toAuthorities(Claims claims) {
        List<String> authorityNames = readStringListClaim(claims, "authorities");

        return authorityNames.stream()
                .filter(StringUtils::hasText)
                .map(SimpleGrantedAuthority::new)
                .toList();
    }

    private List<String> readStringListClaim(Claims claims, String claimName) {
        Object value = claims.get(claimName);
        if (value instanceof List<?> values) {
            return values.stream()
                    .filter(Objects::nonNull)
                    .map(Object::toString)
                    .filter(StringUtils::hasText)
                    .toList();
        }
        return List.of();
    }
}

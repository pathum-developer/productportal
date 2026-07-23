package com.elvencode.productportal.auth.service.impl;

import com.elvencode.productportal.auth.dto.request.LoginRequest;
import com.elvencode.productportal.auth.dto.request.LogoutRequest;
import com.elvencode.productportal.auth.dto.request.RefreshTokenRequest;
import com.elvencode.productportal.auth.dto.response.LoginResponse;
import com.elvencode.productportal.auth.dto.response.TokenRefreshResponse;
import com.elvencode.productportal.auth.protection.dto.LoginRequestMetadata;
import com.elvencode.productportal.auth.service.AuthService;
import com.elvencode.productportal.auth.session.dto.CreatedAuthSession;
import com.elvencode.productportal.auth.session.dto.RotatedAuthSession;
import com.elvencode.productportal.auth.session.entity.AuthSessionRevocationReason;
import com.elvencode.productportal.auth.session.service.AuthSessionService;
import com.elvencode.productportal.security.authentication.ProductPortalAuthenticationContext;
import com.elvencode.productportal.security.principal.ProductPortalUserPrincipal;
import com.elvencode.productportal.security.service.CurrentUserAccessService;
import com.elvencode.productportal.security.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Service;

import java.time.Clock;
import java.time.Instant;
import java.util.Locale;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;
    private final AuthSessionService authSessionService;
    private final CurrentUserAccessService currentUserAccessService;
    private final Clock clock;

    @Override
    public LoginResponse login(LoginRequest loginRequest, LoginRequestMetadata metadata) {

        UsernamePasswordAuthenticationToken authenticationRequest =
                new UsernamePasswordAuthenticationToken(
                        normalizeUsername(loginRequest.username()),
                        loginRequest.password());
        authenticationRequest.setDetails(metadata);

        var authentication = authenticationManager.authenticate(authenticationRequest);

        Instant issuedAt = clock.instant();
        Instant expiresAt = jwtUtil.calculateAccessTokenExpiresAt(issuedAt);
        ProductPortalUserPrincipal principal = (ProductPortalUserPrincipal) authentication.getPrincipal();
        CreatedAuthSession session = authSessionService.createSession(principal.userId(), metadata);
        String accessToken = jwtUtil.generateJwtToken(authentication, session.sessionId(), issuedAt);

        return new LoginResponse(
                "Bearer",
                accessToken,
                session.refreshToken(),
                session.sessionId(),
                issuedAt,
                expiresAt,
                jwtUtil.getAccessTokenValiditySeconds(),
                session.refreshExpiresAt(),
                new LoginResponse.AuthenticatedUserResponse(
                        principal.userId(),
                        principal.username(),
                        principal.statusCode(),
                        principal.organizationId()),
                new LoginResponse.AccessContextResponse(
                        principal.roleCodes(),
                        principal.permissionCodes()));
    }

    @Override
    public TokenRefreshResponse refresh(RefreshTokenRequest refreshTokenRequest, LoginRequestMetadata metadata) {
        RotatedAuthSession rotatedSession = authSessionService.rotateRefreshToken(
                refreshTokenRequest.refreshToken(),
                metadata);
        ProductPortalAuthenticationContext authenticationContext =
                currentUserAccessService.loadContextByUserId(rotatedSession.userId());

        Instant issuedAt = clock.instant();
        Instant expiresAt = jwtUtil.calculateAccessTokenExpiresAt(issuedAt);
        String accessToken = jwtUtil.generateJwtToken(
                authenticationContext.toAuthentication(),
                rotatedSession.sessionId(),
                issuedAt);

        return new TokenRefreshResponse(
                "Bearer",
                accessToken,
                rotatedSession.refreshToken(),
                rotatedSession.sessionId(),
                issuedAt,
                expiresAt,
                jwtUtil.getAccessTokenValiditySeconds(),
                rotatedSession.refreshExpiresAt());
    }

    @Override
    public void logout(LogoutRequest logoutRequest) {
        authSessionService.revokeRefreshToken(
                logoutRequest.refreshToken(),
                AuthSessionRevocationReason.LOGOUT);
    }

    private String normalizeUsername(String username) {
        return username.trim().toLowerCase(Locale.ROOT);
    }
}

package com.elvencode.productportal.auth.service.impl;

import com.elvencode.productportal.auth.dto.request.LoginRequest;
import com.elvencode.productportal.auth.dto.response.LoginResponse;
import com.elvencode.productportal.auth.protection.dto.LoginRequestMetadata;
import com.elvencode.productportal.auth.service.AuthService;
import com.elvencode.productportal.security.principal.ProductPortalUserPrincipal;
import com.elvencode.productportal.security.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Locale;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;

    @Override
    public LoginResponse login(LoginRequest loginRequest, LoginRequestMetadata metadata) {

        UsernamePasswordAuthenticationToken authenticationRequest =
                new UsernamePasswordAuthenticationToken(
                        normalizeUsername(loginRequest.username()),
                        loginRequest.password());
        authenticationRequest.setDetails(metadata);

        var authentication = authenticationManager.authenticate(authenticationRequest);

        Instant issuedAt = Instant.now();
        Instant expiresAt = jwtUtil.calculateAccessTokenExpiresAt(issuedAt);
        String accessToken = jwtUtil.generateJwtToken(authentication, issuedAt);
        ProductPortalUserPrincipal principal = (ProductPortalUserPrincipal) authentication.getPrincipal();

        return new LoginResponse(
                "Bearer",
                accessToken,
                issuedAt,
                expiresAt,
                jwtUtil.getAccessTokenValiditySeconds(),
                new LoginResponse.AuthenticatedUserResponse(
                        principal.userId(),
                        principal.username(),
                        principal.statusCode(),
                        principal.primaryOrganizationId()),
                new LoginResponse.AccessContextResponse(
                        principal.roleCodes(),
                        principal.permissionCodes()));
    }

    private String normalizeUsername(String username) {
        return username.trim().toLowerCase(Locale.ROOT);
    }
}

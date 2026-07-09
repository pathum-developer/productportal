package com.elvencode.productportal.auth.service.impl;

import com.elvencode.productportal.auth.dto.request.LoginRequest;
import com.elvencode.productportal.auth.dto.response.LoginResponse;
import com.elvencode.productportal.auth.service.AuthService;
import com.elvencode.productportal.security.principal.ProductPortalUserPrincipal;
import com.elvencode.productportal.security.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Locale;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;

    @Override
    public LoginResponse login(LoginRequest loginRequest) {
        var authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        normalizeUsername(loginRequest.username()),
                        loginRequest.password()));

        String accessToken = jwtUtil.generateJwtToken(authentication);
        ProductPortalUserPrincipal principal = (ProductPortalUserPrincipal) authentication.getPrincipal();

        List<String> roles = authentication.getAuthorities()
                .stream()
                .map(GrantedAuthority::getAuthority)
                .toList();

        return new LoginResponse(
                "Bearer",
                accessToken,
                jwtUtil.getAccessTokenValiditySeconds(),
                principal.username(),
                roles);
    }

    private String normalizeUsername(String username) {
        return username.trim().toLowerCase(Locale.ROOT);
    }
}

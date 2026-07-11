package com.elvencode.productportal.auth.service;

import com.elvencode.productportal.auth.dto.request.LoginRequest;
import com.elvencode.productportal.auth.dto.request.LogoutRequest;
import com.elvencode.productportal.auth.dto.request.RefreshTokenRequest;
import com.elvencode.productportal.auth.dto.response.LoginResponse;
import com.elvencode.productportal.auth.dto.response.TokenRefreshResponse;
import com.elvencode.productportal.auth.protection.dto.LoginRequestMetadata;

public interface AuthService {

    LoginResponse login(LoginRequest loginRequest, LoginRequestMetadata metadata);

    TokenRefreshResponse refresh(RefreshTokenRequest refreshTokenRequest, LoginRequestMetadata metadata);

    void logout(LogoutRequest logoutRequest);
}

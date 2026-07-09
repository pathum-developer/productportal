package com.elvencode.productportal.auth.service;

import com.elvencode.productportal.auth.dto.request.LoginRequest;
import com.elvencode.productportal.auth.dto.response.LoginResponse;

public interface AuthService {

    LoginResponse login(LoginRequest loginRequest);
}

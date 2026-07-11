package com.elvencode.productportal.auth.session.service;

import com.elvencode.productportal.auth.protection.dto.LoginRequestMetadata;
import com.elvencode.productportal.auth.session.dto.CreatedAuthSession;
import com.elvencode.productportal.auth.session.dto.RotatedAuthSession;
import com.elvencode.productportal.auth.session.entity.AuthSessionRevocationReason;

import java.util.UUID;

public interface AuthSessionService {

    CreatedAuthSession createSession(Long userId, LoginRequestMetadata metadata);

    RotatedAuthSession rotateRefreshToken(String refreshToken, LoginRequestMetadata metadata);

    void revokeRefreshToken(String refreshToken, AuthSessionRevocationReason reason);

    void validateAccessTokenSession(UUID sessionId, Long userId);

    int revokeUserSessions(Long userId, AuthSessionRevocationReason reason);
}

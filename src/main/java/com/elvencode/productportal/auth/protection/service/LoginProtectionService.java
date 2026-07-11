package com.elvencode.productportal.auth.protection.service;

import com.elvencode.productportal.auth.protection.dto.LoginRequestMetadata;
import com.elvencode.productportal.auth.protection.entity.LoginAttemptOutcome;
import com.elvencode.productportal.auth.protection.exception.LoginBlockedException;

public interface LoginProtectionService {

    void assertLoginAllowed(String username, LoginRequestMetadata metadata);

    void recordBadCredentials(String username, Long userId, LoginRequestMetadata metadata);

    void recordSuccessfulLogin(String username, Long userId, LoginRequestMetadata metadata);

    void recordSecurityFailure(
            String username,
            Long userId,
            LoginAttemptOutcome outcome,
            LoginRequestMetadata metadata);

    void recordBlockedAttempt(
            String username,
            LoginBlockedException exception,
            LoginRequestMetadata metadata);
}

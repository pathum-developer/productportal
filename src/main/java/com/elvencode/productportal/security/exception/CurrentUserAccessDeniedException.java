package com.elvencode.productportal.security.exception;

import org.springframework.security.core.AuthenticationException;

public class CurrentUserAccessDeniedException extends AuthenticationException {

    private final Reason reason;

    public CurrentUserAccessDeniedException(Reason reason) {
        super(reason.message);
        this.reason = reason;
    }

    public Reason reason() {
        return reason;
    }

    public enum Reason {
        USER_NOT_FOUND("Authenticated user no longer exists"),
        ACCOUNT_DISABLED("Authenticated user account is not active"),
        NO_ACTIVE_ROLE_ASSIGNMENT("Authenticated user has no active role assignments");

        private final String message;

        Reason(String message) {
            this.message = message;
        }
    }
}

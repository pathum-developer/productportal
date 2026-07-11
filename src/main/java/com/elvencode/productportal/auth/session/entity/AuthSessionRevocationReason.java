package com.elvencode.productportal.auth.session.entity;

public enum AuthSessionRevocationReason {
    LOGOUT,
    REFRESH_TOKEN_REUSE_DETECTED,
    PASSWORD_CHANGED,
    SESSION_LIMIT_EXCEEDED,
    ADMIN_REVOKED
}

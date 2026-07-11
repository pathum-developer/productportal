package com.elvencode.productportal.auth.protection.entity;

public enum LoginAttemptOutcome {
    SUCCESS,
    BAD_CREDENTIALS,
    ACCOUNT_DISABLED,
    NO_ACTIVE_ROLE_ASSIGNMENT,
    USERNAME_LOCKED,
    IP_THROTTLED
}
